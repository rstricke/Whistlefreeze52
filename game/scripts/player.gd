class_name Player
extends CharacterBody2D

@export var MAX_SPEED := 300
@export var ACCELETARION := 1200.0
@export var FRICTION := 1000

signal TURN_END

var player_turn := true
var cell_size := 0

var text_down = preload("res://assets/player/Player_WalkDown.png")
var text_up = preload("res://assets/player/Player_WalkUp.png")

func _process(_delta: float) -> void:
	if !player_turn:
		return
	if Input.is_action_just_pressed("move_up"):
		position += Vector2(0, -cell_size)
		$Sprite2D.texture = text_up
		end_turn()
	elif Input.is_action_just_pressed("move_down"):
		position += Vector2(0, cell_size)
		$Sprite2D.texture = text_down
		end_turn()
	elif Input.is_action_just_pressed("move_left"):
		position += Vector2(-cell_size, 0)
		end_turn()
	elif Input.is_action_just_pressed("move_right"):
		position += Vector2(cell_size, 0)
		end_turn()

func _physics_process(_delta: float) -> void:
	pass

func end_turn() -> void:
	player_turn = false
	TURN_END.emit()
