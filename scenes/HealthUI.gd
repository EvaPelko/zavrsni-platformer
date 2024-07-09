extends Control

@export var full_heart: Texture
@export var empty_heart: Texture

var max_health: int = 3
var current_health: int = 3

var hearts: Array = []

func _ready():
	# Initialize the hearts array
	hearts = [
		$Heart1,
		$Heart2,
		$Heart3
	]
	update_health_ui()

func update_health_ui():
	for i in range(max_health):
		if current_health > i:
			hearts[i].texture = full_heart
		else:
			hearts[i].texture = empty_heart

func take_damage(amount: int):
	current_health -= amount
	current_health = max(current_health, 0)
	update_health_ui()

func heal(amount: int):
	current_health += amount
	current_health = min(current_health, max_health)
	update_health_ui()
