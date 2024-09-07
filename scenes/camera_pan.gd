extends Area2D

@onready var camera = $"../Player/Camera2D"

var camera_zoomed_out = false
var default_camera_zoom = Vector2()
# Called when the node enters the scene tree for the first time.
func _ready():
	if camera:  # Check if camera is properly loaded
		default_camera_zoom = camera.zoom  # Get the current zoom value
		print("Camera Zoom:", default_camera_zoom)
	else:
		print("Camera node not found or path is incorrect")


func _on_body_entered(body):
	if camera_zoomed_out and body.is_in_group("player"):
		camera.zoom = default_camera_zoom
		camera_zoomed_out = false
	elif body.is_in_group("player"):
		camera.zoom = Vector2(3.5, 3.5)
		camera_zoomed_out = true
		
