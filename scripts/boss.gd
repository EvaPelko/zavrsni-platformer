extends CharacterBody2D

@export var SPEED = 10
@export var JUMP_TIME = 3.0
@export var JUMP_FORCE = 500
@export var BUILD_UP_TIME = 1.0
var direction = 1 # Start by moving right
var jump_time_left = JUMP_TIME
var build_up_time_left = 0.0
var original_direction = direction
var original_position = Vector2()
var returning_to_position = false
var is_alive = true

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var audio_player = $SplatSound

var player = null
var chasing_player = false

func _ready():
	original_position = position

func _process(delta):
	if not is_alive:
		return

	if chasing_player:
		jump_towards_player(delta)
	elif returning_to_position:
		return_to_position(delta)
	else:
		jump_cycle(delta)

func jump_cycle(delta):
	# Check for terrain collision
	if ray_cast_right.is_colliding():
		direction = -1
		jump_time_left = JUMP_TIME # Reset jump time when terrain is detected
	elif ray_cast_left.is_colliding():
		direction = 1
		jump_time_left = JUMP_TIME # Reset jump time when terrain is detected
	
	jump_time_left -= delta
	if jump_time_left <= 0:
		build_up_time_left = BUILD_UP_TIME
		direction *= -1
		jump_time_left = JUMP_TIME

	if build_up_time_left > 0:
		build_up_time_left -= delta
		if build_up_time_left <= 0:
			velocity.y = -JUMP_FORCE

	position.x += direction * SPEED * delta
	animated_sprite.flip_h = direction == 1 # Corrected flipping logic

func jump_towards_player(delta):
	if player:
		if build_up_time_left > 0:
			build_up_time_left -= delta
			return

		var direction_to_player = (player.global_position - global_position).normalized()
		position.x += direction_to_player.x * SPEED * delta
		if is_on_floor():
			velocity.y = -JUMP_FORCE
		animated_sprite.flip_h = direction_to_player.x > 0 # Flip sprite based on player direction

func return_to_position(delta):
	var direction_to_original = (original_position - global_position).normalized()
	position.x += direction_to_original.x * SPEED * delta
	if is_on_floor():
		velocity.y = -JUMP_FORCE

	animated_sprite.flip_h = direction_to_original.x > 0 # Flip sprite based on original position direction
	# Check if the enemy is close enough to the original position
	if position.distance_to(original_position) < SPEED * delta:
		position = original_position
		returning_to_position = false
		jump_time_left = JUMP_TIME
		direction = original_direction
		animated_sprite.flip_h = direction == 1

func _on_detection_area_2d_body_entered(body):
	if body.is_in_group("player"):
		print("boss detects player")
		player = body
		chasing_player = true
		original_direction = direction # Save original direction
		original_position = position # Save original position
		build_up_time_left = BUILD_UP_TIME

func _on_detection_area_2d_body_exited(body):
	if body == player:
		player = null
		chasing_player = false
		returning_to_position = true

func _on_health_health_depleted():
	is_alive = false
	audio_player.play()
	animated_sprite.play("die")
	await animated_sprite.animation_finished
	queue_free()
