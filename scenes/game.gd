extends Node

@onready var game_ui: GameUI = $GameUI

var game: Sudoku

func _ready() -> void:
	game = Sudoku.new(GameManager.cur_difficulty)
	#game.new_game()
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
		game_ui.stopwatch.stop()
		await get_tree().create_timer(3).timeout
		get_tree().quit()
	pass


## Handles number input requests from the GameUI. If the number can be
## placed, tells the UI to place the number.
func _on_num_input_request(cell: Cell, num_button: NumberButton, note_mode: bool) -> void:
	var row: int = cell.board_pos.x
	var col: int = cell.board_pos.y
	var num: int = num_button.value
	
	# If note mode is currently on, change the note instead of setting the value
	if note_mode:
		cell.toggle_note(num)
		return
	
	# NOTICE: Game currently validates inputs. 
	# Check if placement @ pos matches solution
	if game.is_solution(row, col, num):
		# Place number
		cell.set_value(num)
		
		# Delete notes of equal values
		var notes_positions = Sudoku.get_potential_conflict_positions(cell.board_pos)
		for pos in notes_positions:
			var note_cell: Cell = game_ui.board.cell_grid[pos.x][pos.y]
			if note_cell.notes.has(num):
				note_cell.toggle_note(num)
		
		# Highlight equal values
		cell.cell_highlighted.emit(cell)
	else:
		# Add to mistakes
		game.strikes += 1
		game_ui.update_strikes(game.strikes)
		# Animate number button
		num_button.animation_player.play("incorrect")
	
	print("Sent to Main for check!")
