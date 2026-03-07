@tool
extends Node2D

@export var CELL_SIZE := 32
@export var GRID_SIZE := 100
@export var DEBUG_DRAW := false

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.cell_size = CELL_SIZE
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _draw() -> void:
	if DEBUG_DRAW:
		for x in range(-GRID_SIZE / 2.0, GRID_SIZE / 2.0):
			for y in range(-GRID_SIZE / 2.0, GRID_SIZE / 2.0):
				draw_rect(Rect2(x * CELL_SIZE - CELL_SIZE / 2.0, y * CELL_SIZE - CELL_SIZE / 2.0, CELL_SIZE, CELL_SIZE), Color.ALICE_BLUE, false)
		queue_redraw() 


func _on_player_turn_end() -> void:
	print("Turn ended")
	player.player_turn = true
