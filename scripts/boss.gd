extends CharacterBody2D

@export var SPEED = 70
@export var JUMP_FORCE = 300
@export var GRAVITY = 800
@export var JUMP_HORIZONTAL_MULTIPLIER = 3.0  # Multiplier for horizontal jump distance
@export var FLIP_COOLDOWN = 0.5  # Time in seconds before the boss can flip again
var direction = 1  # Start by moving right
var is_alive = true

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var audio_player = $SplatSound
@onready var collision_shape = $CollisionShape2D
@onready var collision_shape_hitbox = $HitBox/CollisionShape2D

var player = null
var chasing_player = false
var on_ground = true
var should_jump = false
var jumping = false
var last_flip_time = 0.0  # Track the time of the last flip

var original_collision_position : Vector2
var original_hitbox_position : Vector2
var flip_padding = 10  # Padding to prevent flipping when too close to a wall

func _ready():
	# Store original positions of the collision shapes
	original_collision_position = collision_shape.position
	original_hitbox_position = collision_shape_hitbox.position

func _physics_process(delta):
	if not is_alive:
		return
	
	if chasing_player:
		move_towards_player(delta)
	else:
		patrol(delta)

	# Apply gravity
	if not on_ground:
		velocity.y += GRAVITY * delta

	# Handle horizontal movement when not on the ground (e.g., during a jump)
	if not on_ground and jumping and player:
		var direction_to_player = (player.global_position - global_position).normalized()
		velocity.x = direction_to_player.x * SPEED * JUMP_HORIZONTAL_MULTIPLIER

	# Move the boss and check for ground collision
	move_and_slide()

	on_ground = is_on_floor()

	# Play run animation if the boss is moving and on the ground
	if on_ground:
		jumping = false
		if abs(velocity.x) > 0:
			animated_sprite.play("run")
		else:
			animated_sprite.stop()
	elif not on_ground and not jumping:
		jumping = true

func patrol(delta):
	if ray_cast_right.is_colliding():
		direction = -1
	elif ray_cast_left.is_colliding():
		direction = 1

	if on_ground and not jumping:
		velocity.x = direction * SPEED

	flip_direction(direction == 1)

func move_towards_player(delta):
	if player and not jumping:
		if should_jump and on_ground:
			jump_towards_player()
		else:
			var direction_to_player = (player.global_position - global_position).normalized()
			velocity.x = direction_to_player.x * SPEED
			flip_direction(direction_to_player.x > 0)

func jump_towards_player():
	if player:
		jumping = true  # Indicate that the boss is in the jump animation
		velocity.y = -JUMP_FORCE  # Apply vertical jump force only
		flip_direction(player.global_position.x > global_position.x)
		animated_sprite.play("jump")

		should_jump = false  # Reset the jump flag after jumping

func flip_direction(is_facing_right):
	if get_time_since_last_flip() < FLIP_COOLDOWN:
		return  # Skip flipping if cooldown period hasn't passed

	# Calculate the new position of the collision shapes if flipped
	var new_collision_position = original_collision_position * Vector2(-1, 1) if is_facing_right else original_collision_position
	var new_hitbox_position = original_hitbox_position * Vector2(-1, 1) if is_facing_right else original_hitbox_position

	# Check if the boss has enough space to flip without getting stuck in the wall
	if not is_facing_right:
		if ray_cast_left.is_colliding():
			var left_collision_distance = abs(ray_cast_left.get_collision_point().x - global_position.x)
			print("Left Raycast Colliding, Distance to Collision:", left_collision_distance)
			if left_collision_distance < flip_padding:
				print("Too close to flip left, skipping flip.")
				return
	else:
		if ray_cast_right.is_colliding():
			var right_collision_distance = abs(ray_cast_right.get_collision_point().x - global_position.x)
			print("Right Raycast Colliding, Distance to Collision:", right_collision_distance)
			if right_collision_distance < flip_padding:
				print("Too close to flip right, skipping flip.")
				return

	# Apply the flip
	print("Flipping direction. Facing right:", is_facing_right)
	animated_sprite.flip_h = is_facing_right
	collision_shape.position = new_collision_position
	collision_shape_hitbox.position = new_hitbox_position

	last_flip_time = Time.get_ticks_msec() / 1000.0  # Update last flip time

func get_time_since_last_flip() -> float:
	return Time.get_ticks_msec() / 1000.0 - last_flip_time

func _on_detection_area_2d_body_entered(body):
	if body.is_in_group("player"):
		print("boss detects player")
		player = body
		chasing_player = true
		should_jump = true  # Set the jump flag when the player is detected

func _on_detection_area_2d_body_exited(body):
	if body == player:
		player = null
		chasing_player = false

func _on_health_health_depleted():
	is_alive = false
	audio_player.play()
	animated_sprite.play("die")
	await animated_sprite.animation_finished
	queue_free()
