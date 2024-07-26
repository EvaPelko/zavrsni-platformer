extends Area2D

@onready var animation_player = $AnimationPlayer


func _on_body_entered(body):
	Player_Health.health += 1
	animation_player.play("pickup")
