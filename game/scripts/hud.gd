extends Control

@onready var main_menu: Control = $MainMenu
@onready var game_menu: Control = $GameMenu


var current_menu: Control

func _ready() -> void:
	GameManager.hud = self
	current_menu = main_menu



func play():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	

func switch_gui(menu: Control):
	current_menu.set_deferred("visible", false)
	current_menu = menu
	current_menu.set_deferred("visible", true)
