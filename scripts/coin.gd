extends Area2D


@onready var audio_player = $PickupSound


func _on_body_entered(body):
	GameManager.add_point()
	audio_player.play()
	await audio_player.finished
	queue_free()
