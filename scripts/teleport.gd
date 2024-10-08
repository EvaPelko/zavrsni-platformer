extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("player teleports")
		var current_scene_name = str(get_tree().current_scene.name)
		var next_scene_number = int(current_scene_name) + 1
		var next_scene_path = "res://scenes/level" + str(next_scene_number) + ".tscn"
		GameManager.current_level = next_scene_path
		print(GameManager.current_level)
		GameManager.show_fade_label("Saving game... switching levels...", global_position)
		call_deferred("_change_scene", next_scene_path)
		GameManager.save()

func _change_scene(next_scene_path):
	SceneTransition.change_scene_to_file(next_scene_path)
