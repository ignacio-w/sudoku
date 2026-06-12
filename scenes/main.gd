extends Node

@onready var game_ui: CanvasLayer = $GameUI

var game: Sodoku

func _ready() -> void:
	game = Sodoku.new()
	game.new_game()
	await game_ui.setup(game.num_board)


func _on_cell_value_changed():
	# Update internal game board
	
	# Check if the player has won
	pass
