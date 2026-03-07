class_name Monster
extends CharacterBody2D

# Used to determine how far to move for each button press
var cell_size := 0

var stun_timer := 0

func move(astar_grid: AStarGrid2D, target: Vector2):
	# Stunned! Decrease the timer and exit
	if stun_timer > 0:
		stun_timer -= 1
		return
	# TODO: Dividing and multiplying by cell_size works, but is odd
	# There's probably an astar API that takes cell size into account
	# This code moves the monster towards the player, using the pathfinding algorithm
	var path = astar_grid.get_id_path(position / cell_size, target / cell_size)
	if path.size() > 1: # index 0 is current position
		var new_pos: Vector2 = path[1] * cell_size

		if (new_pos == target):
			attack(target)
			return
		
		position = new_pos 

func attack(player_pos: Vector2):
	print("Attack!")
