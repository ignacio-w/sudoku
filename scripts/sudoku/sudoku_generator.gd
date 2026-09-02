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
			return SudokuDifficultyRater.Tier.PAIRS
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
			return SudokuDifficultyRater.Tier.BOX_LINE_REDUCTION
	return SudokuDifficultyRater.Tier.SINGLES


## Returns the minimum number of clues required for a board to have for this
## specified difficulty
func _min_clues_for(difficulty: Difficulty) -> int:
	match difficulty:
		Difficulty.EASY:
			return 34
		Difficulty.MEDIUM:
			return 28
		Difficulty.HARD:
			return 22
	
	push_warning("Difficulty not accounted for. Will default to medium")
	return 28


## Creates and returns a Sudoku puzzle with a given difficulty. Makes sure
## the puzzle generated meets a minimum difficulty threshold by attempting
## to generate the board multiple times until the difficulty is met.
## TODO: Medium/hard difficulty takes a while to generate. Improve generation
## speed.
func generate(difficulty: Difficulty = Difficulty.EASY) -> SudokuPuzzle:
	var min_tier := _min_tier_for(difficulty)
	var max_solution_attempts := 3 # how many different solution boards to try
	var max_attempts := 50 # how many removal attempts to try per board
	var _time = 0
	
	var puzzle: SudokuPuzzle
	# Create a new solution board up to max_solution_attempts if hard board couldn't be generated
	for solution_attempt in range(max_solution_attempts):
		var solution_board := _build_solution_board()
		
		# Attempt to remove clues to create a puzzle up to max_attempts times
		for attempt in range(max_attempts):
			var _init_time := Time.get_ticks_msec()
			
			puzzle = _attempt_create_puzzle(solution_board, difficulty)
			var tier := rater.rate(puzzle.player_board)
			
			_time += Time.get_ticks_msec() - _init_time
			print("Took %dms to generate a puzzle #%d." % [Time.get_ticks_msec() - _init_time, attempt])
			
			# Puzzle meets difficulty criteria; finished
			if tier >= min_tier:
				print("\nReached min target on attempt %d" % (attempt + 1))
				#_successes += 1
				print("Avg time per puzzle gen: %f" % ((_time / float(max_attempts)) / 1000.0))
				print("Total time elapsed: %.3fs\n\n" % (_time / 1000.0))
				return puzzle
			print()
	
	# Puzzle failed to meet difficulty criteria, return last puzzle generated
	print("Total time elapsed: %.2fs" % (_time / 1000.0))
	push_warning("Couldn't reach minimum difficuly after %d attempts; returning last attempt." % (max_attempts * max_solution_attempts))
	return puzzle


## Creates a solution board for the generator to use.
func _build_solution_board() -> Array[Array]:
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
	return board


## Generates a SudokuPuzzle from a solution_board with a given difficulty. Makes
## sure difficulty of puzzle does not exceed its max technique tier.
func _attempt_create_puzzle(solution_board: Array[Array], difficulty: Difficulty) -> SudokuPuzzle:
	# Construct empty SudokuPuzzle
	var puzzle := SudokuPuzzle.new()
	var board := solution_board.duplicate(true)
	
	# Create empty notes board
	puzzle.notes_board = []
	puzzle.notes_board.resize(9)
	for row in range(9):
		puzzle.notes_board[row] = []
		puzzle.notes_board[row].resize(9)
		for col in range(9):
			puzzle.notes_board[row][col] = [] as Array[int]
	
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
	var failures := 0
	var actual_max_tier_used := SudokuDifficultyRater.Tier.SINGLES # for testing
	for cell in cells:
		# Stop removing clues if # min clues has been reached, regardless of
		# technique tier
		if clues <= min_clues:
			break
		var row = cell.x
		var col = cell.y
		var solution_value = board[row][col]
		
		# Remove clue; perform checks
		board[row][col] = 0
		
		# Check #1: Board must only have 1 unique solution
		if solver.count_solutions(board) != 1:
			board[row][col] = solution_value
			failures += 1
			continue
		
		# Check #2: Difficulty to solve board mustn't exceed max for this difficulty
		var rating = rater.rate(board)
		if rating > max_tier:
			board[row][col] = solution_value
			failures += 1
			continue
		actual_max_tier_used = max(rating, actual_max_tier_used)
		clues -= 1
		
	print("Level ", str(difficulty), " board generated with ", str(clues), " clues.")
	print("Most difficult technique used: " + str(actual_max_tier_used))
	print("Failed %d times before succesful generation." % failures)
	puzzle.player_board = board
	puzzle.solution_board = solution_board.duplicate(true)
	
	return puzzle
