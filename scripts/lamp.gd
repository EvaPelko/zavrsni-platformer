extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite.play("glitch 1")


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta):
	#if Input.is_action_just_pressed("interact"):
		#animated_sprite.play("glitch 2")


func _on_interactable_interacted():
	animated_sprite.play("glitch 2")
