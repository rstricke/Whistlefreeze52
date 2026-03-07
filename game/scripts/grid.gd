@tool
extends Node2D

@export var CELL_SIZE := 32
@export var GRID_SIZE := 100
@export var DEBUG_DRAW := false
@export var DEBUG_DRAW_FOLLOWS_PLAYER := true

@export var player: Player
var monsters: Array[Monster]

var astar_grid: AStarGrid2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.cell_size = CELL_SIZE
	
	monsters.assign(find_child("Monsters").get_children(true))

	for monster in monsters:
		monster.cell_size = CELL_SIZE

	astar_grid = AStarGrid2D.new()
	
	# Top left corner + width and height
	astar_grid.region = Rect2i(-GRID_SIZE / 2, -GRID_SIZE / 2, GRID_SIZE, GRID_SIZE)
	astar_grid.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	astar_grid.update()
	print(astar_grid.get_point_path(Vector2i(0, 0), Vector2i(3, 4))) # Prints [(0, 0), (16, 16), (32, 32), (48, 48), (48, 64)]

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _draw() -> void:
	if DEBUG_DRAW:
		var x_offset := CELL_SIZE / 2.0
		var y_offset := CELL_SIZE / 2.0

		if DEBUG_DRAW_FOLLOWS_PLAYER:
			x_offset -= player.position.x
			y_offset -= player.position.y

		for x in range(-GRID_SIZE / 2.0, GRID_SIZE / 2.0):
			for y in range(-GRID_SIZE / 2.0, GRID_SIZE / 2.0):
				draw_rect(Rect2(x * CELL_SIZE - x_offset, y * CELL_SIZE - y_offset, CELL_SIZE, CELL_SIZE), Color.ALICE_BLUE, false)
		queue_redraw() 


func _on_player_turn_end() -> void:
	print("Turn ended. Monsters turn")

	for monster in monsters:
		# TODO: This delay is temporary for visual effect
		await get_tree().create_timer(.1).timeout
		monster.move(astar_grid, player.position)

	print("Player turn")
	player.player_turn = true
	queue_redraw()
