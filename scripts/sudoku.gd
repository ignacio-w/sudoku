class_name Sudoku extends RefCounted

var player_board: Array[Array]
var solution_board: Array[Array]
var strikes: int = 0
enum Difficulty {EASY, MEDIUM, HARD}


## TODO: Add settings, modes, etc. (ex: Validate input?)
## Extend class to create new Sodoku modes?
## NOTICE: For now, game is 9x9 regular sodoku where every input is checked

## Constructor for a new Sudoku game with a given difficulty. Creates a board
## solution, then prints the board. 
func _init(difficulty: Difficulty = Difficulty.EASY) -> void:
	player_board = _make_puzzle(difficulty)
	solution_board = solve(player_board)
	print_board(player_board)
	
	print("Generated solution board:")
	print_board(solution_board)


## Creates and returns a Sodoku puzzle with a given difficulty.
func _make_puzzle(difficulty: int) -> Array[Array]:
	# Create an empty board
	var sudoku_board: Array[Array] = []
	sudoku_board.resize(9)
	for row in range(9):
		sudoku_board[row] = []
		sudoku_board[row].resize(9)
		for col in range(9):
			sudoku_board[row][col] = 0
	
	# Create a solved board
	if not _solve_recursive(sudoku_board):
		push_warning("Solved board could not be created!")
	
	# Get cell positions
	var cells: Array[Vector2i] = []
	for row_i in sudoku_board.size():
		for col_i in sudoku_board[0].size():
			cells.append(Vector2i(row_i, col_i))
	cells.shuffle()
	
	# TODO: Determine number of clues to give; add difficulty options
	# Make difficulty algorithm more complex; make algorithm more accurately
	# reflect puzzle difficulty as opposed to just based on # of clues
	var clues: int
	match difficulty:
		Difficulty.EASY:
			clues = randi_range(40, 55)
		Difficulty.MEDIUM:
			clues = randi_range(30, 39)
		Difficulty.HARD:
			clues = randi_range(20, 29)
	
	# Remove cells till all that remains is the number of clues
	for cell in range(81 - clues):
		var row = cells[cell].x
		var col = cells[cell].y
		var solution_value = sudoku_board[row][col]
		sudoku_board[row][col] = 0
		if count_solutions(sudoku_board) != 1:
			sudoku_board[row][col] = solution_value
	
	print("Level ", str(difficulty), " board generated with ", str(clues), " clues.")
	return sudoku_board


## Given a sodoku board, a new solved board is returned or null if there is no
## solution. If instead you want to directly create a solution from a given
## board, use _solve_recursive().
func solve(sudoku_board: Array[Array]):
	var copy = sudoku_board.duplicate(true)
	if _solve_recursive(copy):
		return copy
	return null


## Completly solves a given sodoku board by filling the board with random
## numbers until a solution is found. This function will directly modify
## the given sodoku board. If instead you want a solved copy returned,
## use solve(). Returns true if the given board was able to be solved, false
## otherwise.
func _solve_recursive(sudoku_board: Array[Array]) -> bool:
	# Find an empty cell
	var empty_cell = find_empty_cell(sudoku_board)
	
	# If there is no empty cells, board is complete and return true
	if empty_cell == Vector2i(-1, -1):
		return true
	
	var row: int = empty_cell.x
	var col: int = empty_cell.y
	var number_range = range(1, 10)
	number_range.shuffle()
	
	for num in number_range:
		# Test each number until a solution (or lack thereof) is determined
		if is_valid_num(sudoku_board, row, col, num):
			sudoku_board[row][col] = num
			# Check to see if a solution can be found after placing this num
			if _solve_recursive(sudoku_board):
				return true
			# When board is unsolvable, reset value and continue testing values
			sudoku_board[row][col] = 0
	
	# If no number is valid, board is unsolvable and returns false
	return false


## Check if the number at the specified row and col would be a valid placement
## on the given board. Does NOT check if the placement is the board's
## solution, only if it's valid based on the current contents of the given
## board. The position of the number inputted must be empty for this to work 
## properly.
func is_valid_num(sudoku_board: Array[Array], row: int, col: int, num: int) -> bool:
	
	# We assume the spot on the board is empty. If not empty, return false
	if sudoku_board[row][col] != 0:
		return false
	
	# Check column
	for col_i in range(9):
		if sudoku_board[row][col_i] == num:
			return false
	# Check row
	for row_i in range(9):
		if sudoku_board[row_i][col] == num:
			return false
	
	# Check subgrid
	@warning_ignore("integer_division")
	var r: int = row / 3 * 3
	@warning_ignore("integer_division")
	var c: int = col / 3 * 3
	for i in range(3):
		for j in range(3):
			if sudoku_board[r + i][c + j] == num:
				return false
	return true

## Checks if the requested input matches the solution board.
func is_solution(row: int, col: int, num: int) -> bool:
	if num == solution_board[row][col]:
		return true
	return false


## Finds the position of the first empty cell in the board and returns it as a
## 2D vector. If no empty cell is found, returns (-1, -1).
func find_empty_cell(sudoku_board: Array[Array]) -> Vector2i:
	for row_i in sudoku_board.size():
		for col_i in sudoku_board[0].size():
			if sudoku_board[row_i][col_i] == 0:
				return Vector2i(row_i, col_i)
	return Vector2i(-1, -1)


## Counts the number of solutions available from a partially filled board by
## attempting to recurisvely solve the board. This function attempts to answer
## the question, "Does the puzzle have exactly 1 solution?".
## Returns 0 if there are no solutions to the board (invalid placement),
## 1 if there is only 1 solution, and a number greater than 1 if the solution to
## the board is ambiguous (may not be actual number of solutions).
func count_solutions(sudoku_board: Array[Array]) -> int:
	# Find an empty cell
	var empty_cell = find_empty_cell(sudoku_board)
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
		if is_valid_num(sudoku_board, row, col, num):
			sudoku_board[row][col] = num
			# Recursively call function until total number of solutions have been found
			solutions += count_solutions(sudoku_board)
			# Reset empty cell to its original state
			sudoku_board[row][col] = 0
			
			# If more than 1 solution is found as a result of the placed num,
			# stop searching. The solution is ambiguous.
			if solutions >= 2:
				return 2
	
	# Final return statement as described in function description
	return solutions


## Prints the given board in an easy to see way
func print_board(board: Array[Array]) -> void:
	for row in board:
		print(row)


## Returns an array of all cells that need to be checked in order to determine
## potential conflicts with the value of the cell at the specified position. In
## general in Sodoku, this is the row, column, and subgrid.
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
