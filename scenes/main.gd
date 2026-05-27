extends Node

@onready var game_ui: CanvasLayer = $GameUI

var game: Sodoku

func _ready() -> void:
	game = Sodoku.new()
	game.new_game()
	game_ui.reflect(game.num_board)
