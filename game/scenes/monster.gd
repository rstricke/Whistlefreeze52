class_name Monster
extends CharacterBody2D

var cell_size := 0
var stun_timer := 0

func move(astar_grid: AStarGrid2D, target: Vector2):
	if stun_timer > 0:
		stun_timer -= 1
		return
	# TODO: Dividing and multiplying by cell_size works, but is odd
	# There's probably an astar API that takes cell size into account
	var path = astar_grid.get_id_path(position / cell_size, target / cell_size)
	if path.size() > 1: # index 0 is current position
		position = path[1] * cell_size
	if position == target:
		print("ded")
