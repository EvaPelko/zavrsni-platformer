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
var last_flip_time = 0.0  # Track the time of the last flip
var original_collision_position : Vector2
var original_hitbox_position : Vector2
var flip_padding = 10  # Padding to prevent flipping when too close to a wall

# State machine variables
enum State { IDLE, PATROL, CHASING, SHOOTING, JUMPING, FALLING, DEAD }
var current_state = State.IDLE

# Jumping and ground check variables
var should_jump = false
var jumping = false
var on_ground = true

# Player chasing variable
var chasing_player = false

func _ready():
	# Store original positions of the collision shapes
	original_collision_position = collision_shape.position
	original_hitbox_position = collision_shape_hitbox.position
	set_state(State.IDLE)  # Initial state

func _physics_process(delta):
	if not is_alive:
		return

	match current_state:
		State.IDLE:
			state_idle(delta)
		State.PATROL:
			state_patrol(delta)
		State.CHASING:
			state_chasing(delta)
		State.SHOOTING:
			state_shooting(delta)
		State.JUMPING:
			state_jumping(delta)
		State.FALLING:
			state_falling(delta)

	# Apply gravity
	if not on_ground:
		velocity.y += GRAVITY * delta
	
	# Move the boss and check for ground collision
	move_and_slide()  # Use the built-in velocity

	on_ground = is_on_floor()

	# Transition from falling to chasing when the boss lands
	if current_state == State.FALLING and on_ground:
		set_state(State.CHASING)

# State management
func set_state(new_state):
	current_state = new_state
	print(new_state == State.PATROL)
	match new_state:
		State.IDLE:
			animated_sprite.play("idle")
			velocity.x = 0
		State.PATROL:
			animated_sprite.play("run")
		State.CHASING:
			animated_sprite.play("run")
			if player and not jumping:  # Check if player is present and not jumping
				direction = (player.global_position - global_position).normalized()
				print(direction.x)
				velocity.x = direction.x * SPEED  # Set velocity towards player
				flip_direction(direction.x > 0)
				direction = -1 if direction.x < 0 else 1
				print(direction)
		State.SHOOTING:
			animated_sprite.play("shoot")
			velocity.x = 0
			await animated_sprite.animation_finished
			if player:
				set_state(State.CHASING)
			else:
				set_state(State.IDLE)
		State.JUMPING:
			animated_sprite.play("jump")
			await animated_sprite.animation_finished  # Wait for the jump animation to finish
			perform_jump()  # Perform the jump action
			set_state(State.FALLING)
		State.FALLING:
			animated_sprite.play("fall")
		State.DEAD:
			animated_sprite.play("die")
			velocity = Vector2.ZERO
			audio_player.play()

# State behaviors
func state_idle(delta):
	if player:
		set_state(State.CHASING)  # Change to CHASING state when player is detected
	else:
		set_state(State.PATROL)

func state_patrol(delta):
	if ray_cast_right.is_colliding():
		direction = -1
	elif ray_cast_left.is_colliding():
		direction = 1

	velocity.x = direction * SPEED
	flip_direction(direction == 1)

	if player:
		set_state(State.CHASING)  # Change to CHASING state if player is detected

func state_chasing(delta):
	if player and not jumping:
		var direction_to_player = (player.global_position - global_position).normalized()
		velocity.x = direction_to_player.x * SPEED
		flip_direction(direction_to_player.x > 0)
		
		if should_jump and on_ground:
			set_state(State.JUMPING)

func state_shooting(delta):
	velocity.x = 0
	await animated_sprite.animation_finished  # Wait for the shooting animation to finish
	if player:
		set_state(State.CHASING)
	else:
		set_state(State.IDLE)

func state_jumping(delta):
	# During the jump, apply horizontal movement if in the air
	if not on_ground and jumping:
		var direction_to_player = (player.global_position - global_position).normalized()
		velocity.x = direction_to_player.x * SPEED * JUMP_HORIZONTAL_MULTIPLIER
		if velocity.y > 0:  # Check if starting to fall
			set_state(State.FALLING)

func state_falling(delta):
	if not on_ground:
		# Maintain the horizontal velocity while falling
		var direction_to_player = (player.global_position - global_position).normalized()
		velocity.x = direction_to_player.x * SPEED * JUMP_HORIZONTAL_MULTIPLIER
	elif on_ground:
		velocity = Vector2.ZERO  # Reset velocity upon landing
		jumping = false  # Reset jumping flag when landing
		set_state(State.CHASING)

# Jump action towards the player
func perform_jump():
	if player:
		jumping = true
		velocity.y = -JUMP_FORCE  # Apply vertical jump force
		flip_direction(player.global_position.x > global_position.x)
		should_jump = false  # Reset the jump flag after jumping
	else:
		jumping = false

# Flipping direction based on movement
func flip_direction(is_facing_right):
	if get_time_since_last_flip() < FLIP_COOLDOWN:
		return
	var new_collision_position = original_collision_position * Vector2(-1, 1) if is_facing_right else original_collision_position
	var new_hitbox_position = original_hitbox_position * Vector2(-1, 1) if is_facing_right else original_hitbox_position

	if is_facing_right and ray_cast_right.is_colliding():
		var right_collision_distance = abs(ray_cast_right.get_collision_point().x - global_position.x)
		if right_collision_distance < flip_padding:
			return
	elif not is_facing_right and ray_cast_left.is_colliding():
		var left_collision_distance = abs(ray_cast_left.get_collision_point().x - global_position.x)
		if left_collision_distance < flip_padding:
			return

	print("flip direction")
	animated_sprite.flip_h = is_facing_right
	collision_shape.position = new_collision_position
	collision_shape_hitbox.position = new_hitbox_position
	last_flip_time = Time.get_ticks_msec() / 1000.0

func get_time_since_last_flip() -> float:
	return Time.get_ticks_msec() / 1000.0 - last_flip_time

# Detection area signals
func _on_detection_area_2d_body_entered(body):
	if body.is_in_group("player"):
		print("boss detects player")
		player = body
		chasing_player = true
		should_jump = true  # Set the jump flag when the player is detected
		set_state(State.CHASING)  # Trigger chasing when player is detected

func _on_detection_area_2d_body_exited(body):
	if body == player:
		player = null
		chasing_player = false
		set_state(State.SHOOTING)

# Health depletion signal
func _on_health_health_depleted():
	is_alive = false
	set_state(State.DEAD)
	await animated_sprite.animation_finished
	queue_free()
