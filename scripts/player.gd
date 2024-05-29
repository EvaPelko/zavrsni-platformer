extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -280.0
const FALL_MULTIPLIER = 2.5  # Gravity multiplier for falling
const FALL_ANIMATION_THRESHOLD = 0.1  # Time in seconds before the fall animation plays

const DASH_SPEED = 400.0
const DASH_DURATION = 0.2  # Duration of the dash in seconds
const DASH_COOLDOWN = 0.5  # Cooldown time between dashes

var gravity: float
var can_doublejump = false
var fall_time = 0.0
var is_dashing = false
var dash_time = 0.0
var dash_direction = 0
var dash_cooldown_time = 0.0

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

	# Handle Dash
	if is_dashing:
		dash_time -= delta
		if dash_time <= 0:
			is_dashing = false
			dash_cooldown_time = DASH_COOLDOWN
		else:
			velocity.x = dash_direction * DASH_SPEED
	else:
		dash_cooldown_time -= delta
		if dash_cooldown_time <= 0 and Input.is_action_just_pressed("dash"):
			is_dashing = true
			dash_time = DASH_DURATION
			dash_direction = -1 if animated_sprite.flip_h else 1
			velocity.x = dash_direction * DASH_SPEED
			animated_sprite.play("dash")

	# Get the input direction -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animation
	if not is_dashing:
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

	# Apply movement
	if direction and not is_dashing:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
