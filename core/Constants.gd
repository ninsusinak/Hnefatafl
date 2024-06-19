extends Node2D

const GRID_SIZE = 9
const OFFSET = 32
const CELLSIZE = Vector2(64, 64)
const SCALE_FACTOR = 1.8  # Scaling factor applied to your board

enum PieceType {
	KING,
	ATTACKER,
	DEFENDER,
	THRONE
}

const KING_TEXTURE_PATH = preload("res://assets/king.png")
const ATTACKER_TEXTURE_PATH = preload("res://assets/attacker.png")
const DEFENDER_TEXTURE_PATH = preload("res://assets/defender.png")
const THRONE_TEXTURE_PATH = preload("res://assets/throne.png")

const DIRECTIONS = [
	Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1),
	Vector2(1, 1), Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1)
]

const CORNERS = [
	Vector2(0, 0),
	Vector2(0, 8),
	Vector2(8, 0),
	Vector2(8, 8)
]

const CENTER = Vector2(4, 4)

static func cell_to_pixel(irow: int, icol: int) -> Vector2:
	var ttexture = preload("res://assets/square.png")
	var texture_size = ttexture.get_size()
	return Vector2(icol * texture_size.x  + OFFSET, irow * texture_size.y  + OFFSET)

static func pixel_to_cell(iposition: Vector2) -> Vector2:
	var texture = preload("res://assets/square.png")
	var texture_size = texture.get_size()
	var col = int(iposition.x / (texture_size.x * SCALE_FACTOR))
	var row = int(iposition.y / (texture_size.y * SCALE_FACTOR))
	return Vector2(row, col)

static func match_piece_type(i_type: int) -> Texture:
	match i_type:
		PieceType.KING:
			return KING_TEXTURE_PATH
		PieceType.ATTACKER:
			return ATTACKER_TEXTURE_PATH
		PieceType.DEFENDER:
			return DEFENDER_TEXTURE_PATH
		PieceType.THRONE:
			return THRONE_TEXTURE_PATH
		_:
			return null
