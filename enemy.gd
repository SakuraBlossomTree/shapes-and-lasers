extends CharacterBody2D

@export var speed: float = 400.0

func _ready():
	add_to_group("enemy")
	$Area2D.connect("body_entered", _on_body_entered)

func _physics_process(_delta: float) -> void:
	velocity = Vector2(0, speed)
	move_and_slide()
	
	if global_position.y > get_viewport_rect().size.y + 100:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.queue_free()
