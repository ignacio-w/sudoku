class_name SudokuGenerator extends RefCounted

enum Difficulty {EASY, MEDIUM, HARD}

var solver: SudokuSolver
var rater: SudokuDifficultyRater


func _init() -> void:
	solver = SudokuSolver.new()
	rater = SudokuDifficultyRater.new()


## Returns maximum technique tier for specified difficulty
## TODO: Implement more tiers of difficulty for different difficlties
func _max_tier_for(difficulty: Difficulty) -> SudokuDifficultyRater.Tier:
	match difficulty:
		Difficulty.EASY:
			return SudokuDifficultyRater.Tier.SINGLES
		Difficulty.MEDIUM:
			return SudokuDifficultyRater.Tier.SINGLES
		Difficulty.HARD:
			return SudokuDifficultyRater.Tier.SINGLES
	return SudokuDifficultyRater.Tier.SINGLES


## Returns the minimum number of clues required for a board to have for this
## specified difficulty
func _min_clues_for(difficulty: Difficulty) -> int:
	match difficulty:
		Difficulty.EASY:
			return 36
		Difficulty.MEDIUM:
			return 30
		Difficulty.HARD:
			return 25
	return 30


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
	
	# Create empty player board
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
	
	# Remove cells till target # of clues is hit or max # of cells have been removed
	var max_tier := _max_tier_for(difficulty)
	var min_clues := _min_clues_for(difficulty)
	var clues := 81
	
	for cell in cells:
		var row = cell.x
		var col = cell.y
		var solution_value = board[row][col]
		
		# Stop removing clues when min clues has been reached, regardless of
		# technique tier
		if clues <= min_clues:
			break
		board[row][col] = 0
		
		# Check #1: Can't remove clue if solution count is not 1
		if solver.count_solutions(board) != 1:
			board[row][col] = solution_value
			continue
		
		# Check #2: Technique difficulty mustn't exceed max for this difficulty
		if rater.rate(board) > max_tier:
			board[row][col] = solution_value
			continue
		
		clues -= 1
		
	print("Level ", str(difficulty), " board generated with ", str(clues), " clues.")
	puzzle.player_board = board
	
	return puzzle
