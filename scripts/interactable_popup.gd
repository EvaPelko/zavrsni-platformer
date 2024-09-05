extends Control

var interactable = false
signal interacted

@onready var label = $Label
@onready var panel = $Panel

func _ready():
	label.visible = false
	panel.visible = false

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		print("player entered")
		interactable = true
		label.visible = true
		panel.visible = true
		print(label.visible)

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		print("player exited")
		interactable = false
		label.visible = false
		panel.visible = false
		print(label.visible)
		Dialogic.end_timeline()
		
func _physics_process(delta):
	if Input.is_action_just_pressed("interact") and interactable:
		interacted.emit()
