extends MarginContainer

@onready var sodoku_grid: GridContainer = %SodokuGrid

@export var board: Array[Array] # for testing only

const CELL = preload("uid://dbdear076ofrm")
const SUB_GRID = preload("uid://csn5uij01jy01")
var cell_grid: Array[Array]

func _ready() -> void:
	pass


func clear():
	for grid in sodoku_grid.get_children():
		grid.queue_free()
	


# Creates the board to be displayed on screen. The sodoku board is a 2D array of numbers where
# each number represents what should be displayed on the board. 0 = NOTHING, 1-9 = 1-9
func create_visual_board(sodoku_board: Array[Array]):
	clear()
	await get_tree().process_frame
	board = sodoku_board
	cell_grid = []
	# Create subgrids
	for grid_i in range(9):
		var new_subgrid = SUB_GRID.instantiate()
		sodoku_grid.add_child(new_subgrid)
	
	var subgrids := sodoku_grid.get_children()
	# Instantiate cells in subgrids
	for row in range(9):
		cell_grid.append([])
		cell_grid[row].resize(9)
		for col in range(9):
			var new_cell: Cell = CELL.instantiate() # Create celll
			cell_grid[row][col] = new_cell # Add cell to board variable
			var subgrid_index := get_subgrid_index(Vector2i(row, col))
			subgrids[subgrid_index].add_cell(new_cell) # Add cell to subgrid
			
			# Connect signals and set cell to its correct starting value
			new_cell.cell_selected.connect(_on_cell_selected)
			new_cell.cell_highlighted.connect(_on_cell_highlighted)
			new_cell.reset_highlight.connect(clear_highlights)
			new_cell.set_clue(sodoku_board[row][col], Vector2i(row, col))



func get_subgrid_index(pos: Vector2i) -> int:
	@warning_ignore("integer_division")
	return (pos.x / 3) * 3 + (pos.y / 3)


func _on_cell_selected(selected_cell: Cell):
	print("Recieved signal from cell at ", str(selected_cell.board_pos))
	var conflict_positions = Sodoku.get_potential_conflict_positions(selected_cell.board_pos)
	
	# Highlight potential conflicts, and set all other cells to default
	for row in cell_grid:
		for cell in row:
			assert(cell is Cell) # for debugging purposes
			if cell == selected_cell:
				(cell as Cell).set_state(Cell.CellState.SELECTED)
			elif (cell as Cell).board_pos in conflict_positions and (cell as Cell).value != 0:
				(cell as Cell).set_state(Cell.CellState.CONFLICT_HIGHLIGHT)
			else:
				cell.set_state()


func _on_cell_highlighted(selected_cell: Cell):
	var num := selected_cell.value
	# Get idential numbers
	for row in cell_grid:
		for cell in row:
			assert(cell is Cell)
			if (cell as Cell).value == num:
				(cell as Cell).set_state(Cell.CellState.NUM_HIGHLIGHT)
			else:
				cell.set_state()


func clear_highlights():
	for row in cell_grid:
		for cell in row:
			assert(cell is Cell)
			(cell as Cell).set_state()
