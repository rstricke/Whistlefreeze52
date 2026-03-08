class_name Monster
extends CharacterBody2D

# Used to determine how far to move for each button press
var cell_size := 0

var stun_timer := 0



@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play("idle")


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
		var dir = (new_pos-position).normalized()
		
		if (new_pos == target):
			attack(dir)
			return
		else:
			# Setup Animation
			var tween = create_tween()
			set_up_animation(dir)
			tween.tween_property(self,"position",new_pos,0.2)
			

func attack(dir: Vector2):
	print("  Attack!")
	match dir:
		Vector2(1,0):
			anim.play("attackRight")
		Vector2(-1,0):
			anim.play("attackLeft")
		Vector2(0,1):
			anim.play("attackDown")
		Vector2(0,-1):
			anim.play("attackUp")


func set_up_animation(dir):
	match dir:
		Vector2(1,0):
			anim.play("walkRight")
		Vector2(-1,0):
			anim.play("walkLeft")
		Vector2(0,1):
			anim.play("walkDown")
		Vector2(0,-1):
			anim.play("walkUp")
	
