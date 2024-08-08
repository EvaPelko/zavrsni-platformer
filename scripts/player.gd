extends CharacterBody2D

@export var SPEED = 120.0
const JUMP_VELOCITY = -230.0
const FALL_MULTIPLIER = 1.5  # Gravity multiplier for falling
const FALL_ANIMATION_THRESHOLD = 0.1  # Time in seconds before the fall animation plays
const EARLY_FALL_MULTIPLIER = 3.0  # Gravity multiplier for early fall
const ANTI_GRAVITY_APEX_THRESHOLD = 30.0  # Velocity threshold for anti-gravity apex
const ANTI_GRAVITY_APEX_MULTIPLIER = 0.5  # Gravity multiplier at the apex of the jump

const DASH_SPEED = 450.0
const DASH_DURATION = 0.13  # Duration of the dash in seconds
const DASH_COOLDOWN = 0.5  # Cooldown time between dashes
const DASH_END_FALL_VELOCITY = 200.0  # Small upward velocity added at the end of the dash
const DASH_DECELERATION_RATE = 20000.0  # Rate at which dash speed decelerates after dash ends

const COYOTE_TIME = 0.2  # Time allowed to jump after running off a ledge
const JUMP_BUFFER_TIME = 0.2  # Time window to buffer the jump input

var coyote_timer = 0.0
var jump_buffer_timer = 0.0

var gravity: float
var can_doublejump = false
var fall_time = 0.0
var is_dashing = false
var dash_time = 0.0
var dash_direction = 0
var dash_cooldown_time = 0.0

var player_position = Vector2()

@export var throw_offset_y: float = -9.0
@export var throw_angle: float = 45.0  # Angle of the throw in degrees

@onready var projectile_scene = load("res://scenes/projectile.tscn")
@onready var animated_sprite = $AnimatedSprite2D
@onready var normal_collision_shape = $NormalCollisionShape2D
@onready var duck_collision_shape = $DuckCollisionShape2D
@onready var audio_player = $HurtSound

var is_throwing = false

func _ready():
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	# Ensure the normal collision shape is visible and the duck collision shape is hidden at the start
	normal_collision_shape.visible = true
	duck_collision_shape.visible = false
	
	Player_Health.health_depleted.connect(_on_player_health_depleted)
	Player_Health.damage_taken.connect(_on_player_damage_taken)

func _physics_process(delta):
	# Handle gravity
	if not is_on_floor():
		if velocity.y > 0:  # Falling
			velocity.y += gravity * FALL_MULTIPLIER * delta
			fall_time += delta
			if fall_time > FALL_ANIMATION_THRESHOLD:
				if not is_throwing:
					animated_sprite.play("fall")
		elif abs(velocity.y) < ANTI_GRAVITY_APEX_THRESHOLD:  # Near the apex of the jump
			velocity.y += gravity * ANTI_GRAVITY_APEX_MULTIPLIER * delta
			if not is_throwing:
				animated_sprite.play("jump")
			fall_time = 0.0  # Reset fall time when rising
		else:  # Rising or at the apex
			velocity.y += gravity * delta
			if not is_throwing:
				animated_sprite.play("jump")
			fall_time = 0.0  # Reset fall time when rising
	else:
		velocity.y = 0
		fall_time = 0.0  # Reset fall time when on the floor

	# Check if the player is grounded
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		# Check if there is a buffered jump
		if jump_buffer_timer > 0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0
			can_doublejump = true  # Allow double jump after buffered jump
	else:
		coyote_timer -= delta

	# Handle Jump and Double Jump
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			can_doublejump = true
	elif coyote_timer > 0 and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0  # Reset coyote timer after jumping
		can_doublejump = true  # Allow double jump after coyote jump
	elif Input.is_action_just_pressed("jump") and can_doublejump:
		velocity.y = JUMP_VELOCITY
		can_doublejump = false
	elif Input.is_action_just_pressed("jump"):
		# Buffer the jump if in the air and not able to jump
		jump_buffer_timer = JUMP_BUFFER_TIME

	# Early fall handling
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y += gravity * EARLY_FALL_MULTIPLIER * delta

	# Decrease jump buffer timer
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# Handle Dash
	if is_dashing:
		dash_time -= delta
		if dash_time <= 0:
			is_dashing = false
			dash_cooldown_time = DASH_COOLDOWN
			# After the dash ends, apply a small upward velocity to smooth the transition
			velocity.y = DASH_END_FALL_VELOCITY
			velocity.x = 0  # Ensure no residual dash speed
		else:
			# Override gravity during dash
			velocity.y = 0
			# Decelerate dash speed towards the end
			var deceleration = DASH_DECELERATION_RATE * delta
			if abs(velocity.x) > deceleration:
				velocity.x -= sign(velocity.x) * deceleration
			else:
				velocity.x = 0
			velocity.x = dash_direction * DASH_SPEED
			animated_sprite.play("dash")
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
	if not is_dashing and not is_throwing:
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

	# Handle throwing projectiles
	handle_throw_animation()

	move_and_slide()

func handle_throw_animation():
	if is_throwing:
		if animated_sprite.animation == "throw" and !animated_sprite.is_playing():
			is_throwing = false  # Animation finished
	else:
		# Check if throw action is triggered
		if Input.is_action_just_pressed("shoot"):
			shoot()

func shoot():
	if GameManager.score > 0:
		animated_sprite.play("throw")
		is_throwing = true
		var projectile = projectile_scene.instantiate()
		var direction = Vector2.RIGHT if not animated_sprite.flip_h else Vector2.LEFT
		var angle = throw_angle if animated_sprite.flip_h else -throw_angle
		var throw_direction = direction.rotated(deg_to_rad(angle))
		projectile.direction = throw_direction
		var offset = Vector2(0, throw_offset_y)
		projectile.position = global_position + offset
		get_parent().add_child(projectile)
		GameManager.subtract_point()
	else:
		print("not enough lemons")
		GameManager.show_fade_label("Not enough lemons", global_position)

func _on_player_damage_taken():
	audio_player.play()

func _on_player_health_depleted():
	GameManager.show_fade_label("You died", global_position)
	normal_collision_shape.set_deferred("disabled", true)
	duck_collision_shape.set_deferred("disabled", true)
