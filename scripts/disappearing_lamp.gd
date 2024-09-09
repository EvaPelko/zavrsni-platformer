extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite.play("glitch 2")


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		animated_sprite.visible = false
		Dialogic.start("lamp_seen")
