class_name Player
extends CharacterBody2D

@export var MAX_SPEED := 300
@export var ACCELETARION := 1200.0
@export var FRICTION := 1000

@export var whistle_cast: ShapeCast2D

signal TURN_END

var player_turn := true
var cell_size := 0

# Used to avoid walking on walls
var walls: Array[StaticBody2D]

var text_down = preload("res://assets/player/Player_WalkDown.png")
var text_up = preload("res://assets/player/Player_WalkUp.png")

func _process(_delta: float) -> void:
	if !player_turn:
		return

	var new_pos: Vector2 = Vector2.INF
	var new_sprite: CompressedTexture2D

	if Input.is_action_just_pressed("move_up"):
		new_pos = position + Vector2(0, -cell_size)
		new_sprite = text_up
	elif Input.is_action_just_pressed("move_down"):
		new_pos = position + Vector2(0, cell_size)
		new_sprite = text_down
	elif Input.is_action_just_pressed("move_left"):
		new_pos = position + Vector2(-cell_size, 0)
	elif Input.is_action_just_pressed("move_right"):
		new_pos = position + Vector2(cell_size, 0)

	if (new_pos != Vector2.INF):
		if cell_empty(new_pos):
			position = new_pos
			if new_sprite != null:
				$Sprite2D.texture = new_sprite
			end_turn()
	
	if Input.is_action_just_pressed("whistle"):
		for i in whistle_cast.get_collision_count():
			var obj = whistle_cast.get_collider(i)
			if obj is Monster:
				obj.stun_timer = 3
				print("Stunning monster!")
		end_turn()

func cell_empty(pos: Vector2) -> bool:
	return !walls.any(func(wall): return wall.position == pos)

func _physics_process(_delta: float) -> void:
	pass

func end_turn() -> void:
	player_turn = false
	TURN_END.emit()
