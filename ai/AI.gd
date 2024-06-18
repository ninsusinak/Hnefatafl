extends Node
const Constants = preload("res://core/Constants.gd")
@export var board : Node2D

func make_ai_move():
	var attacker_pieces = []
	for child in board.get_children():
		if child is Sprite2D and child.texture == Constants.match_piece_type(Constants.PieceType.ATTACKER):
			attacker_pieces.append(child)

	var valid_moves = []
	for piece in attacker_pieces:
		var piece_row = piece.row
		var piece_col = piece.col
		var possible_moves = [
			Vector2(piece_row - 1, piece_col),
			Vector2(piece_row + 1, piece_col),
			Vector2(piece_row, piece_col - 1),
			Vector2(piece_row, piece_col + 1)
		]

		for move in possible_moves:
			if board.can_move_to(move):
				valid_moves.append({"piece": piece, "move": move})

	if valid_moves.size() > 0:
		var selected_move = valid_moves[randi() % valid_moves.size()]
		board.move_piece(selected_move["piece"], selected_move["move"])
		board.switch_turn()
