class_name SudokuGenerator extends RefCounted

enum Difficulty {EASY, MEDIUM, HARD}

var solver: SudokuSolver


func _init() -> void:
	solver = SudokuSolver.new()


## Creates and returns a Sudoku puzzle with a given difficulty.
func generate(difficulty: int) -> SudokuPuzzle:
	# Construct empty SudokuPuzzle
	var puzzle := SudokuPuzzle.new()
	
	# Create empty notes board
	puzzle.notes_board = []
	puzzle.notes_board.resize(9)
	for row in range(9):
		puzzle.notes_board[row] = []
		puzzle.notes_board[row].resize(9)
		for col in range(9):
			puzzle.notes_board[row][col] = [] as Array[int]
	
	# Create an empty board
	var board: Array[Array] = []
	board.resize(9)
	for row in range(9):
		board[row] = []
		board[row].resize(9)
		board[row].fill(0)
	
	# Create and store a solved board
	if not solver._solve_recursive(board):
		push_warning("Solved board could not be created!")
	puzzle.solution_board = board.duplicate(true)
	
	# Get cell positions
	var cells: Array[Vector2i] = []
	for row_i in board.size():
		for col_i in board[0].size():
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
		var solution_value = board[row][col]
		
		board[row][col] = 0
		
		# Check # of solutions; if only one unique solution, we can safely remove clue
		if solver.count_solutions(board) != 1:
			board[row][col] = solution_value
		else:
			clues -= 1
	
	print("Level ", str(difficulty), " board generated with ", str(clues), " clues.")
	puzzle.player_board = board
	
	return puzzle
