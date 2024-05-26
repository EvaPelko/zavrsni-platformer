extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	print("you died")
	Engine.time_scale = 0.5

	# Disable the collision shapes
	call_deferred("disable_collision_shapes", body)

	timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func disable_collision_shapes(body):
	# Check and disable the normal collision shape
	var normal_collision_shape = body.get_node_or_null("NormalCollisionShape2D")
	if normal_collision_shape:
		normal_collision_shape.set_deferred("disabled", true)

	# Check and disable the duck collision shape
	var duck_collision_shape = body.get_node_or_null("DuckCollisionShape2D")
	if duck_collision_shape:
		duck_collision_shape.set_deferred("disabled", true)
