extends Area2D

const SPEED = 60
const FLY_TIME = 3.0 # Shorter fly time
var direction = 1 # Start by flying left
var fly_time_left = FLY_TIME
var original_direction = direction
var original_position = Vector2()
var returning_to_position = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea2D

var player = null
var chasing_player = false

func _ready():
	original_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if chasing_player:
		fly_towards_player(delta)
	elif returning_to_position:
		return_to_position(delta)
	else:
		fly_cycle(delta)

func fly_cycle(delta):
	fly_time_left -= delta
	if fly_time_left <= 0:
		direction *= -1
		fly_time_left = FLY_TIME
		animated_sprite.flip_h = direction == 1
	
	position.x += direction * SPEED * delta

func fly_towards_player(delta):
	if player:
		var direction_to_player = (player.global_position - global_position).normalized()
		position += direction_to_player * SPEED * delta
		animated_sprite.flip_h = direction_to_player.x > 0

func return_to_position(delta):
	var direction_to_original = (original_position - global_position).normalized()
	position += direction_to_original * SPEED * delta
	animated_sprite.flip_h = direction_to_original.x > 0
	# Check if the enemy is close enough to the original position
	if position.distance_to(original_position) < SPEED * delta:
		position = original_position
		returning_to_position = false
		fly_time_left = FLY_TIME
		direction = original_direction
		animated_sprite.flip_h = direction == 1

func _on_detection_area_2d_body_entered(body):
	if body.is_in_group("player"):
		print("enemy detects player")
		player = body
		chasing_player = true
		original_direction = direction # Save original direction
		original_position = position # Save original position

func _on_detection_area_2d_body_exited(body):
	if body == player:
		player = null
		chasing_player = false
		returning_to_position = true

func _on_health_health_depleted():
	animated_sprite.play("die")
	await animated_sprite.animation_finished
	queue_free()
