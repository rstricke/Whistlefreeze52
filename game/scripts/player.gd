extends CharacterBody2D

@export var MAX_SPEED := 300
@export var ACCELETARION := 1200.0
@export var FRICTION := 1000


var text1 = preload("res://assets/player/Player_WalkDown.png")
var text2 = preload("res://assets/player/Player_WalkUp.png")

func _physics_process(delta: float) -> void:

	var direction := Input.get_vector("move_left","move_right","move_up", "move_down")
	if direction != Vector2.ZERO:
		var tg_v = direction * MAX_SPEED
		velocity =velocity.move_toward(tg_v, ACCELETARION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)


	if direction.y >= 0:
		$Sprite2D.texture = text1
	else:
		$Sprite2D.texture = text2

	move_and_slide()
