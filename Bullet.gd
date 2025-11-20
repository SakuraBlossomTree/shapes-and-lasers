extends Area2D

@export var speed: float = 1000.0
@export var direction: Vector2 = Vector2.ZERO
@export var shooter_type: String = "player"

const LAYER_PLAYER_BULLET = 1 << 2
const LAYER_ENEMY_BULLET = 1 << 3
const LAYER_PLAYER = 1 << 0
const LAYER_ENEMY = 1 << 1

func _ready() -> void:
	_setup_collision()
	connect("area_entered", _on_area_entered)
	connect("body_entered", _on_body_entered)

func _setup_collision() -> void:
	if shooter_type == "player":
		collision_layer = LAYER_PLAYER_BULLET
		collision_mask = LAYER_ENEMY
	elif shooter_type == "enemy":
		collision_layer = LAYER_ENEMY_BULLET
		collision_mask = LAYER_PLAYER

func _on_area_entered(area):
	if shooter_type == "player" and area.is_in_group("enemy"):
		_add_score(100)
		area.queue_free()
		queue_free()
	elif shooter_type == "player" and area.is_in_group("hexagon_enemy"):
		_add_score(200)
		area.queue_free()
		queue_free()
	elif shooter_type == "player" and area.is_in_group("octogon_enemy"):
		_add_score(300)
		area.queue_free()
		queue_free()
	elif shooter_type == "player" and area.is_in_group("triangle_enemy"):
		_add_score(50)
		area.queue_free()
		queue_free()
	elif shooter_type == "player" and area.is_in_group("boss_square"):
		area.take_damage(10)
		queue_free()
	elif shooter_type == "enemy" and area.is_in_group("player"):
		area.queue_free()
		queue_free()
		
func _on_body_entered(body):
	if shooter_type == "player" and body.is_in_group("enemy"):
		_add_score(100)
		body.queue_free()
		queue_free()
	elif shooter_type == "player" and body.is_in_group("hexagon_enemy"):
		_add_score(200)
		body.queue_free()
		queue_free()
	elif shooter_type == "player" and body.is_in_group("octogon_enemy"):
		_add_score(300)
		body.queue_free()
		queue_free()
	elif shooter_type == "player" and body.is_in_group("triangle_enemy"):
		_add_score(50)
		body.queue_free()
		queue_free()
	elif shooter_type == "player" and body.is_in_group("boss_square"):
		body.take_damage(10)
		queue_free()
	elif shooter_type == "enemy" and body.is_in_group("player"):
		body.queue_free()
		queue_free()

func _process(delta: float) -> void:
	position += direction * speed * delta

	if position.y < -550 or position.y > 550:
		queue_free()
	elif position.x < -450 or position.x > 450:
		queue_free()

func _add_score(points: int) -> void:
	var gm = get_tree().get_root().get_node_or_null("Main")
	if gm:
		gm.add_score(points)
