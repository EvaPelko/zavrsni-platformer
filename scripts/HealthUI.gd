extends Control

@export var full_heart: Texture
@export var empty_heart: Texture

var max_health: int = Player_Health.max_health

@onready var hearts = [
	$Heart1,
	$Heart2,
	$Heart3
]

func _ready():
	print("Initializing HealthUI with health:", Player_Health.health)
	update_health_ui(Player_Health.health)  # Initialize the hearts with the current health
	Player_Health.connect("health_changed", Callable(self, "_on_health_changed"))

func _on_health_changed(new_health: int):
	print("Health changed to:", new_health)
	update_health_ui(new_health)

func update_health_ui(current_health: int):
	print("Updating UI with current health:", current_health)
	for i in range(max_health):
		if current_health > i:
			hearts[i].texture = full_heart
		else:
			hearts[i].texture = empty_heart
