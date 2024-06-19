extends Node

const Constants = preload("res://core/Constants.gd")

@export var board : Node2D

# GOAP State variables
var current_actions = []
var goal = null
var king_location = null

# Define a structure for goals
enum GoalPriority {
	HIGH,
	MEDIUM,
	LOW
}

func make_ai_move():
	select_goal()
	
class Goal:
	var name: String
	var priority: GoalPriority
	var execute: Callable
	func _init(name: String, priority: GoalPriority, execute: Callable):
		self.name = name
		self.priority = priority
		self.execute = execute
# List of goals
var goals: Array = []
var threats: Array = []
var threatend: Array = []

func _ready():
	# Initialize goals
	goals.append(Goal.new("capture king", GoalPriority.HIGH, self.captureKing))
	goals.append(Goal.new("capture piece", GoalPriority.MEDIUM, self.capturePiece))
	goals.append(Goal.new("avoid capture", GoalPriority.MEDIUM, self.avoidCapture))
	goals.append(Goal.new("block king", GoalPriority.MEDIUM, self.blockKing))

func select_goal():
	# Sort goals by priority
	threats = evaluate_threats()
	if threats.size() > 0:
		goals[2].priority = GoalPriority.HIGH
	else:
		goals[2].priority = GoalPriority.LOW

	for child in board.get_children():
		if child is Sprite2D:
			if child.texture == Constants.match_piece_type(Constants.PieceType.KING):
				king_location = Vector2(child.row, child.col)
	for corner in Constants.CORNERS:
		var path = calculate_path(king_location,corner)
		if path.size() <= 2:
			goals[3].priority = GoalPriority.HIGH
			goals[0].priority = GoalPriority.LOW
			goals[1].priority = GoalPriority.LOW
			goals[2].priority = GoalPriority.LOW
		else:
			goals[3].priority = GoalPriority.LOW
			
	goals.sort_custom(self.compare_goals)
	
	# Execute the highest priority goal
	goals[0].execute.call()

func compare_goals(a: Goal, b: Goal) -> int:
	return int(a.priority) - int(b.priority)

func captureKing():
	var attacker_pieces = []
	
	for child in board.get_children():
		if child is Sprite2D:
			if child.texture == Constants.match_piece_type(Constants.PieceType.ATTACKER):
				attacker_pieces.append(child)
			elif child.texture == Constants.match_piece_type(Constants.PieceType.KING):
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
			if can_make_move(move):
				valid_moves.append({"piece": piece, "move": move})
	
	if valid_moves.size() > 0:
		
		var selected_move = validate_move(valid_moves,king_location)
		if selected_move:
			board.move_piece(selected_move["piece"], selected_move["move"])
			board.switch_turn()
			

func capturePiece():
	pass

func avoidCapture():
	var valid_moves = []
	for attacker in threatend:
		var possible_moves = [
			Vector2(attacker.row - 1, attacker.col),
			Vector2(attacker.row + 1, attacker.col),
			Vector2(attacker.row, attacker.col - 1),
			Vector2(attacker.row, attacker.col + 1)
		]
		for move in possible_moves:
			if can_make_move(move):
				valid_moves.append({"piece": attacker, "move": move})

	if valid_moves.size() > 0:
		for valid_move in valid_moves:
			if !check_underthreat(valid_move["move"]):
				board.move_piece(valid_move["piece"], valid_move["move"])
				board.switch_turn()
				return
				
		goals[2].priority = GoalPriority.LOW
		goals.sort_custom(self.compare_goals)
		goals[0].execute.call()
	
	goals[2].priority = GoalPriority.LOW
	goals.sort_custom(self.compare_goals)
	goals[0].execute.call()
	
func is_adjacent_to_king(piece_position, king_position):
	# Check if the piece is adjacent to the king
	var adjacent_positions = Constants.DIRECTIONS
	
	return piece_position in adjacent_positions

func can_make_move(move_position):
	# Check if the move position is valid (not on top of the king or on a corner)
	if move_position == king_location:
		return false
	
	if move_position in Constants.CORNERS:
		return false
	
	return board.can_move_to(move_position)

func validate_move(valid_moves,goalPos):
	var closest_move = null
	var closest_distance = INF
	
	for move in valid_moves:
		var move_position = move["move"]
		var distance_to_goal = calculate_manhattan_distance(move_position, goalPos)
		
		if distance_to_goal < closest_distance:
			closest_move = move
			closest_distance = distance_to_goal
	
	return closest_move

func calculate_manhattan_distance(position1, position2):
	return abs(position2.x - position1.x) + abs(position2.y - position1.y)

func blockKing():
	var attacker_pieces = []
	var closest_distance = INF
	var closest_corner = null
	var valid_moves = []
	for child in board.get_children():
		if child is Sprite2D:
			if child.texture == Constants.match_piece_type(Constants.PieceType.ATTACKER):
				attacker_pieces.append(child)
			elif child.texture == Constants.match_piece_type(Constants.PieceType.KING):
				king_location = Vector2(child.row, child.col)
	
	for corner in Constants.CORNERS:
		var distance_to_king = calculate_manhattan_distance(corner, king_location)
		
		if distance_to_king < closest_distance:
			closest_corner = corner
			closest_distance = distance_to_king
	
	var path = calculate_path(king_location,closest_corner )
	var goalPos = null
	for node in path:
		var defender = board.get_piece_at(node)
		if defender != null:
			path.pop_front()
		if node in Constants.CORNERS:
			path.pop_front()
		if node == king_location:
			path.pop_front()
			
	if path.size() > 0:	
		goalPos = path[0]

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
			if can_make_move(move):
				valid_moves.append({"piece": piece, "move": move})

	if valid_moves.size() > 0:
		var selected_move = validate_move(valid_moves,goalPos)
		if selected_move:
			board.move_piece(selected_move["piece"], selected_move["move"])
			board.switch_turn()
	

func calculate_path(start: Vector2, end: Vector2) -> Array:
	var open_set = []
	var came_from = {}
	var g_score = {}
	var f_score = {}
	var open_set_dict = {}

	for x in range(Constants.GRID_SIZE):
		for y in range(Constants.GRID_SIZE):
			var v = Vector2(x, y)
			g_score[v] = INF
			f_score[v] = INF

	g_score[start] = 0
	f_score[start] = heuristic_cost_estimate(start, end)
	open_set.append(start)
	open_set_dict[start] = true

	while open_set.size() > 0:
		open_set.sort_custom(func(a, b): return f_score[a] < f_score[b])
		var current = open_set.pop_front()
		open_set_dict.erase(current)

		if current == end:
			return reconstruct_path(came_from, current)

		for direction in Constants.DIRECTIONS:
			var neighbor = current + direction

			if !is_valid_position(neighbor):
				continue

			var tentative_g_score = g_score[current] + 1

			if tentative_g_score < g_score[neighbor]:
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g_score
				f_score[neighbor] = g_score[neighbor] + heuristic_cost_estimate(neighbor, end)

				if not open_set_dict.has(neighbor):
					open_set.append(neighbor)
					open_set_dict[neighbor] = true

	return []

func compare_f_score(a: Vector2, b: Vector2, f_score: Dictionary) -> int:
	return f_score[a] - f_score[b]

func heuristic_cost_estimate(start: Vector2, goal: Vector2) -> float:
	return start.distance_to(goal)

func is_valid_position(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < Constants.GRID_SIZE and pos.y >= 0 and pos.y < Constants.GRID_SIZE

func reconstruct_path(came_from: Dictionary, current: Vector2) -> Array:
	var total_path = [current]
	while came_from.has(current):
		current = came_from[current]
		total_path.insert(0,current)
		#total_path.prepend(current)
	return total_path

func evaluate_threats():
	var attacker_pieces = []
	var threats = []
	for child in board.get_children():
		if child is Sprite2D:
			if child.texture == Constants.match_piece_type(Constants.PieceType.ATTACKER):
				attacker_pieces.append(child)
			elif child.texture == Constants.match_piece_type(Constants.PieceType.KING):
				king_location = Vector2(child.row, child.col)
	
	for attacker in attacker_pieces:
		var gridpos = Vector2(attacker.row, attacker.col)
		var threat = check_underthreat(gridpos)
		if threat:
			threatend.append(attacker)
	
	return threats
	
func check_underthreat(grid_position):
	var row = grid_position.x
	var col = grid_position.y
	var neighbors = [Vector2(row - 1, col), Vector2(row + 1, col), Vector2(row, col - 1), Vector2(row, col + 1)]
	var enemies = []
	var threats = []
	
	for child in board.get_children():
		if child is Sprite2D:
			if child.texture == Constants.match_piece_type(Constants.PieceType.DEFENDER):
				enemies.append(child)
				
	for neighbor in neighbors:
		var piece = board.get_piece_at(neighbor)
		if piece != null and piece.texture == Constants.match_piece_type(Constants.PieceType.DEFENDER):
			if is_opposite_attacker_present(grid_position,neighbor,enemies, piece):
				threats.append(neighbor)
				return true

			
	
	return false

# Function to check if a position is within the 9x9 grid bounds
func is_within_bounds(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < Constants.GRID_SIZE and pos.y >= 0 and pos.y < Constants.GRID_SIZE
	
func is_opposite_attacker_present(defender: Vector2, attacker: Vector2, attackers: Array, piece) -> bool:
	var opposite_positions = [
		Vector2(8 - defender.x, 8 - defender.y),  # Direct opposite
	]
	var mainattack = Vector2(piece.row, piece.col)
	# Check each opposite position
	for opp_pos in opposite_positions:
		if opp_pos != mainattack:
			if is_within_bounds(opp_pos):
			# Check if the attacker can move to opp_pos in one move
				for dir in Constants.DIRECTIONS:
					var adjacent_pos = attacker + dir
					if adjacent_pos == opp_pos:
						return true

	return false
	
