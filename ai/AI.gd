extends Node

const Constants = preload("res://core/Constants.gd")

@export var board : Node2D

# GOAP State variables
var current_actions = []
var goal = null
var king_location = null

func make_ai_move():
	# Clear current actions and goal
	current_actions.clear()
	goal = null
	
	var attacker_pieces = []
	var king_piece = null
	
	for child in board.get_children():
		if child is Sprite2D:
			if child.texture == Constants.match_piece_type(Constants.PieceType.ATTACKER):
				attacker_pieces.append(child)
			elif child.texture == Constants.match_piece_type(Constants.PieceType.KING):
				king_piece = child
				king_location = Vector2(child.row, child.col)
	
	var valid_moves = []
	
	for piece in attacker_pieces:
		var piece_row = piece.row
		var piece_col = piece.col
		var piece_position = Vector2(piece_row, piece_col)
		
		# Check if the piece is adjacent to the king
		if is_adjacent_to_king(piece_position, king_location):
			continue
		
		var possible_moves = [
			Vector2(piece_row - 1, piece_col),
			Vector2(piece_row + 1, piece_col),
			Vector2(piece_row, piece_col - 1),
			Vector2(piece_row, piece_col + 1)
		]
	
		for move in possible_moves:
			if can_make_move(move, king_location):
				valid_moves.append({"piece": piece, "move": move})
	
	if valid_moves.size() > 0:
		var selected_move = validate_move(valid_moves)
		if selected_move:
			board.move_piece(selected_move["piece"], selected_move["move"])
			board.switch_turn()

func is_adjacent_to_king(piece_position, king_position):
	# Check if the piece is adjacent to the king
	var adjacent_positions = [
		Vector2(king_position.x - 1, king_position.y),
		Vector2(king_position.x + 1, king_position.y),
		Vector2(king_position.x, king_position.y - 1),
		Vector2(king_position.x, king_position.y + 1)
	]
	
	return piece_position in adjacent_positions

func can_make_move(move_position, king_position):
	# Check if the move position is valid (not on top of the king or on a corner)
	if move_position == king_position:
		return false
	
	if move_position in Constants.CORNERS:
		return false
	
	return board.can_move_to(move_position)

func validate_move(valid_moves):
	var closest_move = null
	var closest_distance = INF
	
	for move in valid_moves:
		var move_position = move["move"]
		var distance_to_king = calculate_manhattan_distance(move_position, king_location)
		
		if distance_to_king < closest_distance:
			closest_move = move
			closest_distance = distance_to_king
	
	return closest_move

func calculate_manhattan_distance(position1, position2):
	return abs(position2.x - position1.x) + abs(position2.y - position1.y)
