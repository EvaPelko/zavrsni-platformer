extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var can_doublejump = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var normal_collision_shape = $NormalCollisionShape2D
@onready var duck_collision_shape = $DuckCollisionShape2D

func _ready():
	# Ensure the normal collision shape is visible and the duck collision shape is hidden at the start
	normal_collision_shape.visible = true
	duck_collision_shape.visible = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump and Double Jump.
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			can_doublejump = true
	else:
		if Input.is_action_just_pressed("jump") and can_doublejump:
			velocity.y = JUMP_VELOCITY
			can_doublejump = false

	# get the input direction -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# play animation
	if is_on_floor():
		if direction == 0:
			if Input.is_action_pressed("duck"):
				animated_sprite.play("duck")
				normal_collision_shape.visible = false
				duck_collision_shape.visible = true
			else:
				animated_sprite.play("idle")
				normal_collision_shape.visible = true
				duck_collision_shape.visible = false
		else: 
			animated_sprite.play("run")
			normal_collision_shape.visible = true
			duck_collision_shape.visible = false
	else:
		animated_sprite.play("jump")
		normal_collision_shape.visible = true
		duck_collision_shape.visible = false

	
	# apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
