class_name Monster
extends CharacterBody2D

@export var freeze_color: Color

# Used to determine how far to move for each button press
var cell_size := 0

var stun_timer := 0

var new_pos: Vector2

# Used so the player can't walk when being attacked. It looked weird
var player_turn_delay := .0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play("idle")
	new_pos = position


func move(astar_grid: AStarGrid2D, target: Vector2):
	player_turn_delay = 0.0

	# Stunned! Decrease the timer and exit
	if stun_timer > 0:
		stun_timer -= 1
		modulate = freeze_color
		return
	modulate = Color.WHITE

	# TODO: Dividing and multiplying by cell_size works, but is odd
	# There's probably an astar API that takes cell size into account
	# This code moves the monster towards the player, using the pathfinding algorithm
	var path = astar_grid.get_id_path(position / cell_size, target / cell_size)
	if path.size() > 1: # index 0 is current position
		new_pos = path[1] * cell_size
		
		var dir = (new_pos-position).normalized()
		var tween: Tween
		if (new_pos == target):
			# Couldn't move; still attack
			new_pos = position
			attack(dir)
			player_turn_delay = 1.0
			return
		else:
			# Setup Animation
			tween = create_tween()
			set_up_animation(dir)
			tween.tween_property(self,"position",new_pos,0.2)

		if path.size() > 2:
			if (path[2] * cell_size) as Vector2 == target:
				var attackDir = (target - new_pos).normalized()
				tween.tween_callback(attack.bind(attackDir))
				tween.tween_callback(set_up_animation.bind(attackDir)).set_delay(1)
				player_turn_delay = 1.0
			

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
	
