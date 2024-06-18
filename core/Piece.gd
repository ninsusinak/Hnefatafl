# Piece.gd
extends Sprite2D
# Import Constants.gd
const Constants = preload("res://core/Constants.gd")

@export var type : int
@export var row : int
@export var col : int

func _init(i_row: int, i_col: int, i_type: int):
	self.row = i_row
	self.col = i_col
	self.type = i_type
	self.texture = Constants.match_piece_type(self.type)
	self.position = Constants.cell_to_pixel(self.row, self.col)
