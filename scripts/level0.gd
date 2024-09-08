extends Node2D

@onready var player = load('res://scenes/player.tscn')
const PLAYER_POSITION = Vector2(613,462)
# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_dialogic_signal(argument: String):
	if argument == "start_game_end":
		print("Dialog finished, spawning player")
		var player_instance = player.instantiate()
		player_instance.position = PLAYER_POSITION
		add_child(player_instance)
		print('player spawned')
		
