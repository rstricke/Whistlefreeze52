extends Node
signal health_changed(current, max)

var hud: Control
var player: Player

@export var max_hp := 6
var hp := 0 #Current Hp

func damage(amount):
	hp -= amount
	hp = clamp(hp, 0, max_hp)
	health_changed.emit(hp,max_hp)
	
func heal(amount):
	hp += amount
	hp = clamp(hp, 0, max_hp)
	health_changed.emit(hp,max_hp)
