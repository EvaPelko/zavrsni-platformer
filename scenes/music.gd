extends Node2D

@onready var bossfight = $Bossfight
@onready var maintheme = $Maintheme

# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_tree().root)
	# Start playing the main theme when the scene starts
	maintheme.play()

# Function to play the main theme
func play_main_theme():
	if bossfight.playing:  # Only stop the bossfight if it's playing
		bossfight.stop()
	if not maintheme.playing:
		maintheme.play()  # Start the main theme from the beginning

# Function to play the boss theme
func play_boss_theme():
	if maintheme.playing:  # Only stop the main theme if it's playing
		maintheme.stop()
	if not bossfight.playing:
		bossfight.play()  # Start the boss theme from the beginning
