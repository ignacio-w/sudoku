class_name BoardUI extends PanelContainer

@onready var sudoku_grid: GridContainer = %SudokuGrid

@export var board: Array[Array] # for testing only; 2D array of numbers

const CELL = preload("uid://dbdear076ofrm")
const SUB_GRID = preload("uid://csn5uij01jy01")
var cell_grid: Array[Array] # 2D Array of cell refrences
var focused_cell: Cell # The last cell currently highlighted and clicked on by user

func _ready() -> void:
	clear()


## Frees all board nodes.
func clear():
	for grid in sudoku_grid.get_children():
		grid.queue_free()


## Creates the board to be displayed on screen and connects cell signals to this
## node's functions. The sudoku board is a 2D array of numbers where each number
## represents what should be displayed on the board (0 = NOTHING; 1-9 = 1-9).
func create_visual_board(sudoku_board: Array[Array]) -> void:
	clear()
	focused_cell = null
	await get_tree().process_frame
	board = sudoku_board
	cell_grid = []
	# Create subgrids
	for grid_i in range(9):
		var new_subgrid = SUB_GRID.instantiate()
		sudoku_grid.add_child(new_subgrid)
	
	var subgrids := sudoku_grid.get_children()
	# Instantiate cells in subgrids
	for row in range(9):
		cell_grid.append([])
		cell_grid[row].resize(9)
		for col in range(9):
			var new_cell: Cell = CELL.instantiate() # Create cell
			cell_grid[row][col] = new_cell # Add cell to board variable
			var subgrid_index := get_subgrid_index(Vector2i(row, col))
			subgrids[subgrid_index].add_cell(new_cell) # Add cell to subgrid
			
			# Connect signals and set cell to its correct starting value
			new_cell.cell_selected.connect(_on_cell_selected)
			new_cell.cell_highlighted.connect(_on_cell_highlighted)
			new_cell.cell_cleared.connect(clear_highlights)
			new_cell.set_clue(sudoku_board[row][col], Vector2i(row, col))


## Takes a cell position ((0, 0) to (8, 8)) and returns the index of the subgrid
## the position is in from 0 to 8. 
func get_subgrid_index(pos: Vector2i) -> int:
	@warning_ignore("integer_division")
	return (pos.x / 3) * 3 + (pos.y / 3)


## Updates all cell states based on the current focused state.
func focus_cell(cell: Cell) -> void:
	cell.emit_clicked_signal(GameManager.validate_inputs, true)


## Receives the cell selected signal from board cells and updates all other cells as
## necessary.
func _on_cell_selected(selected_cell: Cell) -> void:
	print("Recieved signal from cell at ", str(selected_cell.board_pos))
	focused_cell = selected_cell
	var conflict_positions = SudokuRules.get_potential_conflict_positions(selected_cell.board_pos)
	
	# Highlight potential conflicts, and set all other cells to default
	if GameManager.visual_guides:
		for row in cell_grid:
			for cell: Cell in row:
				if cell == selected_cell:
					cell.set_state(Cell.CellState.SELECTED)
				elif cell.board_pos in conflict_positions and cell.value != 0:
					cell.set_state(Cell.CellState.CONFLICT_HIGHLIGHT)
				else:
					cell.set_state()
	else:
		for row in cell_grid:
			for cell: Cell in row:
				cell.set_state()
		selected_cell.set_state(Cell.CellState.SELECTED)


## Receives the cell highlighted signal from board cells and updates all other
## cells as necessary.
func _on_cell_highlighted(highlighted_cell: Cell) -> void:
	var num := highlighted_cell.value
	focused_cell = highlighted_cell
	
	# Highlight all identical numbers and cells with notes with equal value
	if GameManager.visual_guides:
		for row in cell_grid:
			for cell: Cell in row:
				if cell == highlighted_cell:
					cell.set_state(Cell.CellState.SELECTED)
				elif cell.value == num or num in cell.notes:
					cell.set_state(Cell.CellState.EQUAL_HIGHLIGHT)
				else:
					cell.set_state()
	else:
		for row in cell_grid:
			for cell: Cell in row:
				cell.set_state()
		highlighted_cell.set_state(Cell.CellState.EQUAL_HIGHLIGHT)


## Handles keyboard navigation of the board.
func _unhandled_key_input(event: InputEvent) -> void:
	if focused_cell == null or event.is_released(): return
	var row: int = focused_cell.board_pos.x
	var col: int = focused_cell.board_pos.y
	var new_row: int = row
	var new_col: int = col
	
	# Find next cell
	if event.is_action("ui_right"):
		if col < 8: new_col += 1
	if event.is_action("ui_left"):
		if col > 0: new_col -= 1
	if event.is_action("ui_down"):
		if row < 8: new_row += 1
	if event.is_action("ui_up"):
		if row > 0: new_row -= 1
	
	# If action results in new focused cell, focus cell and set input as handled
	if focused_cell.board_pos != Vector2i(new_row, new_col):
		(cell_grid[new_row][new_col] as Cell).emit_clicked_signal()
		get_viewport().set_input_as_handled()


## Resets the highlighting of all cells in the grid.
func clear_highlights() -> void:
	for row in cell_grid:
		for cell: Cell in row:
			cell.set_state()
	focused_cell = null
