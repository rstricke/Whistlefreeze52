extends Control

@onready var main: Control = $Main
@onready var tutorial: Control = $Tutorial
func _ready() -> void:
	tutorial.visible = false
	main.visible = true
	

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
	

func _on_next_button_pressed() -> void:
	tutorial.visible = true
	main.visible = false
