extends Camera2D

@export var shake_duration: float = 0.29
@export var shake_magnitude: float = 2.5

var original_position: Vector2
var shake_timer: float = 0.0

func _ready():
	original_position = position
	Player_Health.damage_taken.connect(shake_camera)

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta
		# Randomize the shake offset
		var shake_offset = Vector2(randf_range(-shake_magnitude, shake_magnitude), randf_range(-shake_magnitude, shake_magnitude))
		position = original_position + shake_offset
		if shake_timer <= 0:
			position = original_position  # Restore the original position after shake is done

func shake_camera():
	shake_timer = shake_duration
