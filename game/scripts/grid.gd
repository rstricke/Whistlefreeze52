@tool
extends Node2D

@export var CELL_SIZE := 32
@export var GRID_SIZE_X := 100
@export var GRID_SIZE_Y := 100
@export var DEBUG_DRAW := false
@export var DEBUG_DRAW_FOLLOWS_PLAYER := true

@export var player: Player
@export var obstacleTileMap: TileMapLayer

@export var lockedDoor: TileMapLayer
@export var unlockedDoor: TileMapLayer

@export var monsterScene: PackedScene
@export var monsterSpawnChance := 1.0

@onready var sfx_main_music = $Audio/sfx_main_music
var monsters: Array[Monster]
var walls: Array[StaticBody2D]
var astar_grid: AStarGrid2D
var door_key: Area2D
var fading := false
var fade_speed := 1.5

@export var grid_shift_x := -1
@export var grid_shift_y := 0
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	player.cell_size = CELL_SIZE

	# Get all the "Monster" children
	monsters.assign(find_child("Monsters").get_children(true))
		
	for monster in monsters:
		monster.cell_size = CELL_SIZE
	
	astar_grid = AStarGrid2D.new()

	# Top left corner + width and height
	astar_grid.region = Rect2i(-GRID_SIZE_X / 2 - grid_shift_x, -GRID_SIZE_Y / 2, GRID_SIZE_X, GRID_SIZE_Y)
	print(astar_grid.region)
	astar_grid.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	# No diagonal move
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

	# Get all the "Obstaces" children
	walls.assign(find_child("Obstacles").get_children(false))
	
	# Let the player script know where the walls are so it can't move onto them
	player.walls = walls
	
	# Mark each cell in the grid with a wall as "solid" (impassable) for the pathfinding
	for wall in walls:
		astar_grid.set_point_solid((wall.position / CELL_SIZE).round())
	
	# Mark each cell in the obstacle tilemap with a wall as "solid" (impassable) for the pathfinding
	for tile in obstacleTileMap.get_used_cells():
		astar_grid.set_point_solid(to_global(tile * CELL_SIZE) / CELL_SIZE)

	player.astar_grid = astar_grid

	# Spawn a key after the cells have been marked as solid
	door_key = _spawn_key()
	# Let the player script know where the key is so it is able to acquire it
	player.door_key = door_key

	lock_door()
	
	sfx_main_music.play()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if fading:
		var fade_rect = $Player/CanvasLayer/FadeRect
		fade_rect.color.a += fade_speed * _delta

		if fade_rect.color.a >= 1:
			get_tree().change_scene_to_file("res://Victory.tscn")

# Used to draw the grid. It's useful for visualization, but can be turned off
func _draw() -> void:
	if DEBUG_DRAW:
		var x_offset := CELL_SIZE / 2.0
		var y_offset := CELL_SIZE / 2.0

		if DEBUG_DRAW_FOLLOWS_PLAYER:
			x_offset -= player.position.x
			y_offset -= player.position.y

		for x in range(-GRID_SIZE_X / 2.0 - grid_shift_x, GRID_SIZE_X / 2.0 - grid_shift_x):
			for y in range(-GRID_SIZE_Y / 2.0 - grid_shift_y, GRID_SIZE_Y / 2.0 - grid_shift_y):
				draw_rect(Rect2(x * CELL_SIZE - x_offset, y * CELL_SIZE - y_offset, CELL_SIZE, CELL_SIZE), Color.ALICE_BLUE, false)
		queue_redraw() 

# Called when the player script calls `end_turn`
func _on_player_turn_end() -> void:
	print("Turn ended. Monsters turn")

	var player_turn_delay := 0.0

	# Let the monsters go when the player turn is over
	for monster in monsters:
		# Mark the monsters old square as walkable
		astar_grid.set_point_solid(monster.position / CELL_SIZE, false)

		# TODO: This delay is temporary for visual effect
		await get_tree().create_timer(.075).timeout
		monster.move(astar_grid, player.position)

		# Mark the monsters new square as un-walkable
		astar_grid.set_point_solid(monster.new_pos / CELL_SIZE, true)

		if monster.player_turn_delay > player_turn_delay:
			player_turn_delay = monster.player_turn_delay

	# Let monster attack animations finish playing before we can move again
	await get_tree().create_timer(player_turn_delay).timeout

	print("Player turn")
	player.player_turn = true

	queue_redraw()

func lock_door():
	lockedDoor.visible = true
	unlockedDoor.visible = false
	for tile in lockedDoor.get_used_cells():
		astar_grid.set_point_solid(to_global(tile * CELL_SIZE) / CELL_SIZE)

func unlock_door():
	lockedDoor.visible = false
	unlockedDoor.visible = true
	for tile in lockedDoor.get_used_cells():
		astar_grid.set_point_solid(to_global(tile * CELL_SIZE) / CELL_SIZE, false)

func _spawn_key():
	var new_key = preload("res://scenes/Key.tscn").instantiate()
	new_key.global_position = get_random_walkable_point()
	print('Spawning Key at', new_key.global_position)
	add_child(new_key)
	return new_key

func spawn_monster():
	if randf() >= monsterSpawnChance:
		var pos = get_random_walkable_point()
		var monster: Monster = monsterScene.instantiate() as Monster
		monster.position = pos
		find_child("Monsters").add_child(monster)
		monster.cell_size = CELL_SIZE
		monsters.append(monster)

	
func get_random_walkable_point() -> Vector2:
	var rect := astar_grid.region

	while true:
		var cell := Vector2i(
			randi_range(rect.position.x - grid_shift_x, rect.position.x + rect.size.x - 1 + grid_shift_x),
			randi_range(rect.position.y - grid_shift_y, rect.position.y + rect.size.y - 1 + grid_shift_y)
		)

		if astar_grid.is_in_boundsv(cell) and not astar_grid.is_point_solid(cell) and ((cell * CELL_SIZE) as Vector2 != player.position):
			return cell * CELL_SIZE

	return Vector2.ZERO


func _on_win_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		fading = true
