extends Node2D

@onready var label = $Label
@onready var restart_button = $Button

func _ready() -> void:
	restart_button.connect("pressed", _on_restart_pressed)

func set_final_score(score: int) -> void:
	label.text = "Final Score: " + str(score)

func _on_restart_pressed() -> void:
	queue_free()
	get_tree().change_scene_to_file("res://main.tscn")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_on_restart_pressed()
