extends Control

@export var full_heart: Texture
@export var empty_heart: Texture

var max_health: int = 3

@onready var hearts = [
	$Heart1,
	$Heart2,
	$Heart3
]

func _ready():
	update_health_ui(max_health)

func update_health_ui(current_health: int):
	for i in range(max_health):
		if current_health > i:
			hearts[i].texture = full_heart
		else:
			hearts[i].texture = empty_heart
