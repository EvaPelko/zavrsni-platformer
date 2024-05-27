extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -280.0
const FALL_MULTIPLIER = 2.5  # Gravity multiplier for falling
const FALL_ANIMATION_THRESHOLD = 0.1  # Time in seconds before the fall animation plays

var gravity: float
var can_doublejump = false
var fall_time = 0.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var normal_collision_shape = $NormalCollisionShape2D
@onready var duck_collision_shape = $DuckCollisionShape2D

func _ready():
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	# Ensure the normal collision shape is visible and the duck collision shape is hidden at the start
	normal_collision_shape.visible = true
	duck_collision_shape.visible = false

func _physics_process(delta):
	# Handle gravity
	if not is_on_floor():
		if velocity.y > 0:  # Falling
			velocity.y += gravity * FALL_MULTIPLIER * delta
			fall_time += delta
			if fall_time > FALL_ANIMATION_THRESHOLD:
				animated_sprite.play("fall")
		else:  # Rising or at the apex
			velocity.y += gravity * delta
			animated_sprite.play("jump")
			fall_time = 0.0  # Reset fall time when rising
	else:
		velocity.y = 0
		fall_time = 0.0  # Reset fall time when on the floor

	# Handle Jump and Double Jump
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			can_doublejump = true
	elif Input.is_action_just_pressed("jump") and can_doublejump:
		velocity.y = JUMP_VELOCITY
		can_doublejump = false

	# Get the input direction -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animation
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

	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
