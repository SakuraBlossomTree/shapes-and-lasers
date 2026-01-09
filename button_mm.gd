extends Button

@onready var menu_sound = $"../Menu_Sound"

func _on_pressed() -> void:
	menu_sound.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://main.tscn")
