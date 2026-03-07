extends Node2D

@onready var mat: ShaderMaterial = $Sprite2D.material

var time := 0.0
var duration := 0.6

func _process(delta):
	time += delta
	var p = time / duration

	mat.set_shader_parameter("progress", p)

	scale += Vector2.ONE * delta * 4.0

	if p >= 1.0:
		queue_free()
