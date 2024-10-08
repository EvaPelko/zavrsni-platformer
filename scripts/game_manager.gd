extends Node

var save_path = "res://player1.data"
#var game_saved = false

var score = 0
var current_level = "res://scenes/level0.tscn"
var last_menu = "main menu"

@onready var warning_label = $CanvasLayer/MarginContainer/Warning
@onready var animation_player = $AnimationPlayer
@onready var score_label = $UI/Score/ScoreLabel
@onready var health_ui = $UI/HealthUI
@onready var score_ui = $UI/Score
@onready var timer = $Timer

signal toggle_game_paused(is_paused : bool)

func _ready():
	Player_Health.health_depleted.connect(_on_player_health_health_depleted)
	warning_label.visible = false
	hide_ui()

func add_point():
	score += 1
	print(score)
	score_label.text = str(score)

func subtract_point():
	score -= 1
	print(score)
	score_label.text = str(score)


func _on_player_health_health_depleted():
	print("you died")
	score = 0
	score_label.text = str(score)
	Engine.time_scale = 0.5
	# Disable the collision shapes
	#call_deferred("disable_collision_shapes")
	timer.start()
	
func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
	Player_Health.health = Player_Health.max_health
	
var game_paused : bool = false:
	get:
		return game_paused
	set(value):
		if Dialogic.current_timeline == null:
			game_paused = value
			get_tree().paused = game_paused
			emit_signal("toggle_game_paused", game_paused)

func _input(event : InputEvent):
	if (event.is_action_pressed("ui_cancel")):
		game_paused = !game_paused
		
func show_fade_label(text: String, position: Vector2):
	warning_label.text = text
	warning_label.position = position
	warning_label.modulate = Color(1, 1, 1, 1)  # Reset visibility
	warning_label.visible = true
	animation_player.play("fade_out")
	# Queue free after the animation is done
	await animation_player.animation_finished
	warning_label.visible = false

func save():
	var saved_game:SavedGame = SavedGame.new()
	
	saved_game.health = Player_Health.health
	saved_game.score = score
	saved_game.current_level = current_level
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	
	print("Saved game")
	
func load_data():
	var saved_game:SavedGame = load("user://savegame.tres") as SavedGame
	
	Player_Health.health = saved_game.health
	score = saved_game.score
	current_level = saved_game.current_level
	
	score_label.text = str(score)
#	if FileAccess.file_exists(save_path):
#		var file = FileAccess.open(save_path, FileAccess.READ)
#		score = file.get_var()
#		current_level = file.get_var()
#		Player_Health.health = file.get_var()
#		file.close()
#		#game_saved = true
#		print("Loaded saved game.")
#		score_label.text = str(score)
#	else:
#		print("No data saved.")
#		#game_saved = false
		
func delete_data():
	var saved_game:SavedGame = SavedGame.new()
	
	saved_game.health = Player_Health.max_health
	saved_game.score = 0
	saved_game.current_level = "res://scenes/level0.tscn"
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
#	var file = FileAccess.open(save_path, FileAccess.WRITE)
#	file.store_var(0)
#	file.store_var("res://scenes/level1.tscn")
#	file.store_var(Player_Health.max_health)
#	file.close()
	score_label.text = str(score)
	print("Overwritten save file, starting new game")

func hide_ui():
	health_ui.visible = false
	score_ui.visible = false
	
func show_ui():
	health_ui.visible = true
	score_ui.visible = true
