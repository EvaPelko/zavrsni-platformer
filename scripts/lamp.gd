extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
var current_scene = null

# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite.play("glitch 1")
	current_scene = get_tree().get_current_scene()
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_interactable_interacted():
	print(current_scene.name)
	if current_scene.name == "level0":
		animated_sprite.play("glitch 2")
		Dialogic.start("lamp_intro")
	if current_scene.name == "level6":
		animated_sprite.play("glitch 3")
		Dialogic.start("lamp_end")
		
func _on_dialogic_signal(argument: String):
	if argument == "finished_intro":
		print("Dialog finished, changing to level 1")
		get_tree().change_scene_to_file("res://scenes/level1.tscn")
	if argument == "end_game":
		print("end game")
		get_tree().change_scene_to_file("res://scenes/GodotCredits.tscn")
