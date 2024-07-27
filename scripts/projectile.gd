extends Area2D

@onready var audio_player = $HurtSound

@export var SPEED: float = 200.0
@export var DAMAGE: int = 1

var direction: Vector2
var velocity: Vector2

func _ready():
	# Initialize velocity based on direction and speed
	velocity = direction * SPEED

func _process(delta):
	# Apply gravity to vertical velocity
	velocity.y += gravity * delta
	# Update position based on velocity
	position += velocity * delta
	

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemies"):
		print("hit")
		audio_player.play()
		queue_free()
		

func _on_area_2d_body_entered(body):
	if body.is_in_group("terrain"):
		print("hit terrain")
		audio_player.play()
		queue_free()
