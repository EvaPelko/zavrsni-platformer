extends Node2D

@onready var chair = $chair
@onready var chair_sat = $chair_sat

# Called when the node enters the scene tree for the first time.
func _ready():
	chair_sat.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_interactable_interacted():
	if chair_sat.visible:
		chair_sat.visible = false
		var player = get_tree().get_nodes_in_group("player")[0]
		player.visible = true
		get_tree().paused = false
	else:
		chair_sat.visible = true
		var player = get_tree().get_nodes_in_group("player")[0]
		player.visible = false
		get_tree().paused = true
