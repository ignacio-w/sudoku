class_name Sodoku extends RefCounted

var num_board: Array[Array]
var solution_board: Array[Array]
enum Difficulty {EASY, NORMAL, HARD}


## Creates a new game
func new_game(difficulty: Difficulty = Difficulty.EASY):
	num_board = _make_puzzle(difficulty)
	for row in num_board:
		print(row)


## Creates and returns a Sodoku puzzle with a given difficulty.
func _make_puzzle(difficulty: int) -> Array[Array]:
	# Create an empty board
	var sodoku_board: Array[Array] = []
	sodoku_board.resize(9)
	for row in range(9):
		sodoku_board[row] = []
		sodoku_board[row].resize(9)
		for col in range(9):
			sodoku_board[row][col] = 0
	
	# Create a solved board
	if not _solve_recursive(sodoku_board):
		push_warning("Solved board could not be created!")
	
	# Get cell positions
	var cells: Array[Vector2i] = []
	for row_i in sodoku_board.size():
		for col_i in sodoku_board[0].size():
			cells.append(Vector2i(row_i, col_i))
	cells.shuffle()
	
	# Determine number of clues to give
	var clues: int
	match difficulty:
		Difficulty.EASY:
			clues = randi_range(40, 55)
	
	# Remove cells till all that remains is the number of clues
	for cell in range(81 - clues):
		var row = cells[cell].x
		var col = cells[cell].y
		var solution_value = sodoku_board[row][col]
		sodoku_board[row][col] = 0
		if count_solutions(sodoku_board) != 1:
			sodoku_board[row][col] = solution_value
	
	print("Board generated with ", str(clues), " clues.")
	return sodoku_board


## Given a sodoku board, a new solved board is returned or null if there is no
## solution. If instead you want to directly solve the given board, use
## _solve_recursive().
func solve(sodoku_board: Array[Array]):
	var copy = sodoku_board.duplicate(true)
	if _solve_recursive(copy):
		return copy
	return null


## Completly solves a given sodoku board. This function will directly modify
## the given sodoku board. If instead you want a solved copy returned,
## use solve().
func _solve_recursive(sodoku_board: Array[Array]) -> bool:
	# Find an empty cell
	var empty_cell = find_empty_cell(sodoku_board)
	
	# If there is no empty cells, board is complete and return true
	if empty_cell == Vector2i(-1, -1):
		return true
	
	var row: int = empty_cell.x
	var col: int = empty_cell.y
	var number_range = range(1, 10)
	number_range.shuffle()
	
	for num in number_range:
		# Test numbers until a valid number is found
		if is_valid_num(sodoku_board, row, col, num):
			sodoku_board[row][col] = num
			# Recursively call function until board is completly solved
			if _solve_recursive(sodoku_board):
				return true
			# When board is unsolvable, reset value and continue testing values
			sodoku_board[row][col] = 0
	
	# If no number is valid, board is unsolvable and returns false
	return false


## Check if the number at the specified row and col would be a valid placement
func is_valid_num(sodoku_board: Array[Array], row: int, col: int, num: int) -> bool:
	
	# We assume the spot on the board is empty
	if sodoku_board[row][col] != 0:
		return false
	
	# Check column
	for col_i in range(9):
		if sodoku_board[row][col_i] == num:
			return false
	# Check row
	for row_i in range(9):
		if sodoku_board[row_i][col] == num:
			return false
	
	# Check subgrid
	var r: int = row / 3 * 3
	var c: int = col / 3 * 3
	for i in range(3):
		for j in range(3):
			if sodoku_board[r + i][c + j] == num:
				return false
	return true


## Finds the first empty cell in the board and returns it has an
## integer 2D vector. If no empty cell is found, returns (-1, -1)
func find_empty_cell(sodoku_board: Array[Array]) -> Vector2i:
	for row_i in sodoku_board.size():
		for col_i in sodoku_board[0].size():
			if sodoku_board[row_i][col_i] == 0:
				return Vector2i(row_i, col_i)
	return Vector2i(-1, -1)


## Counts the number of solutions available from a partially filled board by
## attempting to recurisvely solve the board. This function attempts to answer
## the question, "Does the puzzle have exactly 1 solution?".
## Returns 0 if there are no solutions to the board (invalid number placement),
## 1 if there is only 1 solution, and a number greater than 1 if the solution to
## the board is ambiguous (may not be actual number of solutions).
func count_solutions(sodoku_board: Array[Array]) -> int:
	# Find an empty cell
	var empty_cell = find_empty_cell(sodoku_board)
	var row: int
	var col: int
	var solutions := 0
	
	# No empty cells means a solution has been found
	if empty_cell == Vector2i(-1, -1):
		return 1
	else:
		row = empty_cell.x
		col = empty_cell.y
	
	# Test numbers sequentially
	for num in range(1, 10):
		# Test numbers until a valid number is found
		if is_valid_num(sodoku_board, row, col, num):
			sodoku_board[row][col] = num
			# Recursively call function until total number of solutions have been found
			solutions += count_solutions(sodoku_board)
			# Reset empty cell to its original state
			sodoku_board[row][col] = 0
			
			# If more than 1 solution is found as a result of the placed num,
			# stop searching. The solution is ambiguous.
			if solutions >= 2:
				return 2
	
	# Final return statement as described in function description
	return solutions
