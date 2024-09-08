extends Area2D

@onready var audio_player = $HurtSound

@export var SPEED: float = 200.0
@export var DAMAGE: int = 1

var direction: Vector2
var velocity: Vector2

func _ready():
	# Initialize velocity based on direction and speed
	velocity = direction * SPEED
	print('projectile created')

func _process(delta):
	# Apply gravity to vertical velocity
	#velocity.y += gravity * delta
	# Update position based on velocity
	position += velocity * delta
	

#func _on_area_2d_area_entered(area):
#	if area.is_in_group("enemies"):
#		print("enemy hit, didnt take damage")
#		audio_player.play()
#		queue_free()
		
func _on_area_2d_body_entered(body):
	if body.is_in_group("terrain"):
		print("web hit terrain")
		audio_player.play()
		queue_free()
		
	elif body.is_in_group("player"):
		print("web hit player and took damage")
		Player_Health.health -= DAMAGE
		audio_player.play()
		body.slow()
		queue_free()
