extends Button

@onready var normal_music = get_node("../../NormalMusic") # UPDATE path if needed
@onready var panel = get_node("..") # or drag-assign if needed$".."

func _on_pressed() -> void:
	# Reset the music pitch back to 1.0 (normal)
	if is_instance_valid(normal_music):
		var tween = create_tween()
		tween.tween_property(normal_music, "pitch_scale", 1.0, 0.5)

	# Hide panel (optional)
	if is_instance_valid(panel):
		panel.visible = false

	await get_tree().create_timer(1.5).timeout
	
	# Reload the main scene
	get_tree().reload_current_scene()
