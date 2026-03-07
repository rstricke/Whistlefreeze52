@tool
extends Node2D

@export var CELL_SIZE := 32
@export var GRID_SIZE := 100
@export var DEBUG_DRAW := false
@export var DEBUG_DRAW_FOLLOWS_PLAYER := true

@export var player: Player
@export var obstacleTileMap: TileMapLayer

var monsters: Array[Monster]
var walls: Array[StaticBody2D]
var astar_grid: AStarGrid2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.cell_size = CELL_SIZE
	
	# Get all the "Monster" children
	monsters.assign(find_child("Monsters").get_children(true))
		
	for monster in monsters:
		monster.cell_size = CELL_SIZE

	astar_grid = AStarGrid2D.new()
	
	# Top left corner + width and height
	astar_grid.region = Rect2i(-GRID_SIZE / 2, -GRID_SIZE / 2, GRID_SIZE, GRID_SIZE)
	astar_grid.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	astar_grid.update()

	# Get all the "Obstaces" children
	walls.assign(find_child("Obstacles").get_children(false))
	
	# Spawn a key
	_spawn_key()
	
	# Let the player script know where the walls are so it can't move onto them
	player.walls = walls

	# Mark each cell in the grid with a wall as "solid" (impassable) for the pathfinding
	for wall in walls:
		astar_grid.set_point_solid((wall.position / CELL_SIZE).round())
	
	# Mark each cell in the obstacle tilemap with a wall as "solid" (impassable) for the pathfinding
	for tile in obstacleTileMap.get_used_cells():
		astar_grid.set_point_solid(to_global(tile * CELL_SIZE) / CELL_SIZE)

	player.astar_grid = astar_grid

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Used to draw the grid. It's useful for visualization, but can be turned off
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

# Called when the player script calls `end_turn`
func _on_player_turn_end() -> void:
	print("Turn ended. Monsters turn")

	# Let the monsters go when the player turn is over
	for monster in monsters:
		# TODO: This delay is temporary for visual effect
		await get_tree().create_timer(.1).timeout
		monster.move(astar_grid, player.position)

	print("Player turn")
	player.player_turn = true

	queue_redraw()

func _spawn_key() -> void:
	var new_key = preload("res://scenes/Key.tscn").instantiate()
	print(get_random_walkable_point())
	new_key.global_position = get_random_walkable_point()
	add_child(new_key)
	print("Spawning Key")
	
func get_random_walkable_point() -> Vector2:
	var rect := astar_grid.region

	while true:
		var cell := Vector2i(
			randi_range(rect.position.x, rect.position.x + rect.size.x - 1),
			randi_range(rect.position.y, rect.position.y + rect.size.y - 1)
		)

		if astar_grid.is_in_boundsv(cell) and not astar_grid.is_point_solid(cell):
			return cell * CELL_SIZE

	return Vector2.ZERO
