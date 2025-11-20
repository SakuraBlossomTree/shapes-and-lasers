extends CharacterBody2D

@export var speed: float = 100.0
@export var max_hp: int = 200
var current_hp: int
var center_x: float = 0
var amplitude: float = 330.0
var mov_speed: float = 1.0

@onready var hp_bar: ProgressBar = $Control/ProgressBar

# Bullet properties
@onready var bullet_scene = preload("res://Bullet.tscn")
@export var bullet_speed: float = 400.0

# Spread attack (Phase 1)
@export var spread_bullet_count: int = 36

# Spiral attack (Phase 2)
@export var spiral_bullet_count: int = 12
var spiral_angle: float = 0.0

# Horizontal lines (Phase 3)
@export var line_bullet_count: int = 10
@export var line_spacing: float = 50.0  # vertical gap between lines

# Timers
@onready var attack_timer: Timer = $AttackTimer
@onready var pattern_timer: Timer = $PatternTimer

const ROTATION_OFFSET = deg_to_rad(-90)
var current_pattern: int = 0
var player: Node2D
var game_manager: Node

func _ready():
	current_hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	add_to_group("boss_square")
	player = get_tree().get_first_node_in_group("player")
	game_manager = get_tree().get_first_node_in_group("Main")
	attack_timer.start()
	pattern_timer.start()

func _physics_process(_delta: float) -> void:
	# Optional boss oscillation
	global_position.x = center_x + sin(Time.get_ticks_msec() / 1000.0 * mov_speed) * amplitude
	
	# Optional: face player
	if player:
		look_at(player.global_position)
		rotation += ROTATION_OFFSET

# --- Timer callbacks ---
func _on_attack_timer_timeout() -> void:
	match current_pattern:
		0:
			spread_attack()
		1:
			spiral_attack()
		2:
			horizontal_lines_attack()

func _on_pattern_timer_timeout() -> void:
	current_pattern = (current_pattern + 1) % 3  # 3 phases

# --- ATTACKS ---

# Phase 1: Spread bullets
func spread_attack():
	for i in range(spread_bullet_count):
		var bullet = bullet_scene.instantiate()
		var angle = deg_to_rad((360.0 / spread_bullet_count) * i)
		var dir = Vector2(cos(angle), sin(angle))
		bullet.rotation = dir.angle()
		bullet.direction = dir
		bullet.speed = bullet_speed
		bullet.shooter_type = "enemy"
		bullet.global_position = global_position
		get_parent().add_child(bullet)

# Phase 2: Spiral bullets
func spiral_attack():
	for i in range(spiral_bullet_count):
		var bullet = bullet_scene.instantiate()
		var angle = deg_to_rad((360.0 / spiral_bullet_count) * i + spiral_angle)
		var dir = Vector2(cos(angle), sin(angle))
		bullet.rotation = dir.angle()
		bullet.direction = dir
		bullet.speed = bullet_speed
		bullet.shooter_type = "enemy"
		bullet.global_position = global_position
		get_parent().add_child(bullet)
	spiral_angle += 10.0

# Phase 3: Horizontal lines with gaps
func horizontal_lines_attack():
	var num_lines = 3  # number of horizontal lines
	for i in range(num_lines):
		var y_offset = i * line_spacing - line_spacing  # position lines above/below boss
		var bullet_spacing = 50  # horizontal spacing between bullets

		for j in range(line_bullet_count):
			if j % 3 == 0:
				continue  # create gaps

			var bullet = bullet_scene.instantiate()
			# X relative to boss
			var x_pos = global_position.x + (j - line_bullet_count / 2.0) * bullet_spacing
			bullet.global_position = Vector2(x_pos, global_position.y + y_offset)

			bullet.direction = Vector2(0, 1)  # move downward
			bullet.speed = bullet_speed
			bullet.shooter_type = "enemy"
			get_parent().add_child(bullet)
			
func take_damage(amount: int) -> void:
	current_hp -= amount
	hp_bar.value = current_hp
	if current_hp <= 0:
		die()
		
func die():
	if game_manager and is_instance_valid(game_manager):
		game_manager.add_score(1000)
	queue_free()
