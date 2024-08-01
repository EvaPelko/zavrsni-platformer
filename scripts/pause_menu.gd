extends Control

#@export var game_ui_manager : GameLevelManager

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	GameManager.connect("toggle_game_paused", _on_game_level_manager_toggle_game_paused)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_game_level_manager_toggle_game_paused(is_paused : bool):
	if(is_paused):
		show()
	else:
		hide()


func _on_resume_button_pressed():
	GameManager.game_paused = false


func _on_quit_button_pressed():
	get_tree().quit()


func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")
	GameManager.game_paused = false
	GameManager.last_menu = "pause menu"
