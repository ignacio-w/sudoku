extends Node

const PAUSE_MENU = preload("uid://csufm8nmtlviw")

var puzzle: SudokuPuzzle
var move_history: Array ## Each element in this array represents an action by
## the player. Each action is an Array of cell information that was modified
## as a result of the action. The information gathered from each cell can be
## found in _snapshot_cells().
## EX: [[{"position": (0, 0), "prev_value": 0, "prev_notes": []}, ...], ...]
## The first element represents the first move, the second the second move, etc.

@onready var game_ui: GameUI = $GameUI


func _ready() -> void:
	GameEvents.undo_requested.connect(_on_undo_requested)
	GameEvents.hint_requested.connect(_on_hint_requested)
	GameEvents.erase_requested.connect(_on_erase_requested)
	
	puzzle = SudokuGenerator.new().generate(GameManager.cur_difficulty)
	await game_ui.setup(puzzle.player_board)
	game_ui.num_input_requested.connect(_on_num_input_request)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not puzzle.is_complete():
		add_child(PAUSE_MENU.instantiate())


## Places the specified number in the specified cell. Updates notes across
## the board and checks for board completion.
func _place_num(input_cell: Cell, num: int) -> void:
	var input_cell_pos = input_cell.board_pos
	
	# Get all cells affected by number placement. The cell itself + all cells
	# in potential conflict positions with notes containing num to place.
	var affected_positions: Array[Vector2i] = []
	affected_positions.append(input_cell_pos)
	for pos in SudokuRules.get_potential_conflict_positions(input_cell_pos):
		if num in puzzle.get_notes(pos):
			affected_positions.append(pos)
	
	# Before changing, add to move history
	move_history.append(_snapshot_cells(affected_positions))
	
	# Place number, display value, update buttons, update notes
	puzzle.set_value(input_cell_pos, num)
	input_cell.display_value(num)
	game_ui.update_number_buttons_active_state()
	for pos in affected_positions:
		if pos != input_cell_pos:
			puzzle.toggle_note(pos, num) # Remove note
			var note_cell: Cell = game_ui.board.cell_grid[pos.x][pos.y]
			note_cell.display_notes(puzzle.get_notes(pos)) # Update display
	
	# Update highlighting
	input_cell.cell_highlighted.emit(input_cell)
	
	# Check if the player has won
	if puzzle.is_complete():
		print("Board complete! Ending game...")
		game_ui.stopwatch.stop()
		await get_tree().create_timer(3).timeout
		get_tree().quit()


## Returns information about the cells at the specified positions in the form
## of an array of dictionaries. Each dictionary contains the cell's position,
## current value, and current notes at the time of the snapshot. This is intended
## to be used to keep track of move history which is why the entries are named
## "previous __".
func _snapshot_cells(positions: Array[Vector2i]) -> Array[Dictionary]:
	var snapshot: Array[Dictionary] = []
	for pos in positions:
		snapshot.append({
			"row": pos.x, "col": pos.y, # int, int
			"prev_value": puzzle.player_board[pos.x][pos.y], # int
			"prev_notes": puzzle.get_notes(pos).duplicate(), # Array[int]
		})
	return snapshot


## Handles number input requests from the GameUI. If the number can be
## placed, tells the UI to place the number.
func _on_num_input_request(cell: Cell, num_button: NumberButton, note_mode: bool) -> void:
	var cell_pos = cell.board_pos
	var num: int = num_button.value
	
	# If note mode is currently on, update SudokuPuzzle's notes, then tell
	# cell to display results.
	if note_mode:
		puzzle.toggle_note(cell_pos, num)
		cell.display_notes(puzzle.get_notes(cell_pos))
		return
	
	# NOTICE: Game currently validates inputs. 
	# Check if placement @ pos matches solution
	if puzzle.is_solution(cell_pos, num):
		_place_num(cell, num)
	else:
		# Add to mistakes
		puzzle.mistakes += 1
		game_ui.update_mistakes(puzzle.mistakes)
		# Animate number button
		num_button.animation_player.play("incorrect")
	
	print("Sent to Main for check!")


## Undoes number placements. 
## - If the last action was a placement, it undoes the placement and restores
## notes to their state before the placement (usually adds backs)
## - If the last action was an erasure, it places the number back and restores
## notes to their state before the erasure. (usually removes)
## NOTE: There is only something to undo if a number was placed/removed. This 
## does not undo note placements/removals.
func _on_undo_requested() -> void:
	# No history == nothing to undo
	if move_history.is_empty():
		return
	
	# Get most recent move then remove from move_history
	var move = move_history.pop_back()
	
	var undone_cell: Cell # Cell whose value is going to be undone
	for entry in move:
		var cell: Cell = game_ui.board.cell_grid[entry.row][entry.col]
		# Undone cell is cell whose value will change (Cur value != prev value)
		if puzzle.player_board[entry.row][entry.col] != entry.prev_value:
			undone_cell = cell
		# Place previous values/notes in cells affected by move
		puzzle.player_board[entry.row][entry.col] = entry.prev_value
		puzzle.notes_board[entry.row][entry.col] = entry.prev_notes
		# Update visuals
		cell.display_value(entry.prev_value)
		cell.display_notes(entry.prev_notes)
	
	# Focus undone cell; update UI buttons
	game_ui.board.focus_cell(undone_cell)
	game_ui.update_number_buttons_active_state()


## Gives a hint to the user. The focused cell is solved for the user. If
## there is no cell focused, it inputs the solution to the first available
## cell if any. If there are no empty cells, this does nothing.
func _on_hint_requested() -> void:
	# Try to give a hint on the focused cell. If not, on first empty cell.
	var target: Cell = game_ui.board.focused_cell
	if target == null or target.value != 0:
		target = _find_first_empty_cell()
		if target == null: return # No empty cells == can't give hint
	var row := target.board_pos.x
	var col := target.board_pos.y
	# Place solution on cell
	_place_num(target, puzzle.solution_board[row][col])
	

## Resets the value of the focused cell to zero. Notes are not brought back
## or changed in any way anywhere on the board.
func _on_erase_requested() -> void:
	var cell: Cell = game_ui.board.focused_cell
	# Check if cell is focused and can be erased
	if cell == null or cell.is_clue or cell.value == 0:
		return
	# Save cell state before erasure in case user wants to undo
	move_history.append(_snapshot_cells([cell.board_pos]))
	
	# Reset cell, delete notes
	puzzle.set_value(cell.board_pos, 0)
	cell.display_value(0)
	cell.display_notes([])
	game_ui.board.focus_cell(cell)
	game_ui.update_number_buttons_active_state()


## Returns the first empty cell on the board or null if there are no empty
## cells.
func _find_first_empty_cell() -> Cell:
	for row in range(9):
		for col in range(9):
			if puzzle.player_board[row][col] == 0:
				return game_ui.board.cell_grid[row][col]
	return null
