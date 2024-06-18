extends Node2D

@onready var board = $Board
@onready var ai = $AI
@onready var victory_screen = $VictoryScreen

func _ready():
	board.ai = ai
	board.victory_screen = victory_screen
