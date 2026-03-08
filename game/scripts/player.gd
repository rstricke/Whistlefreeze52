class_name Player
extends CharacterBody2D

@export var whistle_cast: ShapeCast2D
@export var whistle_cd_base := 3
@export var whistle_cd := 0

const PULSE_SCENE = preload("res://scenes/effects/pulse.tscn")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


# Used to let the parent know that the player's turn has ended
signal TURN_END
signal UNLOCK_DOOR
signal WHISTLED

# Player script sets to false, parent sets back to true after monsters go
var player_turn := true

# Used to determine how far to move for each button press
var cell_size := 0

# Used to avoid walking on walls
var walls: Array[StaticBody2D]
var astar_grid: AStarGrid2D

var door_key: Area2D
var key_found: bool = false

var is_moving := false

func _process(_delta: float) -> void:
	if !player_turn:
		return

	var target_pos: Vector2 = Vector2.INF
	var animation := ""
	
	if !is_moving:
		if Input.is_action_just_pressed("move_up"):
			target_pos = position + Vector2(0, -cell_size)
			animation = "walkUp"
		elif Input.is_action_just_pressed("move_down"):
			target_pos = position + Vector2(0, cell_size)
			animation = "walkDown"
		elif Input.is_action_just_pressed("move_left"):
			target_pos = position + Vector2(-cell_size, 0)
			animation = "walkLeft"
		elif Input.is_action_just_pressed("move_right"):
			target_pos = position + Vector2(cell_size, 0)
			animation = "walkRight"

	if (target_pos != Vector2.INF):
		
		#Check if the cell has a key
		if (!key_found):
			if cell_has_key(target_pos):
				key_found = true
				UNLOCK_DOOR.emit()
				%ObjectiveValueLabel.text = 'Look for the door to escape!'
				print("Key Found")
				door_key.queue_free()
		
		# Attempt to move if the target cell is empty
		if cell_empty(target_pos):
			## MOVE
			player_turn = false
			is_moving = true
			anim.play(animation)
			var tween = create_tween()
			tween.tween_property(self, "position", target_pos, 0.2).set_ease(Tween.EASE_IN)
			tween.tween_callback(anim.stop)
			tween.tween_callback(end_turn)
			tween.finished.connect(func(): is_moving = false)
			
			print("Player at position:", position)
			#end_turn()
	
	if Input.is_action_just_pressed("whistle") && whistle_cd <= 0:
		whistle_cd = whistle_cd_base
		anim.play("whistling")
		spawn_pulse()
		WHISTLED.emit()
		for i in whistle_cast.get_collision_count():
			var obj = whistle_cast.get_collider(i)
			if obj is Monster:
				obj.stun_timer = 5
				print("Stunning monster!")
		end_turn()

# Checks if a cell does not have a wall in it
func cell_empty(pos: Vector2) -> bool:
	var has_wall = walls.any(func(wall): return wall.position == pos)
	var has_tile = astar_grid.is_point_solid(pos / cell_size)

	return !has_wall && !has_tile

func cell_has_key(pos: Vector2) -> bool:
	return pos == door_key.global_position

func _physics_process(_delta: float) -> void:
	pass

func end_turn() -> void:
	whistle_cd -= 1
	player_turn = false
	TURN_END.emit()
	
func spawn_pulse():
	print('spawning pulse')
	var pulse = PULSE_SCENE.instantiate()
	pulse.global_position = global_position
	get_tree().current_scene.add_child(pulse)
