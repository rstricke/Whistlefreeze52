extends Node
signal health_changed(current, max)

var hud: Control
var player: Player

@export var max_hp := 6
var hp := 0 #Current Hp


func die():
	get_tree().change_scene_to_file("res://death.tscn")


func damage(amount):
	hp -= amount
	hp = clamp(hp, 0, max_hp)
	health_changed.emit(hp,max_hp)
	if hp <= 0:
		die()
	
func heal(amount):
	hp += amount
	hp = clamp(hp, 0, max_hp)
	health_changed.emit(hp,max_hp)
	
func update_whistle(current, max_whistle):
	hud.update_whistle(current, max_whistle)
