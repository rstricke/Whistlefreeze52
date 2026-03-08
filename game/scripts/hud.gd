extends Control

## Menus

@onready var game_menu: Control = $GameMenu


## HEARTS
@onready var hearts_container = $GameMenu/Hearts
@export var h_full: AtlasTexture
@export var h_half: AtlasTexture
@export var h_empty: AtlasTexture


@onready var whistle_bar: ProgressBar = $GameMenu/Sprite2D/Sprite2D/WhistleBar


func _ready() -> void:
	GameManager.hud = self
	

	create_hearts(GameManager.max_hp)
	# Signal Gamemanager
	
	GameManager.health_changed.connect(update_hearts)
	update_hearts(GameManager.hp, GameManager.max_hp)
	
	
func create_hearts(max_health):

	var heart_count = int(ceil(max_health / 2.0))

	for i in range(heart_count):
		var heart = TextureRect.new()
		heart.texture = h_empty
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP
		heart.custom_minimum_size = Vector2(80,80)
		hearts_container.add_child(heart)	
	
func update_hearts(health, max_health):
	var hearts = hearts_container.get_children()
	var n = hearts.size()
	for i in range(n):
		var value = i * 2
		if health >= value + 2:
			hearts[n-i-1].texture = h_full
		elif health == value + 1:
			hearts[n-i-1].texture = h_half
		else:
			hearts[n-i-1].texture = h_empty

func update_whistle(current, max_whistle):
	whistle_bar.value = current * 100 / max_whistle


func _on_exit_menu_pressed() -> void:
	get_tree().quit()
