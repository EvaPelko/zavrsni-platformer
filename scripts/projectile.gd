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
		var health_component = area.get_node_or_null("Health")
		if health_component and health_component.has_method("take_damage"):
			health_component.take_damage(DAMAGE)
			print("enemy hit and took damage")
			audio_player.play()
			queue_free()
		else:
			print("hit enemy without health component")
			
		

func _on_area_2d_body_entered(body):
	if body.is_in_group("terrain"):
		print("hit terrain")
		audio_player.play()
		queue_free()
		
	if body.is_in_group("boss"):
		var health_component = body.get_node_or_null("Health")
		if health_component and health_component.has_method("take_damage"):
			health_component.take_damage(DAMAGE)
			print("boss hit and took damage")
			audio_player.play()
			queue_free()
		else:
			print("hit boss without health component")
