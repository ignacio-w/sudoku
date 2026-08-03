class_name SudokuDifficultyRater extends RefCounted

"""
Rates how difficult a puzzle is for a human to solve.
Answers: What is the least sophisticated technique needed, and does one even
exist without guessing?

"""

enum Tier {
	SINGLES, # naked singles, hidden singles
	UNSOLVABLE_LOGICALLY, # technique not implemented
}

var _techniques: Dictionary[Callable, Tier] = {
	_apply_naked_single: Tier.SINGLES,
	_apply_hidden_single: Tier.SINGLES,
}

## Returns true if the given board is solved, false otherwise.
## Vector2i(-1, -1) is the returned value of SudokuRules.find_empty_cell() when
## no empty cell is found.
func _is_solved(board: Array[Array]) -> bool:
	return SudokuRules.find_empty_cell(board) == Vector2i(-1, -1)

## Rates the difficulty of the given board. Returns the highest tier of
## technique that was ever required during a full logical solve, or
## Tier.UNSOLVABLE_LOGICALLY if the board couldn't be fully solved only using
## the implemented technqiues. This does not modify the board passed in.
## TODO: Add implementation
func rate(board: Array[Array]) -> Tier:
	return 0 as Tier


## Attempts to input one number into the board by finding a naked single.
## A naked single is a cell with exactly one candidate and is the simplest
## solving technqiue. After analyzing a cell's row, col, and subgrid, there
## should only be one number (1-9) not found.
## Returns true if a naked single was found and placed, false otherwise.
func _apply_naked_single(board: Array[Array]) -> bool:
	for row in range(9):
		for col in range(9):
			if board[row][col] != 0: # Skip filled cells; 0 candidates
				continue
			var candidates := SudokuRules.get_candidates(board, Vector2i(row, col))
			if candidates.size() == 1:
				board[row][col] = candidates[0] # Place num
				return true
	return false


## Attempts to input one number into the board by finding a hidden single.
## A hidden single is where a number (1-9) only has one legal cell it could go
## in within a unit (row/col/box).
## Returns true if a hidden single was found and placed, false otherwise.
func _apply_hidden_single(board: Array[Array]) -> bool:
	for unit in SudokuRules.get_units():
		# Test each number in each position in unit
		for num in range(1, 10):
			var legal_cells: Array[Vector2i] = []
			for pos in unit:
				if board[pos.x][pos.y] == 0 and SudokuRules.is_valid_num(board, pos.x, pos.y, num):
					legal_cells.append(pos) # Num is valid at cell pos
			if legal_cells.size() == 1: # Only 1 valid pos in unit; hidden single found
				var pos := legal_cells[0]
				board[pos.x][pos.y] = num # Place num
				return true
	return false
