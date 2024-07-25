class_name HurtBox
extends Area2D

signal received_damage(damage: int)


func _ready():
	connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not is_instance_of(area, HitBox):
		return
	if area != null:
		Player_Health.health -= area.damage
		received_damage.emit(area.damage)
