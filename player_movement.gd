extends CharacterBody2D

@onready var bullet_scene = preload("res://Bullet.tscn")
@onready var sprite: Sprite2D = $Sprite2D
@onready var bullet_cooldown: Timer = $BulletCooldown
@onready var crt_node: ColorRect = $"../Camera2D/CRT Shader"

const fast_speed = 500.0
const walk_speed = 200.0
var current_speed = 0.0
const ACCEL = 2500.0
#const FRICTION = 2500.0

var crt_enabled := true 

func _physics_process(delta: float) -> void:
	var input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()

	if Input.is_action_pressed("Walk"):
		current_speed = walk_speed
	else:
		current_speed = fast_speed

	if input_dir != Vector2.ZERO:
		velocity.x = move_toward(velocity.x, input_dir.x * current_speed, ACCEL * delta)
		velocity.y = move_toward(velocity.y, input_dir.y * current_speed, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCEL * delta)
		velocity.y = move_toward(velocity.y, 0, ACCEL * delta)

	if bullet_cooldown.is_stopped():
		shoot_bullet()
		bullet_cooldown.start()

	if Input.is_action_just_pressed("toggle_crt"):
		crt_enabled = !crt_enabled
		crt_node.visible = crt_enabled

	var tilt_angle = clamp(velocity.x / current_speed, -1.0, 1.0)
	sprite.rotation_degrees = lerp(sprite.rotation_degrees, tilt_angle * 10.0, delta * 10.0)

	move_and_slide()

func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.shooter_type = "player"
	bullet.direction = Vector2.UP
	bullet.global_position = global_position + Vector2(0, -30)
	get_parent().add_child(bullet)
