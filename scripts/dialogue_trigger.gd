extends Area2D

var interactable = true

# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("player") and interactable:
		Dialogic.start("garden")
		
func _on_dialogic_signal(argument: String):
	if argument == "garden_end":
		interactable = false


func _on_body_exited(body):
	pass # Replace with function body.
