extends Node2D

@onready var bullet_scene = preload("res://Bullet.tscn")
@onready var timer: Timer = $Timer

func _ready():
	timer.start()

func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.shooter_type = "enemy"
	bullet.speed = 800.0
	bullet.direction = Vector2.RIGHT
	bullet.global_position = global_position
	bullet.rotation = deg_to_rad(90)

	get_parent().add_child(bullet)

	# ⬇️ THIS stops the bullet after 0.3 seconds
	var stop_timer := Timer.new()
	stop_timer.wait_time = 0.1
	stop_timer.one_shot = true
	stop_timer.connect("timeout", func():
		if is_instance_valid(bullet):
			bullet.speed = 0
	)
	get_tree().current_scene.add_child(stop_timer)
	stop_timer.start()

func _on_timer_timeout():
	shoot_bullet()
