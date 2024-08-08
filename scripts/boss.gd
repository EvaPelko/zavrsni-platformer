extends CharacterBody2D

@export var SPEED = 70
@export var JUMP_FORCE = 300
@export var GRAVITY = 800
@export var JUMP_HORIZONTAL_MULTIPLIER = 2.0  # Multiplier for horizontal jump distance
var direction = 1  # Start by moving right
var is_alive = true

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var audio_player = $SplatSound

var player = null
var chasing_player = false
var on_ground = true
var should_jump = false
var jumping = false

func _ready():
	pass

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

	animated_sprite.flip_h = direction == 1

func move_towards_player(delta):
	if player and not jumping:
		if should_jump and on_ground:
			jump_towards_player()
		else:
			var direction_to_player = (player.global_position - global_position).normalized()
			velocity.x = direction_to_player.x * SPEED
			animated_sprite.flip_h = direction_to_player.x > 0

func jump_towards_player():
	if player:
		jumping = true  # Indicate that the boss is in the jump animation
		velocity.y = -JUMP_FORCE  # Apply vertical jump force only
		animated_sprite.flip_h = player.global_position.x > global_position.x
		animated_sprite.play("jump")

		should_jump = false  # Reset the jump flag after jumping

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
