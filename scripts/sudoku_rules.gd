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
