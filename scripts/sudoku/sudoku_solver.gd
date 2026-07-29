class_name SudokuSolver extends RefCounted


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
	var empty_cell := SudokuRules.find_empty_cell(sudoku_board)
	
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
		if SudokuRules.is_valid_num(sudoku_board, row, col, num):
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


## Counts the number of solutions available from a partially filled board by
## attempting to recurisvely solve the board. This function attempts to answer
## the following question: "Does the puzzle have exactly 1 solution?".
## Returns 0 if there are no solutions to the board (invalid placement),
## 1 if there is only 1 solution, and a number greater than 1 if the solution to
## the board is ambiguous (may not be actual number of solutions).
func count_solutions(sudoku_board: Array[Array]) -> int:
	# Find an empty cell
	var empty_cell := SudokuRules.find_empty_cell(sudoku_board)
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
		if SudokuRules.is_valid_num(sudoku_board, row, col, num):
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
