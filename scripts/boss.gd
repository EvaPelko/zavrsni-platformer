extends CharacterBody2D

@export var SPEED = 70
@export var JUMP_FORCE = 400
@export var GRAVITY = 800
@export var JUMP_HORIZONTAL_MULTIPLIER = 3.5  # Multiplier for horizontal jump distance
@export var JUMP_COOLDOWN = 3000 # ms
@export var JUMP_TRIGGER_DISTANCE = 75
@export var JUMP_WINDUP_SPEED = 1
var direction = 1  # Start by moving right

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var audio_player = $SplatSound
@onready var collision_shape = $CollisionShape2D
@onready var hitbox_collision_shape = $HitBox/CollisionShape2D

#
var player = null
var initial_collision_shape_pos = null
var initial_hitbox_collision_shape_pos = null

# State machine variables
enum State { PATROL, CHASE, JUMP }
var current_state = State.PATROL

## Jumping and ground check variables
#var should_jump = false
#var jumping = false
var on_ground = true
var body_is_currently_flipped = false
var last_detected_player_location = null
var time_last_jumped = 0
var jumping = false

func _ready():
	initial_collision_shape_pos = collision_shape.position
	initial_hitbox_collision_shape_pos = hitbox_collision_shape.position
	set_state(State.PATROL)  # Initial state

func _physics_process(delta):
	# State frame by frame behavior
	match current_state:
		State.PATROL:
			state_patrol(delta)
		State.CHASE:
			state_chasing(delta)
		State.JUMP:
			state_jumping(delta)

	on_ground = is_on_floor()

	## Apply gravity
	if not on_ground:
		velocity.y += GRAVITY * delta
	
	# Flip sprite and collision boxes depending on velocity x component
	if velocity.x > 0:
		flip_body(true)
	else:
		flip_body(false)
	
	# Move the boss and check for ground collision
	move_and_slide()  # Use the built-in velocity

# State transition behavior
func set_state(new_state):
	print("State change (" + State.keys()[current_state] + " -> " + State.keys()[new_state] + ")")
	current_state = new_state
	match new_state:
		State.PATROL:
			animated_sprite.play("run")
		State.CHASE:
			animated_sprite.play("run")
		State.JUMP:
			if player:
				jumping = true
				var direction_to_player = (player.global_position - global_position).normalized()
				velocity.x = sign(direction_to_player.x) * JUMP_WINDUP_SPEED
				animated_sprite.play("jump")
				await animated_sprite.animation_finished
				
				velocity.y = -max(0.5, direction_to_player.y) * JUMP_FORCE
				velocity.x = sign(direction_to_player.x) * SPEED * JUMP_HORIZONTAL_MULTIPLIER
				print(velocity.x)
				time_last_jumped = Time.get_ticks_msec()
				jumping = false
				animated_sprite.play("fall")
			
			
			
func state_patrol(delta):
	if ray_cast_right.is_colliding():
		direction = -1
	elif ray_cast_left.is_colliding():
		direction = 1

	velocity.x = direction * SPEED
	#flip_direction(direction == 1)

	#if player:
		#set_state(State.CHASE)  # Change to CHASING state if player is detected

func state_chasing(delta):
	if player:
		var distance_to_player = player.global_position - global_position
		var direction_to_player = distance_to_player.normalized()
		velocity.x = direction_to_player.x * SPEED
		#flip_direction(direction_to_player.x > 0)
		
		#if should_jump and on_ground:
			#set_state(State.JUMPING)
		
		var time_since_last_jump = Time.get_ticks_msec() - time_last_jumped
		if distance_to_player.length() > JUMP_TRIGGER_DISTANCE and time_since_last_jump > JUMP_COOLDOWN:
			set_state(State.JUMP)
		

func state_jumping(delta):
	if on_ground and not jumping and velocity.y >= -1:
		print('on ground and shiet')
		set_state(State.CHASE)

# Detection area signals
func _on_detection_area_2d_body_entered(body):
	if body.is_in_group("player"):
		print("boss detects player")
		player = body
		#chasing_player = true
		#should_jump = true  # Set the jump flag when the player is detected
		if current_state != State.JUMP: 
			set_state(State.CHASE)  # Trigger chasing when player is detected

func _on_detection_area_2d_body_exited(body):
	if body == player:
		player = null
		#chasing_player = false
		#set_state(State.SHOOTING)
		last_detected_player_location = body.position

func flip_body(flip: bool):
	if flip and not body_is_currently_flipped:
		collision_shape.position = initial_collision_shape_pos * Vector2(-1, 1)
		hitbox_collision_shape.position = initial_hitbox_collision_shape_pos * Vector2(-1, 1)
		animated_sprite.flip_h = true
		body_is_currently_flipped = true
		
	elif not flip and body_is_currently_flipped:
		collision_shape.position = initial_collision_shape_pos
		hitbox_collision_shape.position = initial_hitbox_collision_shape_pos
		animated_sprite.flip_h = false
		body_is_currently_flipped = false
