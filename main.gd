extends Node2D

@onready var player = get_node_or_null("Player")
@onready var enemy_scene = preload("res://enemy.tscn")
@onready var hexagon_scene = preload("res://Hexagon.tscn")
@onready var octogon_scene = preload("res://octogon.tscn")
@onready var triangle_scene = preload("res://Triangle.tscn")
@onready var boss_scene = preload("res://boss_triangle.tscn")
@onready var spawn_timer: Timer = $SpawnTimer
@onready var score_label = $Label
@onready var stage_label = $Label2
@onready var end_screen = preload("res://end_game.tscn")
@onready var normal_music = $NormalMusic
@onready var slow_music = $SlowMusic
@onready var main = get_tree().get_root().get_node("Main")
@onready var panel = $Panel
@onready var menu_sound = $Menu_Button_Sound
var score: int = 0
var current_stage = 1
var enemies_spawned_per_stage = 0
var enemies_per_stage = 5
var spawn_interval = 2.0
var target_bpm = 80
var original_bpm = 120
var music_swapped := false

func _ready():
	spawn_timer.start()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	var enemy_x_pos = randf_range(-340, 340)
	var screen_size = get_viewport_rect().size
	enemy.global_position = Vector2(enemy_x_pos, -screen_size.y)
	add_child(enemy)
	
func spawn_hexagon():
	var hexagon = hexagon_scene.instantiate()
	var hexagon_x_pos = randf_range(-340, 340)
	var screen_size = get_viewport_rect().size
	hexagon.global_position = Vector2(hexagon_x_pos, (-screen_size.y+100))
	add_child(hexagon)

func spawn_octogon():
	var octogon = octogon_scene.instantiate()
	var octogon_x_pos = randf_range(-340, 340)
	var screen_size = get_viewport_rect().size
	octogon.global_position = Vector2(octogon_x_pos, (-screen_size.y+400))
	add_child(octogon)

func spawn_triangle():
	print("spawning")
	var triangle = triangle_scene.instantiate()
	var triangle_x_pos = randf_range(-340, 340)
	var screen_size = get_viewport_rect().size
	triangle.global_position = Vector2(triangle_x_pos, (-screen_size.y+200))
	add_child(triangle)

func spawn_boss():
	var boss = boss_scene.instantiate()
	#var boss_x_pos = 0
	var screen_size = get_viewport_rect().size
	boss.global_position = Vector2(screen_size.x / 2, -500)
	add_child(boss)
	print("Boss spawned!")

func _on_spawn_timer_timeout() -> void:
	
	var r = randi_range(0,100)
	
	if current_stage <=5:
		if r < 15:
			spawn_triangle()
		elif r < 60:
			spawn_enemy()
		elif r < 85:
			spawn_hexagon()
		else:
			spawn_octogon()
		
		enemies_spawned_per_stage+=1
			
		if enemies_spawned_per_stage >= enemies_per_stage:
			current_stage += 1
			enemies_spawned_per_stage = 0
			spawn_interval = max(spawn_interval - 0.5, 0.3)
			spawn_timer.wait_time = spawn_interval
			enemies_per_stage += 2
			print("Stage", current_stage, "starting! Spawn interval:", spawn_interval)
	
	elif current_stage == 6:
		spawn_timer.stop()
		for child in get_children():
			if child.is_in_group("enemy") \
			or child.is_in_group("hexagon_enemy") \
			or child.is_in_group("octogon_enemy") \
			or child.is_in_group("triangle_enemy"):
				child.queue_free()
		spawn_boss()
		current_stage += 1


func _process(_delta: float) -> void:
	stage_counter()

	#if not is_instance_valid(player) and not music_swapped:
		#music_swapped = true
		#
		#slow_music.volume_db = -40
		#slow_music.pitch_scale = float(target_bpm) / float(original_bpm)
		#slow_music.play()
#
		#var fade_time = 0.5
		#var tween = create_tween()
#
		## Fade out normal music
		#tween.tween_property(normal_music, "volume_db", -40, fade_time)
		#tween.parallel().tween_property(normal_music, "pitch_scale", slow_music.pitch_scale, fade_time)
#
		## Fade in slow music
		#tween.parallel().tween_property(slow_music, "volume_db", 0, fade_time)
		##print("Player destroyed, restarting scene...")
		##var end_screen_instance = end_screen.instantiate()
		##get_tree().root.add_child(end_screen_instance)
		##end_screen_instance.set_final_score(score)
		##queue_free()
	if not is_instance_valid(player) and not music_swapped:
		music_swapped = true
			
		var slow_pitch = float(target_bpm) / float(original_bpm)   # = 0.666
			
		var tween = create_tween()
			
		# Fade volume & pitch together
		tween.tween_property(normal_music, "pitch_scale", slow_pitch, 1.0)
		
		panel.visible = true
		
func add_score(points: int) -> void:
	score += points
	score_label.text = "Score: " + str(score)

func stage_counter() -> void:
	stage_label.text = "Stage: " + str(current_stage)
	
func reset_game_state():
	# Reset music
	normal_music.pitch_scale = 1.0
	music_swapped = false

	# Reset UI
	panel.visible = false
	stage_label.text = "Stage: 1"
	score_label.text = "Score: 0"

	# Reset variables
	score = 0
	current_stage = 1
	enemies_spawned_per_stage = 0
	spawn_interval = 2.0
	enemies_per_stage = 5

	# Reset the existing player (because it's a node, not a scene)
	if is_instance_valid(player):
		player.global_position = Vector2(0, 0)
		player.show()
		# Also reset any custom variables like HP, velocity, etc.
		# player.health = player.max_health
		# player.velocity = Vector2.ZERO
	else:
		print("WARNING: Player somehow got deleted! Cannot reset.")

	# Remove enemies
	for child in get_children():
		if child.is_in_group("enemy") \
		or child.is_in_group("hexagon_enemy") \
		or child.is_in_group("triangle_enemy") \
		or child.is_in_group("octogon_enemy"):
			child.queue_free()

	# Reset timer
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()




func _on_button_pressed() -> void:
	# Reset the music pitch back to 1.0 (normal)
	menu_sound.play()
	if is_instance_valid(normal_music):
		var tween = create_tween()
		tween.tween_property(normal_music, "pitch_scale", 1.0, 2.0)

	# Hide panel (optional)
	if is_instance_valid(panel):
		panel.visible = false

	await get_tree().create_timer(2.5).timeout
	
	# Reload the main scene
	get_tree().reload_current_scene()

	#if is_instance_valid(main):
		#main.reset_game_state()

func _on_button_2_pressed() -> void:
	menu_sound.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://menu.tscn")
