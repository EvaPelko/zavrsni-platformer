extends CharacterBody2D

@export var SPEED = 70
@export var JUMP_FORCE = 400
@export var GRAVITY = 800
@export var JUMP_HORIZONTAL_MULTIPLIER = 3.5  # Multiplier for horizontal jump distance
@export var JUMP_COOLDOWN = 6000 # ms
@export var JUMP_TRIGGER_DISTANCE = 75
@export var WINDUP_SPEED = 1

const PROJECTILE_OFFSET = Vector2(-20, -10)
var direction = 1  # Start by moving right
var is_alive = true
const PLAYER_AIM_OFFSET = Vector2(0, -10)

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var audio_player = $SplatSound
@onready var collision_shape = $CollisionShape2D
@onready var hitbox_collision_shape = $HitBox/CollisionShape2D
@onready var web_projectile = load('res://scenes/projectile_web.tscn')

#
var player = null
var initial_collision_shape_pos = null
var initial_hitbox_collision_shape_pos = null
var rng = RandomNumberGenerator.new()

# State machine variables
enum State { IDLE, PATROL, CHASE, JUMP, DEAD, SHOOT }
var current_state = State.IDLE

## Jumping and ground check variables
var on_ground = true
var body_is_currently_flipped = false
var last_detected_player_location = null
var time_last_jumped = 0
var jumping = false
var rand_jump_cooldown_offset = 0
var current_projectile_offset = PROJECTILE_OFFSET

func _ready():
	initial_collision_shape_pos = collision_shape.position
	initial_hitbox_collision_shape_pos = hitbox_collision_shape.position
	set_state(State.PATROL)  # Initial state

func _physics_process(delta):
	# State frame by frame behavior
	match current_state:
		State.IDLE:
			state_idle(delta)
		State.PATROL:
			state_patrol(delta)
		State.CHASE:
			state_chasing(delta)
		State.JUMP:
			state_jumping(delta)
		State.SHOOT:
			state_shooting(delta)

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
	if current_state == new_state:
		return
	print("State change (" + State.keys()[current_state] + " -> " + State.keys()[new_state] + ")")
	current_state = new_state
	match new_state:
		State.PATROL:
			animated_sprite.play("run")
			if last_detected_player_location:
				print('xd')
				var direction_to_player = (last_detected_player_location - global_position).normalized()
				velocity.x = sign(direction_to_player.x) * SPEED
			else:
				var rand_dir = (2*rng.randi_range(0, 1) - 1) # random choice [-1, 1]
				print(rand_dir)
				velocity.x = rand_dir * SPEED 
			
		State.CHASE:
			animated_sprite.play("run")
		State.JUMP:
			if player:
				jumping = true
				var direction_to_player = (player.global_position - global_position).normalized()
				velocity.x = sign(direction_to_player.x) * WINDUP_SPEED
				animated_sprite.play("jump")
				await animated_sprite.animation_finished
				
				velocity.y = -max(0.5, direction_to_player.y) * JUMP_FORCE
				velocity.x = sign(direction_to_player.x) * SPEED * JUMP_HORIZONTAL_MULTIPLIER
				print(velocity.x)
				time_last_jumped = Time.get_ticks_msec()
				rand_jump_cooldown_offset = randi_range(-2000, 2000)
				jumping = false
				animated_sprite.play("fall")
		State.DEAD:
			animated_sprite.play("die")
			velocity = Vector2.ZERO
			audio_player.play()
		State.SHOOT:
			animated_sprite.play("shoot")
			velocity.x = velocity.x/abs(velocity.x)
			await animated_sprite.frame_changed
			await animated_sprite.frame_changed
			var direction_to_player = null
			if player:
				direction_to_player = (player.global_position + PLAYER_AIM_OFFSET - global_position - current_projectile_offset).normalized()
			else:
				direction_to_player = (last_detected_player_location + PLAYER_AIM_OFFSET - global_position - current_projectile_offset).normalized()
			var web_projectile_instance = web_projectile.instantiate()
			
			web_projectile_instance.direction = direction_to_player
			web_projectile_instance.position = current_projectile_offset
			add_child(web_projectile_instance)
			print('shot projectile')
			
func state_idle(delta):
	pass

func state_patrol(delta):
	if ray_cast_right.is_colliding():
		velocity.x = -SPEED
	elif ray_cast_left.is_colliding():
		velocity.x = SPEED

func state_chasing(delta):
	if player:
		var distance_to_player = player.global_position - global_position
		var direction_to_player = distance_to_player.normalized()
		velocity.x = direction_to_player.x * SPEED
		
		var time_since_last_jump = Time.get_ticks_msec() - time_last_jumped
		if distance_to_player.length() > JUMP_TRIGGER_DISTANCE and time_since_last_jump > JUMP_COOLDOWN + rand_jump_cooldown_offset:
			set_state(State.JUMP)
		

func state_jumping(delta):
	if on_ground and not jumping and velocity.y >= -1:
		print('on ground and shiet')
		set_state(State.CHASE)

func state_shooting(delta):
	await animated_sprite.animation_finished  # Wait for the shooting animation to finish
	if player:
		set_state(State.CHASE)
	else:
		set_state(State.PATROL)

# Detection area signals
func _on_detection_area_2d_body_entered(body):
	if body.is_in_group("player"):
		print("boss detects player")
		player = body
		if current_state != State.JUMP: 
			set_state(State.CHASE)  # Trigger chasing when player is detected

func _on_detection_area_2d_body_exited(body):
	if body == player:
		player = null
		last_detected_player_location = body.global_position
		#chasing_player = false
		if current_state != State.JUMP: 
			set_state(State.SHOOT)

func flip_body(flip: bool):
	if flip and not body_is_currently_flipped:
		collision_shape.position = initial_collision_shape_pos * Vector2(-1, 1)
		hitbox_collision_shape.position = initial_hitbox_collision_shape_pos * Vector2(-1, 1)
		animated_sprite.flip_h = true
		body_is_currently_flipped = true
		current_projectile_offset = PROJECTILE_OFFSET * Vector2(-1, 1)
		
	elif not flip and body_is_currently_flipped:
		collision_shape.position = initial_collision_shape_pos
		hitbox_collision_shape.position = initial_hitbox_collision_shape_pos
		animated_sprite.flip_h = false
		body_is_currently_flipped = false
		current_projectile_offset = PROJECTILE_OFFSET
		
# Health depletion signal
func _on_health_health_depleted():
	is_alive = false
	set_state(State.DEAD)
	await animated_sprite.animation_finished
	queue_free()
