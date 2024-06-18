extends Control

@onready var board = $Board
@onready var ai = $AI
@onready var victory_screen = $VictoryScreen
@onready var background = $Background

func _ready():
	board.ai = ai
	board.victory_screen = victory_screen
	var screen_size = get_viewport_rect().size
	var scale_factor = Vector2(screen_size.x, screen_size.y)
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.set_size(scale_factor)

func scale_sprites():
	var screen_size = get_viewport_rect().size
	var base_size = Vector2(1080, 1920) # Assuming 1080x1920 is your base resolution

	var scale_factor = min(screen_size.x / base_size.x, screen_size.y / base_size.y)

	for sprite in board.get_children():
		if sprite is Sprite2D:
			sprite.scale = Vector2(scale_factor, scale_factor)
