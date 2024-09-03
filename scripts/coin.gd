extends Area2D


@onready var audio_player = $PickupSound
@onready var timer = $Timer
var on_cooldown = false

func _on_body_entered(body):
	if not on_cooldown:
		GameManager.add_point()
		audio_player.play()
		await audio_player.finished
		#queue_free()
		visible = false
		on_cooldown = true
		timer.start()

func _on_timer_timeout():
	on_cooldown = false
	visible = true
