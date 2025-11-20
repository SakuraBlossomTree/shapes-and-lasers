extends CharacterBody2D

@export var speed: float = 100.0

@onready var bullet_scene = preload("res://Bullet.tscn")
@onready var bullet_shoot: Timer = $Bullet_Fire
@export var bullet_count: int = 24
@export var bullet_speed: float = 400.0

func _ready():
	add_to_group("octogon_enemy")
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
	for i in range(bullet_count):
		var bullet = bullet_scene.instantiate()
		var angle = deg_to_rad((360.0 / bullet_count) * i)
		
		var direction = Vector2(cos(angle), sin(angle))
		bullet.rotation = direction.angle()
		
		bullet.direction = direction
		bullet.speed = bullet_speed
		bullet.shooter_type = "enemy"
		bullet.global_position = global_position
		
		get_parent().add_child(bullet)

func _on_bullet_fire_timeout() -> void:
	shoot_bullet()
