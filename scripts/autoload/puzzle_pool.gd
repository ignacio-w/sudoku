extends Node

signal puzzle_generated(difficulty: SudokuGenerator.Difficulty)

var _pools: Dictionary[SudokuGenerator.Difficulty, Array]= { # holds puzzles per difficulty
	SudokuGenerator.Difficulty.EASY: [],
	SudokuGenerator.Difficulty.MEDIUM: [],
	SudokuGenerator.Difficulty.HARD: [],
}

var _pool_target := 2  # how many puzzles to keep ready per difficulty
var _generating := {}  # tracks in-flight threads per difficulty, avoids double-generating


## Method to obtain a pre-generated SudokuPuzzle. Returns null if no puzzles of the given difficulty
## are immediately available.
func take_puzzle(difficulty: SudokuGenerator.Difficulty) -> SudokuPuzzle:
	var puzzle: SudokuPuzzle = _pools[difficulty].pop_front() if not _pools[difficulty].is_empty() else null
	_refill(difficulty)  # top the pool back up, regardless of whether we had one ready
	return puzzle  # null means the caller needs to show the loading screen and generate synchronously-on-thread


## Method to obtain a SudokuPuzzle. If one is available, returns the available
## one and generates more to refill the pool on a separate thread. If one is not available,
## waits for a puzzle with the correct difficulty to be generated and returns it once finished.
func get_puzzle_async(difficulty: SudokuGenerator.Difficulty) -> SudokuPuzzle:
	if not _pools[difficulty].is_empty():
		var puzzle: SudokuPuzzle = _pools[difficulty].pop_front()
		_refill(difficulty)
		return puzzle
	
	# Pool's empty - make sure generation is happening, then wait for it.
	_refill(difficulty)
	while _pools[difficulty].is_empty():
		var ready_difficulty = await puzzle_generated
		# if refill has been called more than once somewhere else, another
		# difficulty may be ready first so ignore it
		if ready_difficulty != difficulty:
			continue
	
	# Return generated puzzle
	var puzzle: SudokuPuzzle = _pools[difficulty].pop_front()
	_refill(difficulty)
	return puzzle


## Calls the internal _refill() function.
func request_refill(difficulty: SudokuGenerator.Difficulty) -> void:
	_refill(difficulty)


## Generates SudokuPuzzles for the given difficulty on a separate thread until the number of puzzles
## specified in _pool_target has been reached. If no more puzzles need to be generated, no action
## will  occur. If a puzzle of the given difficulty is already attempting to generate, a new
## one will not start until the current one finishes.
func _refill(difficulty: SudokuGenerator.Difficulty) -> void:
	if _pools[difficulty].size() >= _pool_target or _generating.get(difficulty, false):
		return
	_generating[difficulty] = true
	var thread := Thread.new()
	thread.start(_generate_for_pool.bind(difficulty, thread))


## Calls the method to generate a Sudoku Puzzle with a given difficulty on the given thread, then
## calls _on_pool_puzzle_ready() on the main thread using call_deffered().
func _generate_for_pool(difficulty: SudokuGenerator.Difficulty, thread: Thread) -> void:
	var puzzle := SudokuGenerator.new().generate(difficulty)
	_on_pool_puzzle_ready.call_deferred(difficulty, puzzle, thread) # calls on main thread


## Waits until a puzzle has finished generating and updates all internal properties. Should not be
## used outside of this script.
func _on_pool_puzzle_ready(difficulty: SudokuGenerator.Difficulty, puzzle: SudokuPuzzle, thread: Thread) -> void:
	thread.wait_to_finish()
	_pools[difficulty].append(puzzle)
	_generating[difficulty] = false
	puzzle_generated.emit(difficulty)
	_refill(difficulty)  # keep going until the pool's actually full
