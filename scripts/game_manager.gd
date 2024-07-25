extends Node

var score = 0

@onready var score_label = $UI/Score/ScoreLabel


func _ready():
	Player_Health.health_depleted.connect(_on_player_health_health_depleted)

func add_point():
	score += 1
	print(score)
	score_label.text = str(score)


func _on_player_health_health_depleted():
	print("you died")
	score = 0
	score_label.text = str(score)
	#audio_player.play()
	get_tree().reload_current_scene()
	Player_Health.health = Player_Health.max_health
	
