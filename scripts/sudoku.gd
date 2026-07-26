class_name Sudoku extends RefCounted

var player_board: Array[Array] ## The board the player uses to play the game.
var solution_board: Array[Array] ## The end goal of the player's board.
var mistakes: int = 0 ## The number of mistakes the player has made.
enum Difficulty {EASY, MEDIUM, HARD}


## TODO: Add settings, modes, etc. (ex: Validate input?)
## Extend class to create new Sudoku modes?
## NOTICE: For now, game is 9x9 regular sudoku where every input is checked

## Constructor for a new Sudoku game with a given difficulty. Creates a board
## solution, then prints the board. 
func _init(difficulty: Difficulty = Difficulty.EASY) -> void:
	player_board = _make_puzzle(difficulty)
	print_board(player_board)
	
	print("Generated solution board:")
	print_board(solution_board)


## Creates and returns a Sudoku puzzle with a given difficulty.
func _make_puzzle(difficulty: int) -> Array[Array]:
	# Create an empty board
	var sudoku_board: Array[Array] = []
	sudoku_board.resize(9)
	for row in range(9):
		sudoku_board[row] = []
		sudoku_board[row].resize(9)
		sudoku_board[row].fill(0)
	
	# Create and store a solved board
	if not _solve_recursive(sudoku_board):
		push_warning("Solved board could not be created!")
	solution_board = sudoku_board.duplicate(true)
	
	# Get cell positions
	var cells: Array[Vector2i] = []
	for row_i in sudoku_board.size():
		for col_i in sudoku_board[0].size():
			cells.append(Vector2i(row_i, col_i))
	cells.shuffle()
	
	# TODO: Determine number of clues to give; add difficulty options
	# Make difficulty algorithm more complex; make algorithm more accurately
	# reflect puzzle difficulty as opposed to just based on # of clues
	var target_clues: int
	match difficulty:
		Difficulty.EASY:
			target_clues = randi_range(36, 46)
		Difficulty.MEDIUM:
			target_clues = randi_range(30, 35)
		Difficulty.HARD:
			target_clues = randi_range(25, 29)
	
	# Remove cells till target # of clues is hit or max # of cells have been removed
	var clues := 81
	for cell in cells:
		if clues <= target_clues:
			break
		
		var row = cell.x
		var col = cell.y
		var solution_value = sudoku_board[row][col]
		
		sudoku_board[row][col] = 0
		
		# Check # of solutions; if only one unique solution, we can safely remove clue
		if count_solutions(sudoku_board) != 1:
			sudoku_board[row][col] = solution_value
		else:
			clues -= 1
	
	print("Level ", str(difficulty), " board generated with ", str(clues), " clues.")
	return sudoku_board


## Given a Sudoku board, a new solved board is returned or null if there is no
## solution. If instead you want to directly create a solution from a given
## board, use _solve_recursive().
func solve(sudoku_board: Array[Array]):
	var copy = sudoku_board.duplicate(true)
	if _solve_recursive(copy):
		return copy
	return null


## Attempts to completly solves a given Sudoku board by testing numbers in cells
## until a complete legal board is found.[br]
##    - If no legal board is found after testing all numbers in all empty cells,
## the board will return to its inital state and [code]false[/code] will be returned.[br]
##    - If a legal board is found, the
## given board will become the solution board and [code]true[/code] will be returned.[br]
## If you don't want your inital board to be modified, use [method Sudoku.solve]
## to get a copy of the solved board instead.
func _solve_recursive(sudoku_board: Array[Array]) -> bool:
	# Find an empty cell
	var empty_cell := find_empty_cell(sudoku_board)
	
	# If there are no empty cells val of (-1, -1), board solution was found; END
	if empty_cell == Vector2i(-1, -1):
		return true
	
	var row: int = empty_cell.x
	var col: int = empty_cell.y
	var number_range = range(1, 10)
	number_range.shuffle()
	
	# Test each number until a solution (or lack thereof) is determined
	for num in number_range:
		# Check if number can be placed at empty cell
		if is_valid_num(sudoku_board, row, col, num):
			# Place number, then attempt to solve new board
			sudoku_board[row][col] = num
			if _solve_recursive(sudoku_board):
				return true
			# Board is not solvable with this number at this cell. Reset
			# cell. If all numbers have been tested, we backtrack. 
			sudoku_board[row][col] = 0
	
	# No number can be placed in this cell to generate legal board. False on
	# first cell means the board has no solution.
	return false


## Checks to see if the number at the specified row and col would be a valid 
## placement on the given board. In a normal game of Sudoku this means the
## number is not already found in the position's row, column, or subgrid. [br]
## This does NOT check if the placement is the solution to the board. It checks
## validity based on the current state of the given board.
func is_valid_num(sudoku_board: Array[Array], row: int, col: int, num: int) -> bool:
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
## the following question: "Does the puzzle have exactly 1 solution?".
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
## general, in a normal game of Sudoku, this is the row, column, and subgrid.
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
