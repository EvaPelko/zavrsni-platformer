extends Control




func _on_continue_pressed():
	if FileAccess.file_exists(GameManager.save_path):
		GameManager.load_data()
		var scene_number = int(GameManager.current_level)
		var scene_path = "res://scenes/level" + str(scene_number) + ".tscn"
		GameManager.show_fade_label("Loading game...", global_position)
		get_tree().change_scene_to_file(scene_path)
	else:
		GameManager.show_fade_label("No saved game", global_position)


func _on_options_pressed():
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")
	GameManager.last_menu = "main menu"


func _on_quit_pressed():
	get_tree().quit()


func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://scenes/level1.tscn")
	GameManager.delete_data()


