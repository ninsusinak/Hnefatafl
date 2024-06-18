extends Node2D

# Import Constants.gd
const Constants = preload("res://core/Constants.gd")
const Piece = preload("res://core/Piece.gd")
const Victory = preload("res://core/VictoryScreen.gd")

@export var ai : Node

@onready var victory_screen = Victory.new()
@onready var sound_pick_player = AudioStreamPlayer.new()
@onready var sound_drop_player = AudioStreamPlayer.new()
@onready var background_music_player = AudioStreamPlayer.new()

var selected_piece = null
var original_piece_color = Color(1, 1, 1, 1)
var current_player = Constants.PieceType.DEFENDER

func _ready():
	create_grid()
	setup_board()
	set_window_size()
	add_child(sound_pick_player)
	add_child(sound_drop_player)
	add_child(background_music_player)
	sound_pick_player.stream = load("res://sounds/pick-92276.mp3")
	sound_drop_player.stream = load("res://sounds/plastic-wow-4-83016.mp3")
	background_music_player.stream = load("res://sounds/026311_quotmedievalquot-guitar-loop-70460.mp3")
	background_music_player.play()   
	victory_screen.load_victory_screen()
	victory_screen.load_defvictory_screen()

func setup_board():
	clear_board()
	create_grid()
	
	place_piece(4, 3, Constants.PieceType.DEFENDER)
	place_piece(4, 4, Constants.PieceType.KING)
	place_piece(3, 4, Constants.PieceType.DEFENDER)
	place_piece(3, 3, Constants.PieceType.DEFENDER)
	place_piece(5, 5, Constants.PieceType.DEFENDER)
	place_piece(5, 3, Constants.PieceType.DEFENDER)
	place_piece(3, 5, Constants.PieceType.DEFENDER)
	place_piece(5, 4, Constants.PieceType.DEFENDER)
	place_piece(4, 5, Constants.PieceType.DEFENDER)
	place_piece(0, 3, Constants.PieceType.ATTACKER)
	place_piece(0, 4, Constants.PieceType.ATTACKER)
	place_piece(0, 5, Constants.PieceType.ATTACKER)
	place_piece(1, 4, Constants.PieceType.ATTACKER)
	place_piece(8, 3, Constants.PieceType.ATTACKER)
	place_piece(8, 4, Constants.PieceType.ATTACKER)
	place_piece(8, 5, Constants.PieceType.ATTACKER)
	place_piece(7, 4, Constants.PieceType.ATTACKER)
	place_piece(3, 0, Constants.PieceType.ATTACKER)
	place_piece(4, 0, Constants.PieceType.ATTACKER)
	place_piece(5, 0, Constants.PieceType.ATTACKER)
	place_piece(4, 1, Constants.PieceType.ATTACKER)
	place_piece(3, 8, Constants.PieceType.ATTACKER)
	place_piece(4, 8, Constants.PieceType.ATTACKER)
	place_piece(5, 8, Constants.PieceType.ATTACKER)
	place_piece(4, 7, Constants.PieceType.ATTACKER)

func place_piece(row, col, type):
	var piece_sprite = Piece.new(row, col, type)
	add_child(piece_sprite)

func move_piece(piece, grid_position):
	var cell_center = Constants.cell_to_pixel(grid_position.x, grid_position.y)
	var target_piece = get_piece_at(grid_position)
	if target_piece == null:
		piece.position = cell_center
		piece.row = grid_position.x
		piece.col = grid_position.y
		check_captures_around(grid_position)
		check_king_in_corner(grid_position, piece)

func get_piece_at(grid_position):
	for child in get_children():
		if child is Sprite2D and (child.texture == Constants.match_piece_type(Constants.PieceType.DEFENDER) or child.texture == Constants.match_piece_type(Constants.PieceType.ATTACKER) ):
			if child.row == grid_position.x and child.col == grid_position.y:
				return child
	return null

func clear_board():
	for child in get_children():
		if child is Sprite2D:
			if child.texture != null:
				child.queue_free()

func create_grid():
	var texture = preload("res://assets/square.png")
	var texture_size = texture.get_size()
	for row in range(Constants.GRID_SIZE):
		for col in range(Constants.GRID_SIZE):
			var cell_sprite = Sprite2D.new()
			cell_sprite.texture = texture
			cell_sprite.position = Vector2(col * texture_size.x + Constants.OFFSET, row * texture_size.y + Constants.OFFSET)
			add_child(cell_sprite)

	var corner_positions = Constants.CORNERS

	for pos in corner_positions:
		var corner_sprite = Sprite2D.new()
		corner_sprite.texture = preload("res://assets/corner.png")
		corner_sprite.position = Vector2(pos.x * texture_size.x + Constants.OFFSET, pos.y * texture_size.y + Constants.OFFSET)
		add_child(corner_sprite)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var cell_position = get_global_mouse_position()
		var grid_position = Constants.pixel_to_cell(cell_position)
		if selected_piece == null:
			selected_piece = get_piece_at(grid_position)
			if selected_piece and can_move_piece(selected_piece):
				original_piece_color = selected_piece.modulate
				selected_piece.modulate = Color(0.5, 0.5, 1, 1)
				sound_pick_player.play()
			else:
				selected_piece = null
		elif selected_piece and can_move_piece(selected_piece):
			if can_move_to(grid_position):
				move_piece(selected_piece, grid_position)
				selected_piece.modulate = original_piece_color
				selected_piece = null
				sound_drop_player.play()
				switch_turn()

func can_move_piece(piece):
	return piece.texture == Constants.match_piece_type(current_player) or (current_player == Constants.PieceType.DEFENDER and piece.texture == Constants.match_piece_type(Constants.PieceType.KING))

func can_move_to(grid_position):
	if grid_position.x < 0 or grid_position.x >= Constants.GRID_SIZE or grid_position.y < 0 or grid_position.y >= Constants.GRID_SIZE:
		return false

	var target_piece = get_piece_at(grid_position)
	if target_piece != null:
		return false

	if selected_piece != null:
		var piece_row = selected_piece.row
		var piece_col = selected_piece.col
		var distance = abs(grid_position.x - piece_row) + abs(grid_position.y - piece_col)
		if distance != 1:
			return false

	if current_player == Constants.PieceType.ATTACKER and grid_position in Constants.CORNERS:
		return false
	
	if selected_piece != null:
		if grid_position == Constants.CENTER and selected_piece.texture != Constants.match_piece_type(Constants.PieceType.KING):
			return false

	return true

func switch_turn():
	if current_player == Constants.PieceType.ATTACKER:
		current_player = Constants.PieceType.DEFENDER
	else:
		current_player = Constants.PieceType.ATTACKER
		ai.make_ai_move()

func check_captures_around(grid_position):
	var row = grid_position.x
	var col = grid_position.y
	var neighbors = [Vector2(row - 1, col), Vector2(row + 1, col), Vector2(row, col - 1), Vector2(row, col + 1)]

	for neighbor in neighbors:
		check_capture(neighbor)

func check_capture(grid_position):
	var row = grid_position.x
	var col = grid_position.y

	var piece = get_piece_at(grid_position)
	if piece == null:
		return

	var up = Vector2(row - 1, col)
	var down = Vector2(row + 1, col)
	var left = Vector2(row, col - 1)
	var right = Vector2(row, col + 1)

	if piece.texture == Constants.match_piece_type(Constants.PieceType.ATTACKER):
		if (is_defender_at(up) and is_defender_at(down)) or (is_defender_at(left) and is_defender_at(right)):
			remove_piece(piece)
	elif piece.texture == Constants.match_piece_type(Constants.PieceType.DEFENDER):
		if (is_attacker_at(up) and is_attacker_at(down)) or (is_attacker_at(left) and is_attacker_at(right)):
			remove_piece(piece)

	check_king_surrounded(grid_position)

func is_defender_at(grid_position):
	var piece = get_piece_at(grid_position)
	return piece != null and piece.texture == Constants.match_piece_type(Constants.PieceType.DEFENDER)

func is_attacker_at(grid_position):
	var piece = get_piece_at(grid_position)
	return piece != null and piece.texture == Constants.match_piece_type(Constants.PieceType.ATTACKER)

func remove_piece(piece):
	piece.queue_free()

func check_king_surrounded(grid_position):
	var row = grid_position.x
	var col = grid_position.y

	var up = Vector2(row - 1, col)
	var down = Vector2(row + 1, col)
	var left = Vector2(row, col - 1)
	var right = Vector2(row, col + 1)

	if is_attacker_at(up) and is_attacker_at(down) and is_attacker_at(left) and is_attacker_at(right):
		victory_screen.show_victory_screen()

func check_king_in_corner(grid_position, piece):
	if piece.texture == Constants.match_piece_type(Constants.PieceType.KING) and grid_position in Constants.CORNERS:
		victory_screen.show_defvictory_screen()

func set_window_size():
	var texture = preload("res://assets/square.png")
	var texture_size = texture.get_size()
	var window_size = Vector2(texture_size.x * Constants.GRID_SIZE, texture_size.y * Constants.GRID_SIZE)
	get_viewport().set_size(window_size)
