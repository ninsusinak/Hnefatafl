extends Node2D

const GRID_SIZE = 9
const OFFSET = 32

enum PieceType {
	KING,
	ATTACKER,
	DEFENDER,
	THRONE
}
const KING_TEXTURE_PATH =  preload("res://assets/king.png")
const ATTACKER_TEXTURE_PATH =  preload("res://assets/attacker.png")
const DEFENDER_TEXTURE_PATH =  preload("res://assets/defender.png")
const THRONE_TEXTURE_PATH =  preload("res://assets/throne.png")
var selected_piece = null
var original_piece_color = Color(1, 1, 1, 1)
var victory_screen = null
var defvictory_screen = null
var current_player = PieceType.DEFENDER # Start with defenders

@onready var sound_pick = $pick
@onready var sound_drop = $drop
@onready var sound_victory = $victory

var corners = [
	Vector2(0, 0),
	Vector2(0, 8),
	Vector2(8, 0),
	Vector2(8, 8)
]

var center = Vector2(4, 4)

func load_victory_screen():
	var victory_screen_scene = preload("res://VictoryScreen.tscn")
	victory_screen = victory_screen_scene.instantiate()
	victory_screen.visible = false
	add_child(victory_screen)
	
func load_defvictory_screen():
	var defvictory_screen_scene = preload("res://defendervictory.tscn")
	defvictory_screen = defvictory_screen_scene.instantiate()
	defvictory_screen.visible = false
	add_child(defvictory_screen)
	
func show_victory_screen():
	victory_screen.visible = true
	get_tree().paused = true
	sound_victory.play()

func show_defvictory_screen():
	defvictory_screen.visible = true
	get_tree().paused = true
	sound_victory.play()
	
func _ready():
	create_grid()
	setup_board()
	set_window_size()
	load_victory_screen()
	load_defvictory_screen()

func setup_board():
	# Clear board of any existing pieces
	clear_board()
	create_grid()
	
	#setup throne
	#place_piece(4, 4, PieceType.THRONE)
	
	# Set up attackers
	place_piece(4, 3, PieceType.DEFENDER)
	place_piece(4, 4, PieceType.KING)
	place_piece(3, 4, PieceType.DEFENDER)
	place_piece(3, 3, PieceType.DEFENDER)
	place_piece(5, 5, PieceType.DEFENDER)
	place_piece(5, 3, PieceType.DEFENDER)
	place_piece(3, 5, PieceType.DEFENDER)
	place_piece(5, 4, PieceType.DEFENDER)
	place_piece(4, 5, PieceType.DEFENDER)

	# Set up defenders
	place_piece(0, 3, PieceType.ATTACKER)
	place_piece(0, 4, PieceType.ATTACKER)
	place_piece(0, 5, PieceType.ATTACKER)
	place_piece(1, 4, PieceType.ATTACKER)
	place_piece(8, 3, PieceType.ATTACKER)
	place_piece(8, 4, PieceType.ATTACKER)
	place_piece(8, 5, PieceType.ATTACKER)
	place_piece(7, 4, PieceType.ATTACKER)
	place_piece(3, 0, PieceType.ATTACKER)
	place_piece(4, 0, PieceType.ATTACKER)
	place_piece(5, 0, PieceType.ATTACKER)
	place_piece(4, 1, PieceType.ATTACKER)
	place_piece(3, 8, PieceType.ATTACKER)
	place_piece(4, 8, PieceType.ATTACKER)
	place_piece(5, 8, PieceType.ATTACKER)
	place_piece(4, 7, PieceType.ATTACKER)
	

func match_piece_type(type):
	match type:
		PieceType.KING:
			return KING_TEXTURE_PATH
		PieceType.ATTACKER:
			return ATTACKER_TEXTURE_PATH
		PieceType.DEFENDER:
			return DEFENDER_TEXTURE_PATH
		PieceType.THRONE:
			return THRONE_TEXTURE_PATH
			
				
func cell_to_pixel(row, col):
	var texture = preload("res://assets/square.png")
	var texture_size = texture.get_size()
	return Vector2(col * texture_size.x + OFFSET, row * texture_size.y + OFFSET)

func pixel_to_cell(position):
	var texture = preload("res://assets/square.png")
	var texture_size = texture.get_size()
	var col = int(position.x / texture_size.x)
	var row = int(position.y / texture_size.y)
	return Vector2(row, col)	
	

	
func clear_board():
	for child in get_children():
		if child is Sprite2D:
			if child.texture != null: # Skip grid squares
				child.queue_free()


func create_grid():
	var texture = preload("res://assets/square.png") # Load the texture
	var texture_size = texture.get_size()
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var cell_sprite = Sprite2D.new()
			cell_sprite.texture = texture
			cell_sprite.position = Vector2(col * texture_size.x + OFFSET , row * texture_size.y + OFFSET)
			add_child(cell_sprite)
			
	# Add icon sprite on top of throne square
	var throne_row = GRID_SIZE / 2
	var throne_col = GRID_SIZE / 2
	
	var corner_sprite1 = Sprite2D.new()
	corner_sprite1.texture = preload("res://assets/corner.png") # Load the icon texture
	corner_sprite1.position = Vector2(0 * texture_size.x + OFFSET, 0 * texture_size.y + OFFSET)
	add_child(corner_sprite1)
	
	var corner_sprite2 = Sprite2D.new()
	corner_sprite2.texture = preload("res://assets/corner.png") # Load the icon texture
	corner_sprite2.position = Vector2(8 * texture_size.x + OFFSET, 0 * texture_size.y + OFFSET)
	add_child(corner_sprite2)
	
	var corner_sprite3 = Sprite2D.new()
	corner_sprite3.texture = preload("res://assets/corner.png") # Load the icon texture
	corner_sprite3.position = Vector2(0 * texture_size.x + OFFSET, 8 * texture_size.y + OFFSET)
	add_child(corner_sprite3)
	
	var corner_sprite4 = Sprite2D.new()
	corner_sprite4.texture = preload("res://assets/corner.png") # Load the icon texture
	corner_sprite4.position = Vector2(8 * texture_size.x + OFFSET, 8 * texture_size.y + OFFSET)
	add_child(corner_sprite4)
	
func _on_piece_input(viewport, event, row, col):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected_piece = viewport
		event.handled = true

func move_piece(piece, grid_position):
	var cell_center = cell_to_pixel(grid_position.x, grid_position.y)
	var target_piece = get_piece_at(grid_position)
	if target_piece == null:
		piece.position = cell_center	
		piece.set_meta("row", grid_position.x)
		piece.set_meta("col", grid_position.y)
		check_captures_around(grid_position)
		check_king_in_corner(grid_position, piece)

func check_king_in_corner(grid_position, piece):
	if piece.texture == match_piece_type(PieceType.KING) and grid_position in corners:
		show_defvictory_screen()

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

	if piece.texture == match_piece_type(PieceType.ATTACKER):
		if (is_defender_at(up) and is_defender_at(down)) or (is_defender_at(left) and is_defender_at(right)):
			remove_piece(piece)
	elif piece.texture == match_piece_type(PieceType.DEFENDER):
		if (is_attacker_at(up) and is_attacker_at(down)) or (is_attacker_at(left) and is_attacker_at(right)):
			remove_piece(piece)

	check_king_surrounded(grid_position)

func is_defender_at(grid_position):
	var piece = get_piece_at(grid_position)
	return piece != null and piece.texture == match_piece_type(PieceType.DEFENDER)

func is_attacker_at(grid_position):
	var piece = get_piece_at(grid_position)
	return piece != null and piece.texture == match_piece_type(PieceType.ATTACKER) 

func remove_piece(piece):
	piece.queue_free()
	
func place_piece(row, col, type):
	var piece_sprite = Sprite2D.new()
	piece_sprite.texture = match_piece_type(type)
	piece_sprite.position = cell_to_pixel(row, col)
	piece_sprite.set_meta("row", row)
	piece_sprite.set_meta("col", col)
	add_child(piece_sprite)
	
func get_piece_at(grid_position):
	for child in get_children():
		if child.has_meta("row") and child.has_meta("col"):
			var row = child.get_meta("row")
			var col = child.get_meta("col")
			if row == grid_position.x and col == grid_position.y:
				return child
	return null
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var cell_position = get_global_mouse_position()
		var grid_position = pixel_to_cell(cell_position)
		if selected_piece == null:
			selected_piece = get_piece_at(grid_position)
			if selected_piece and can_move_piece(selected_piece):
				original_piece_color = selected_piece.modulate
				selected_piece.modulate = Color(0.5, 0.5, 1, 1) # Change color to highlight
				sound_pick.play()
			else:
				selected_piece = null
		elif selected_piece and can_move_piece(selected_piece):
			if can_move_to(grid_position):
				move_piece(selected_piece, grid_position)
				selected_piece.modulate = original_piece_color # Restore original color
				selected_piece = null
				sound_drop.play()
				switch_turn()

func can_move_piece(piece):
	return piece.texture == match_piece_type(current_player) or (current_player == PieceType.DEFENDER and piece.texture == match_piece_type(PieceType.KING))

func can_move_to(grid_position):
	if grid_position.x < 0 or grid_position.x >= GRID_SIZE or grid_position.y < 0 or grid_position.y >= GRID_SIZE:
		return false

	var target_piece = get_piece_at(grid_position)
	if target_piece != null:
		return false
		
	if 	selected_piece  != null:
		var piece_row = selected_piece.get_meta("row")
		var piece_col = selected_piece.get_meta("col")
		var distance = abs(grid_position.x - piece_row) + abs(grid_position.y - piece_col)
		if distance != 1:
			return false

	# Prevent attackers from moving into corners
	if current_player == PieceType.ATTACKER and grid_position in corners:
		return false

	# Prevent anyone but the king from moving into the center
	if grid_position == center and selected_piece.texture != match_piece_type(PieceType.KING):
		return false

	return true
	
func switch_turn():
	if current_player == PieceType.ATTACKER:
		current_player = PieceType.DEFENDER
	else:
		current_player = PieceType.ATTACKER		
		make_ai_move()  # Call the AI function when it's the attacker's turn

func check_king_surrounded(grid_position):
	var row = grid_position.x
	var col = grid_position.y

	var up = Vector2(row - 1, col)
	var down = Vector2(row + 1, col)
	var left = Vector2(row, col - 1)
	var right = Vector2(row, col + 1)

	if is_attacker_at(up) and is_attacker_at(down) and is_attacker_at(left) and is_attacker_at(right):
		show_victory_screen()
		
func set_window_size():
	var texture = preload("res://assets/square.png") # Load the texture
	var texture_size = texture.get_size()
	var window_size = Vector2(texture_size.x * GRID_SIZE, texture_size.y * GRID_SIZE)
	get_viewport().set_size(window_size)

# AI function to make a move for the attackers
func make_ai_move():
	var attacker_pieces = []
	for child in get_children():
		if child is Sprite2D:
			if child.has_meta("row") and child.has_meta("col"):
				if child.texture == match_piece_type(PieceType.ATTACKER):
					attacker_pieces.append(child)

	var valid_moves = []

	for piece in attacker_pieces:
		var piece_row = piece.get_meta("row")
		var piece_col = piece.get_meta("col")
		var possible_moves = [
			Vector2(piece_row - 1, piece_col),
			Vector2(piece_row + 1, piece_col),
			Vector2(piece_row, piece_col - 1),
			Vector2(piece_row, piece_col + 1)
		]

		for move in possible_moves:
			if can_move_to(move):
				valid_moves.append({"piece": piece, "move": move})

	if valid_moves.size() > 0:
		var selected_move = valid_moves[randi() % valid_moves.size()]
		move_piece(selected_move["piece"], selected_move["move"])
		sound_drop.play()
		switch_turn()
