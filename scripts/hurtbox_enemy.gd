extends Area2D

signal received_damage(damage: int)
@onready var health = $"../Health"
@onready var projectile_scene = load("res://scenes/projectile.tscn")

func _ready():
	connect("area_entered", _on_area_entered)
	projectile_scene.enemy_hit.connect(_on_enemy_hit)

func _on_area_entered(area: Area2D) -> void:
	if area != null:
		health.health -= area.damage
		received_damage.emit(area.damage)
		
func _on_enemy_hit():
	print("aaa")
