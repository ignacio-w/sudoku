extends Node

@onready var game_ui: GameUI = $GameUI
@onready var timer: Timer = $Timer

var game: Sudoku

func _ready() -> void:
	game = Sudoku.new()
	game.new_game()
	await game_ui.setup(game.player_board)
	GameEvents.cell_value_changed.connect(_on_cell_value_changed)
	game_ui.num_input_requested.connect(_on_num_input_request)


## Receives the cell_value_changed signal emitted by the GameEvents class.
## Whenever the value of a cell is changed, update the internal game board with
## that change then check if the player has finished.
func _on_cell_value_changed(cell: Cell):
	print("Cell value changed")
	var row: int = cell.board_pos.x
	var col: int = cell.board_pos.y
	# Update internal game board with new value
	game.player_board[row][col] = cell.value
	
	# Check if the player has won
	if game.player_board == game.solution_board:
		print("Board complete! Ending game...")
		get_tree().quit()
	pass


## Handles number input requests from the GameUI. If the number can be
## placed, tells the UI to place the number.
func _on_num_input_request(cell: Cell, num_button: NumberButton):
	var row: int = cell.board_pos.x
	var col: int = cell.board_pos.y
	var num: int = num_button.value
	
	# NOTICE: Game is currently validating inputs. 
	# Check if placement @ pos matches solution
	if game.is_solution(row, col, num):
		# Place number
		cell.set_value(num)
	else:
		# Add to mistakes
		game.strikes += 1
		game_ui.update_strikes(game.strikes)
		# Animate number button
		num_button.animation_player.play("incorrect")
	
	print("Sent to Main for check!")
