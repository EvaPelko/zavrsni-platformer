extends Control

@export var full_heart: Texture
@export var empty_heart: Texture
@export var shake_duration: float = 0.29
@export var shake_magnitude: float = 2.5

var max_health: int = Player_Health.max_health

@onready var hearts = [
	$Heart1,
	$Heart2,
	$Heart3
]

# Dictionary to store shaking hearts and their respective timers
var shaking_hearts = {}

func _ready():
	print("Initializing HealthUI with health:", Player_Health.health)
	update_health_ui(Player_Health.health)  # Initialize the hearts with the current health
	Player_Health.connect("health_changed", Callable(self, "_on_health_changed"))

func _process(delta):
	# Process shaking hearts
	for heart in shaking_hearts.keys():
		if shaking_hearts[heart]["timer"] > 0:
			shaking_hearts[heart]["timer"] -= delta
			var original_position = shaking_hearts[heart]["original_position"]
			var shake_offset = Vector2(randf_range(-shake_magnitude, shake_magnitude), randf_range(-shake_magnitude, shake_magnitude))
			heart.position = original_position + shake_offset
		else:
			heart.position = shaking_hearts[heart]["original_position"]
			shaking_hearts.erase(heart)

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
			shake_heart(hearts[i])

func shake_heart(heart: TextureRect):
	var original_position = heart.position
	var shake_timer = shake_duration
	shaking_hearts[heart] = {
		"original_position": original_position,
		"timer": shake_timer
	}
		
