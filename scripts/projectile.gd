extends Area2D

@export var SPEED: float = 200.0
@export var DAMAGE: int = 1

var direction: Vector2

func _process(delta):
	position += direction * SPEED * delta
	

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemies"):
		print("hit")
		queue_free()
		

func _on_area_2d_body_entered(body):
	if body.is_in_group("terrain"):
		print("hit terrain")
		queue_free()
