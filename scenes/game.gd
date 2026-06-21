extends Node

@onready var game_ui: CanvasLayer = $GameUI

var game: Sudoku

func _ready() -> void:
	game = Sudoku.new()
	game.new_game()
	await game_ui.setup(game.num_board)
	GameEvents.cell_value_changed.connect(_on_cell_value_changed)
	game_ui.number_input.connect(_on_number_input)


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


## Validates and handles number inputs.
func _on_number_input(board_pos: Vector2i, num: int):
	# Check if number can be placed
	var row: int = board_pos.x
	var col: int = board_pos.y
	if game.num_board[row][col] != 0: return # Check if number can be inputted
	
	# Check if placement @ pos matches solution
	if game.is_solution(row, col, num):
		game.num_board[row][col] = num
	else:
		# Add to mistakes
		game_ui.increment_strikes()
	
	print("Sent to Main for check!")
	
