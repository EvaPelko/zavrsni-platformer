extends Node2D

const section_time := 2.0
const line_time := 0.3
const base_speed := 100
const speed_up_multiplier := 10.0
const title_color := Color.AQUA

var scroll_speed := base_speed
var speed_up := false

@onready var line := $CreditsContainer/Line
var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits = [
	[
		"GAME OVER"
	],
	[
		"A game by Eva Pelko"
	],[	
		"Programming",
		"Programmer Name",
		"Programmer Name 2"
	],[	
		"Art",
		"Artist Name"
	],[	
		"Music",
		"Musician Name"
	],[	
		"Sound Effects",
		"SFX Name"
	],[	
		"Testers",
		"Name 1",
		"Name 2",
		"Name 3"
	],[	
		"Tools used",
		"Developed with Godot Engine",
		"https://godotengine.org/license",
		"",
		"Art created with Aseprite",
		"https://www.aseprite.org/"
	],[	
		"Special thanks",
		"My parents",
		"My friends"
	]
]

func _process(delta):
	var scroll_speed = base_speed * delta
	GameManager.hide_ui()
	
	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	
	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if speed_up:
		scroll_speed *= speed_up_multiplier
	
	if lines.size() > 0:
		for l in lines:
			l.position.y -= scroll_speed  # Changed from rect_position to position
			if l.position.y < -l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()


func finish():
	if not finished:
		finished = true
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		#GameManager.delete_data()

func add_line():
	var new_line = line.duplicate()  # You can pass flags if needed like (DUPLICATE_USE_INSTANCING)
	new_line.text = section.pop_front()
	lines.append(new_line)
	
	# If it's the first line, you can set the title color
	if curr_line == 0:
		new_line.add_theme_color_override("font_color", title_color)
	
	$CreditsContainer.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		finish()
	if event.is_action_pressed("ui_down") and not event.is_echo():
		speed_up = true
	if event.is_action_released("ui_down") and not event.is_echo():
		speed_up = false
