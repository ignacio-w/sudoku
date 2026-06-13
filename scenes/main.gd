extends Node

@onready var game_ui: CanvasLayer = $GameUI

var game: Sodoku

func _ready() -> void:
	game = Sodoku.new()
	game.new_game()
	await game_ui.setup(game.num_board)
	GameEvents.cell_value_changed.connect(_on_cell_value_changed)


## Receives the cell_value_changed signal emitted by the GameEvents class.
func _on_cell_value_changed(cell: Cell):
	print("Cell value changed")
	var row: int = cell.board_pos.x
	var col: int = cell.board_pos.y
	# Update internal game board with new value
	game.num_board[row][col] = cell.value
	
	# Check if the player has won
	if game.num_board == game.solution_board:
		print("Board complete! Ending game...")
		get_tree().quit()
	pass
