extends Node
const Constants = preload("res://core/Constants.gd")

var victory_screen = null
var defvictory_screen = null

@onready var victory_music_player = AudioStreamPlayer.new()

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
	add_child(victory_music_player)
	victory_music_player.stream = load("res://sounds/075747_inception-horn-victory-82997.mp3")
	victory_music_player.play()

func show_defvictory_screen():
	defvictory_screen.visible = true
	get_tree().paused = true
	add_child(victory_music_player)
	victory_music_player.stream = load("res://sounds/075747_inception-horn-victory-82997.mp3")
	victory_music_player.play()
