class_name SudokuRules extends RefCounted


## Returns an array of all cells that need to be checked in order to determine
## potential conflicts with the value of the cell at the specified position. In
## a normal game of Sudoku, this is the row, column, and subgrid.
static func get_potential_conflict_positions(pos: Vector2i) -> Array[Vector2i]:
	var cell_positions: Array[Vector2i] = []
	var row = pos.x
	var col = pos.y
	
	# Appends the row and col
	for i in range(9):
		if i != col:
			cell_positions.append(Vector2i(row, i))
		if i != row:
			cell_positions.append(Vector2i(i, col))
	
	# Append subgrid
	@warning_ignore("integer_division")
	var r: int = row / 3 * 3
	@warning_ignore("integer_division")
	var c: int = col / 3 * 3
	for i in range(3):
		for j in range(3):
			# Don't add positions in the cell's row or col (they've already been added!)
			if r + i != row and c + j != col:
				cell_positions.append(Vector2i(r + i, c + j))
	
	return cell_positions


## Finds the position of the first empty cell in the board and returns it as a
## 2D vector. If no empty cell is found, returns (-1, -1).
static func find_empty_cell(sudoku_board: Array[Array]) -> Vector2i:
	for row_i in sudoku_board.size():
		for col_i in sudoku_board[0].size():
			if sudoku_board[row_i][col_i] == 0:
				return Vector2i(row_i, col_i)
	return Vector2i(-1, -1)


## Checks to see if the number at the specified row and col would be a valid 
## placement on the given board. In a normal game of Sudoku this means the
## number is not already found in the position's row, column, or subgrid. [br]
## This does NOT check if the placement is the solution to the board. It checks
## validity based on the current state of the given board.
static func is_valid_num(sudoku_board: Array[Array], row: int, col: int, num: int) -> bool:
	# Check row and column
	for i in range(9):
		if sudoku_board[i][col] == num and i != row:
			return false
		if sudoku_board[row][i] == num and i!= col:
			return false
	
	# Check subgrid
	@warning_ignore("integer_division")
	var r: int = row / 3 * 3
	@warning_ignore("integer_division")
	var c: int = col / 3 * 3
	for i in range(3):
		for j in range(3):
			if r + i == row and c + j == col:
				continue
			if sudoku_board[r + i][c + j] == num:
				return false
	return true


## Returns a list of all numbers that could still legally be placed at the given
## position (candidates). A filled cell does not have any candidates.
static func get_candidates(board: Array[Array], pos: Vector2i) -> Array[int]:
	if board[pos.x][pos.y] != 0: # Filled cell == no candidates
		return []
	
	var candidates: Array[int] = []
	for num in range(1, 10):
		if is_valid_num(board, pos.x, pos.y, num):
			candidates.append(num)
	return candidates


## Returns all 27 units on a 9x9 board (9 rows, 9 columns, 9 boxes), each as a
## list of the 9 cell positions belonging to it. Helps with human diffiuclty
## rating since all techniques operate per-unit.
static func get_units() -> Array[Array]:
	var units: Array[Array] = []
	
	# Rows
	for row in range(9):
		var unit: Array[Vector2i] = []
		for col in range(9):
			unit.append(Vector2i(row, col))
		units.append(unit)
	
	# Columns
	for col in range(9):
		var unit: Array[Vector2i] = []
		for row in range(9):
			unit.append(Vector2i(row, col))
		units.append(unit)
	
	# Boxes/Subgrids
	for box_row in range(3):
		for box_col in range(3):
			var unit: Array[Vector2i] = []
			for in_row in range(3):
				for in_col in range(3):
					unit.append(Vector2i(box_row * 3 + in_row, box_col * 3 + in_col))
			units.append(unit)
	
	return units
