extends CharacterBody2D

@export var speed: float = 600.0

@onready var player = get_tree().get_first_node_in_group("player")

const ROTATION_OFFSET = deg_to_rad(90)

func _ready():
	add_to_group("triangle_enemy")
	$Area2D.connect("body_entered", _on_body_entered)

func _physics_process(_delta: float) -> void:
	if not player:
		return
	
	# Move toward player
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	
	# Rotate toward player
	look_at(player.global_position)
	rotation += ROTATION_OFFSET
	
	# Remove if off-screen
	if global_position.y > get_viewport_rect().size.y + 100:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.queue_free()
		queue_free()
