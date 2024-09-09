extends CanvasLayer

var glitch_time = 0.0
var glitch_duration = 1.5
var glitch_text = ""
var letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;':,./<>?`~"
var glitching = false

# Called to change scene with specified transition type
func change_scene_to_file(target: String, type: String = 'dissolve') -> void:
	if type == 'dissolve':
		await transition_dissolve(target)
	else:
		await transition_clouds(target)

# Dissolve transition with glitchy effect
func transition_dissolve(target: String) -> void:
	$AnimationPlayer.play('dissolve')
	start_glitch_effect()  # Start the glitch effect during the dissolve
	await $AnimationPlayer.animation_finished  # Await the 'animation_finished' signal
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards('dissolve')
	stop_glitch_effect()  # Stop glitch effect when transition ends

# Clouds transition with glitchy effect
func transition_clouds(target: String) -> void:
	$AnimationPlayer.play('clouds_in')
	start_glitch_effect()  # Start the glitch effect during the clouds transition
	await $AnimationPlayer.animation_finished  # Await the 'animation_finished' signal
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play('clouds_out')
	stop_glitch_effect()  # Stop glitch effect when transition ends

# Start glitch effect
func start_glitch_effect():
	glitching = true
	glitch_time = 0.0
	$GlitchLabel.visible = true
	#$dissolve_rect.visible = true
	randomize()
	set_process(true)  # Enable _process for glitch updates

# Stop glitch effect
func stop_glitch_effect():
	glitching = false
	$GlitchLabel.visible = false
	#$dissolve_rect.visible = false
	set_process(false)  # Disable _process when glitch is not needed

# Process the glitch effect every frame
func _process(delta: float) -> void:
	if glitching:
		glitch_time += delta
		if glitch_time < glitch_duration:
			glitch_text = generate_glitch_text(40)
			$GlitchLabel.text = glitch_text
			$GlitchLabel.modulate = Color(randf(), randf(), randf(), 1)  # Random color for glitch text
			#$dissolve_rect.color = Color(0, 0, 0, 0.1 + randf() * 0.3)  # Random background flicker
		else:
			stop_glitch_effect()

# Generate random glitchy text for the effect
func generate_glitch_text(length: int) -> String:
	var text = ""
	for i in range(length):
		text += letters[randi() % letters.length()]
	return text
