extends Node

var score = 0

@onready var score_label = $UI/Score/ScoreLabel


func add_point():
	score += 1
	print(score)
	score_label.text = str(score)
