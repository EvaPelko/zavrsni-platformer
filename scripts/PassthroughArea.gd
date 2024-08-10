extends Area2D

@onready var collision_shape_2d_passable = $CollisionShape2DPassable

func _ready():
	collision_shape_2d_passable.disabled = false

#func _on_body_entered(body):
#	if body.is_in_group("player"):
#		collision_shape_2d_passable.disabled = true  # Disable legs collision when player is underneath
#
#func _on_body_exited(body):
#	if body.is_in_group("player"):
#		collision_shape_2d_passable.disabled = false  # Re-enable legs collision when player leaves
