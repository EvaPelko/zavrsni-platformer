extends Control

@onready var sfxVolumeSlider = $"VBoxContainer/SFX/MarginContainer/HSlider"
@onready var bgmVolumeSlider = $"VBoxContainer/Music/MarginContainer/HSlider"
@onready var sfxPreview = $"SFX Preview"


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	

func _on_sfx_volume_signal(new_value):
	sfxVolumeSlider.value = new_value


func _on_bgm_volume_signal(new_value):
	bgmVolumeSlider.value = new_value




func _on_sfx_volume_slider_value_changed(value):
	Options.sfx_volume = value
	
	#if (visible):
	#	sfxPreview.play()


func _on_bgm_volume_slider_value_changed(value):
	Options.bgm_volume = value
