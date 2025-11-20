extends CharacterBody2D

@export var speed: float = 400.0

@onready var bullet_scene = preload("res://Bullet.tscn")
@onready var bullet_shoot: Timer = $Bullet_Fire

func _ready():
	add_to_group("hexagon_enemy")
	$Area2D.connect("body_entered", _on_body_entered)
	bullet_shoot.start()

func _physics_process(_delta: float) -> void:
	velocity = Vector2(0, speed)
	move_and_slide()
	
	if global_position.y > get_viewport_rect().size.y + 100:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.queue_free()
	
func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.shooter_type = "enemy"
	bullet.speed = 800.0
	bullet.direction = Vector2.DOWN
	bullet.global_position = global_position + Vector2(0, 30)
	get_parent().add_child(bullet)

func _on_timer_timeout() -> void:
	shoot_bullet()
