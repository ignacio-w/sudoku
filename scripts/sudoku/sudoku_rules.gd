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


## Finds the empty cell with the FEWEST legal candidates. Trying the most
## constrained cell first means backtracking fails fast on dead branches
## instead of wandering deep into unproductive ones.
static func find_most_constrained_cell(sudoku_board: Array[Array]) -> Vector2i:
	var best_pos := Vector2i(-1, -1)
	var best_count := 10  # more than any real candidate count

	for row in range(9):
		for col in range(9):
			if sudoku_board[row][col] != 0:
				continue
			var count: int = get_candidates(sudoku_board, Vector2i(row, col)).size()
			if count == 0:
				return Vector2i(row, col)  # dead end — bail out immediately
			if count < best_count:
				best_count = count
				best_pos = Vector2i(row, col)

	return best_pos


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
	
	# Check subgrid/box
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


### Returns a list of all numbers that could still legally be placed at the given
### position (candidates). Fills in numerical order (eg. [1, 4, 7]; never [4, 7, 1]).
### A filled cell does not have any candidates. Uses bitmasks to do this,
## optimizing for speed.
static func get_candidates(board: Array[Array], pos: Vector2i) -> Array[int]:
	var row := pos.x
	var col := pos.y
	
	if board[row][col] != 0: # Filled cell == no candidates
		return []
	
	var used := 0
	# used = 000000000
	# Each digit represents numbers 1-9; if found in row/col; turn digit to 1
	for i in range(9):
		if board[row][i] != 0:
			used |= 1 << (board[row][i] - 1)
		if board[i][col] != 0:
			used |= 1 << (board[i][col] - 1)
	
	# Check subgrid/box
	@warning_ignore("integer_division")
	var r: int = row / 3 * 3
	@warning_ignore("integer_division")
	var c: int = col / 3 * 3
	for i in range(3):
		for j in range(3):
			var num = board[r + i][c + j]
			if num != 0:
				used |= 1 << (num - 1)
	
	var candidates: Array[int] = []
	for num in range(1, 10):
		# Candidate if bit is not set (0)
		if (used & 1 << (num - 1)) == 0:
			candidates.append(num)
	return candidates


## Returns the list of candidate numbers (1-9) that could still legally be
## placed at the given position. Empty if the cell is already filled.
#static func get_candidates(sudoku_board: Array[Array], pos: Vector2i) -> Array[int]:
	#var row := pos.x
	#var col := pos.y
	#
	#if sudoku_board[row][col] != 0:
		#return []
	#
	#var candidates: Array[int] = []
	#for num in range(1, 10):
		#if is_valid_num(sudoku_board, row, col, num):
			#candidates.append(num)
	#return candidates


## Returns all 27 units on a 9x9 board (9 rows, 9 columns, 9 boxes in that
## order), each as a list of the 9 cell positions belonging to it. Helps with
## human diffiuclty rating since all techniques operate per-unit.
static func get_units() -> Array[Array]:
	var units: Array[Array] = []
	units.append_array(get_rows())
	units.append_array(get_cols())
	units.append_array(get_boxes())
	return units


## Returns the 9 rows, each as a list of the 9 cell positions in it.
static func get_rows() -> Array[Array]:
	var rows: Array[Array] = []
	for row in range(9):
		var unit: Array[Vector2i] = []
		for col in range(9):
			unit.append(Vector2i(row, col))
		rows.append(unit)
	return rows


## Returns the 9 columns, each as a list of the 9 cell positions in it.
static func get_cols() -> Array[Array]:
	var cols: Array[Array] = []
	for col in range(9):
		var unit: Array[Vector2i] = []
		for row in range(9):
			unit.append(Vector2i(row, col))
		cols.append(unit)
	return cols


## Returns the 9 boxes, each as a list of the 9 cell positions in it.
static func get_boxes() -> Array[Array]:
	var boxes: Array[Array] = []
	for box_row in range(3):
		for box_col in range(3):
			var unit: Array[Vector2i] = []
			for i in range(3):
				for j in range(3):
					unit.append(Vector2i(box_row * 3 + i, box_col * 3 + j))
			boxes.append(unit)
	return boxes
