class_name SudokuGenerator extends RefCounted

enum Difficulty {EASY, MEDIUM, HARD}

var solver: SudokuSolver
var rater: SudokuDifficultyRater


func _init() -> void:
	solver = SudokuSolver.new()
	rater = SudokuDifficultyRater.new()


## Returns minimum technique tier for specified difficulty
## TODO: Implement more tiers of difficulty for different difficulties
func _min_tier_for(difficulty: Difficulty) -> SudokuDifficultyRater.Tier:
	match difficulty:
		Difficulty.EASY:
			return SudokuDifficultyRater.Tier.SINGLES
		Difficulty.MEDIUM:
			return SudokuDifficultyRater.Tier.NAKED_PAIRS
		Difficulty.HARD:
			return SudokuDifficultyRater.Tier.POINTING_PAIRS
	return SudokuDifficultyRater.Tier.SINGLES

## Returns maximum technique tier for specified difficulty
## TODO: Implement more tiers of difficulty for different difficulties
func _max_tier_for(difficulty: Difficulty) -> SudokuDifficultyRater.Tier:
	match difficulty:
		Difficulty.EASY:
			return SudokuDifficultyRater.Tier.SINGLES
		Difficulty.MEDIUM:
			return SudokuDifficultyRater.Tier.POINTING_PAIRS
		Difficulty.HARD:
			return SudokuDifficultyRater.Tier.POINTING_PAIRS
	return SudokuDifficultyRater.Tier.SINGLES


## Returns the minimum number of clues required for a board to have for this
## specified difficulty
func _target_clues_for(difficulty: Difficulty) -> int:
	match difficulty:
		Difficulty.EASY:
			return randi_range(36, 46)
		Difficulty.MEDIUM:
			return randi_range(30, 35)
		Difficulty.HARD:
			return randi_range(25, 29)
	
	push_error("Difficulty not accounted for. Target Clues will be -1")
	return -1


## Creates and returns a Sudoku puzzle with a given difficulty. Makes sure
## the puzzle generated meets a minimum difficulty threshold by attempting
## to generate the board multiple times until the difficulty is met.
## TODO: Medium/hard difficulty takes a while to generate. Improve generation
## speed.
func generate(difficulty: Difficulty = Difficulty.EASY) -> SudokuPuzzle:
	var min_tier := _min_tier_for(difficulty)
	var max_attempts := 25
	
	var puzzle: SudokuPuzzle
	# Attempt to generate board "max_attempts" attempts
	for attempt in range(max_attempts):
		puzzle = _generate_attempt(difficulty)
		var tier := rater.rate(puzzle.player_board)
		if tier >= min_tier:
			print("Reached min target on attempt %d" % (attempt + 1))
			return puzzle
	
	push_warning("Couldn't reach minimum difficuly after %d attempts; returning last attempt." % max_attempts)
	return puzzle

## Main method to generate a SudokuPuzzle with a given difficulty. Makes sure
## difficulty of puzzle does not exceed the max technique tier for that
## difficulty.
func _generate_attempt(difficulty: Difficulty) -> SudokuPuzzle:
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
	var target_clues := _target_clues_for(difficulty)
	var clues := 81
	var actual_max_tier_used := SudokuDifficultyRater.Tier.SINGLES # for testing
	for cell in cells:
		var row = cell.x
		var col = cell.y
		var solution_value = board[row][col]
		
		# Stop removing clues if # min clues has been reached, regardless of
		# technique tier
		if clues <= target_clues:
			break
		board[row][col] = 0
		
		# Check #1: Board must have only 1 unique solution if clue were to be removed
		if solver.count_solutions(board) != 1:
			board[row][col] = solution_value
			continue
		
		# Check #2: Technique difficulty to solve board mustn't exceed max for this difficulty
		var rating = rater.rate(board)
		if rating > max_tier:
			board[row][col] = solution_value
			continue
		actual_max_tier_used = max(rating, actual_max_tier_used)
		
		clues -= 1
		
	print("Level ", str(difficulty), " board generated with ", str(clues), " clues.")
	print("Most difficult technique used: " + str(actual_max_tier_used))
	puzzle.player_board = board
	
	return puzzle
