extends Node

@onready var game_ui: GameUI = $GameUI

var puzzle: SudokuPuzzle

func _ready() -> void:
	puzzle = SudokuGenerator.new().generate(GameManager.cur_difficulty)
	await game_ui.setup(puzzle.player_board)
	#GameEvents.cell_value_changed.connect(_on_cell_value_changed)
	game_ui.num_input_requested.connect(_on_num_input_request)


## Handles number input requests from the GameUI. If the number can be
## placed, tells the UI to place the number.
func _on_num_input_request(cell: Cell, num_button: NumberButton, note_mode: bool) -> void:
	var row: int = cell.board_pos.x
	var col: int = cell.board_pos.y
	var num: int = num_button.value
	
	# If note mode is currently on, update SudokuPuzzle's notes, then tell
	# cell to display results.
	if note_mode:
		puzzle.toggle_note(row, col, num)
		cell.display_notes(puzzle.get_notes(row, col))
		return
	
	# NOTICE: Game currently validates inputs. 
	# Check if placement @ pos matches solution
	if puzzle.is_solution(row, col, num):
		# Place number; display value
		puzzle.set_value(row, col, num)
		cell.display_value(num)
		
		# Delete notes of equal values
		var notes_positions = SudokuRules.get_potential_conflict_positions(cell.board_pos)
		for pos in notes_positions:
			var note_cell: Cell = game_ui.board.cell_grid[pos.x][pos.y]
			if num in puzzle.get_notes(pos.x, pos.y):
				puzzle.toggle_note(pos.x, pos.y, num)
				note_cell.display_notes(puzzle.get_notes(pos.x, pos.y))
		
		# Highlight equal values
		cell.cell_highlighted.emit(cell)
		
		# Check if the player has won
		if puzzle.is_complete():
			print("Board complete! Ending game...")
			game_ui.stopwatch.stop()
			await get_tree().create_timer(3).timeout
			get_tree().quit()
	else:
		# Add to mistakes
		puzzle.mistakes += 1
		game_ui.update_mistakes(puzzle.mistakes)
		# Animate number button
		num_button.animation_player.play("incorrect")
	
	print("Sent to Main for check!")
