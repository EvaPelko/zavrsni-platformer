extends Node

var score = 0
#var current_level = str(get_tree().current_scene.name)

@onready var score_label = $UI/Score/ScoreLabel
@onready var timer = $Timer

signal toggle_game_paused(is_paused : bool)

func _ready():
	Player_Health.health_depleted.connect(_on_player_health_health_depleted)

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
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused", game_paused)

func _input(event : InputEvent):
	if (event.is_action_pressed("ui_cancel")):
		game_paused = !game_paused
