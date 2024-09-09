extends Control

#@export var game_ui_manager : GameLevelManager
@onready var sfxVolumeSlider = $Panel/VBoxContainer/VBoxContainer/SFX/MarginContainer/HSlider
@onready var bgmVolumeSlider = $Panel/VBoxContainer/VBoxContainer/Music/MarginContainer/HSlider

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	GameManager.connect("toggle_game_paused", _on_game_level_manager_toggle_game_paused)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_game_level_manager_toggle_game_paused(is_paused : bool):
	print(Dialogic.current_timeline != null)
	if(is_paused and Dialogic.current_timeline == null):
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


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	GameManager.game_paused = false
	GameManager.hide_ui()


func _on_sfx_volume_signal(new_value):
	sfxVolumeSlider.value = new_value


func _on_bgm_volume_signal(new_value):
	bgmVolumeSlider.value = new_value



func _on_bgm_volume_slider_value_changed(value):
	Options.bgm_volume = value



func _on_sfx_volume_slider_value_changed(value):
	Options.sfx_volume = value
