class_name SudokuDifficultyRater extends RefCounted

"""
Rates how difficult a puzzle is for a human to solve.
Answers: What is the least sophisticated technique needed, and does one even
exist without guessing?

"""
# TODO: Implement more techniques and tiers of difficulty to distinguish
# - Better account for density of techniques available Ex. at least 2-3
# singles were simultaneously findable at every step

enum Tier {
	SINGLES, # naked/hidden singles
	PAIRS, # naked/hidden pairs
	POINTING_PAIRS, # pointing pairs/triples
	BOX_LINE_REDUCTION, # box/line reduction
	UNSOLVABLE_LOGICALLY, # technique not implemented
}

var _techniques: Dictionary[Callable, Tier] = {
	_apply_naked_single: Tier.SINGLES,
	_apply_hidden_single: Tier.SINGLES,
	_apply_naked_pair: Tier.PAIRS,
	_apply_hidden_pair: Tier.PAIRS,
	_apply_pointing_pair: Tier.POINTING_PAIRS,
	_apply_box_line_reduction: Tier.BOX_LINE_REDUCTION,
}

## Returns true if the given board is solved, false otherwise.
## NOTE: Vector2i(-1, -1) is the returned value of SudokuRules.find_empty_cell()
## when no empty cell is found.
func _is_solved(board: Array[Array]) -> bool:
	return SudokuRules.find_empty_cell(board) == Vector2i(-1, -1)


## Creates the initial candidate grid straight from the board's placed values.
func _create_init_candidates(board: Array[Array]) -> Array[Array]:
	var candidates: Array[Array] = []
	candidates.resize(9)
	for row in range(9):
		candidates[row] = []
		candidates[row].resize(9)
		for col in range(9):
			candidates[row][col] = SudokuRules.get_candidates(board, Vector2i(row, col))
	return candidates


## Returns every unit (from "units") that contains ALL of the given positions.
func _units_containing_pos(units: Array[Array], positions: Array[Vector2i]) -> Array:
	var result := []
	for unit in units:
		var contains_all_pos := true
		for pos in positions:
			if pos not in unit:
				contains_all_pos = false
				break
		if contains_all_pos:
			result.append(unit)
	return result


## Returns all cell positions in the specified row number
func _row_cells(row: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for col in range(9):
		cells.append(Vector2i(row, col))
	return cells
 
## Returns all cell positions in the specified col number
func _col_cells(col: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for row in range(9):
		cells.append(Vector2i(row, col))
	return cells


## The ONE place a value ever gets placed. Updates both the board and
## removes the placed number from every peer's candidate list — this is
## what keeps the candidate grid a true reflection of reality as we go.
func _place_value(board: Array[Array], candidates: Array[Array], row: int, col: int, num: int) -> void:
	board[row][col] = num # Place num
	candidates[row][col] = [] # Remove candidates
	
	# Remove num from candidates in all affected cells
	for pos in SudokuRules.get_potential_conflict_positions(Vector2i(row, col)):
		candidates[pos.x][pos.y].erase(num)


## Rates the difficulty of the given board. Returns the highest tier of
## technique that was ever required to solve the board humanly, or
## Tier.UNSOLVABLE_LOGICALLY if the board couldn't be fully solved only using
## the implemented technqiues. This does NOT modify the board passed in.
## TODO: Add implementation
func rate(board: Array[Array]) -> Tier:
	var working_board := board.duplicate(true)
	var candidates := _create_init_candidates(working_board)
	var highest_tier_used := Tier.SINGLES
	
	while not _is_solved(working_board):
		var progress := false
		
		# Try each technique, easiest to hardest, every time progress is made.
		for technique in _techniques:
			var tier: Tier = _techniques[technique]
			
			# All techniques return true/false; true == technique successful
			if technique.call(working_board, candidates): 
				highest_tier_used = max(highest_tier_used, tier)
				progress = true
				break
		# After trying every technique, if no technique was successful,
		# progress was not made in solving the board and it is unsolvable
		# using currently implemented logical techniques
		if not progress:
			return Tier.UNSOLVABLE_LOGICALLY
	
	return highest_tier_used


"""
============================HUMAN SOLVING TECHNIQUES============================

This website contains information for most of the techniques: 
	https://www.sudokuwiki.org/sudoku.htm

- Naked/Hidden Singles
- Naked/Hidden Pairs
- Pointing Pairs/Triples
- Box-Line Reduction
"""

## A naked (obvious) single is a cell with exactly one candidate. After
## analyzing a cell's row, col, and subgrid, there should only be one number
## (1-9) not found. Attempts to input one number into the board by finding a
## naked single. Returns true if a naked single was found and placed,
## false otherwise.
func _apply_naked_single(board: Array[Array], candidates: Array[Array]) -> bool:
	for row in range(9):
		for col in range(9):
			# If only 1 candidate in an empty cell, place candidate in cell
			if board[row][col] == 0 and candidates[row][col].size() == 1:
				_place_value(board, candidates, row, col, candidates[row][col][0])
				return true
	return false


## A hidden single is where a number (1-9) only has one legal cell it could go
## in within a unit (row/col/box). Attempts to input one number into the board
## by finding a hidden single. Returns true if a hidden single was found and
## placed, false otherwise.
func _apply_hidden_single(board: Array[Array], candidates: Array[Array]) -> bool:
	for unit in SudokuRules.get_units():
		# Test each number in each position in unit
		for num in range(1, 10):
			var legal_cells: Array[Vector2i] = []
			for pos in unit:
				if num in candidates[pos.x][pos.y]:
					legal_cells.append(pos) # Num is candidate at cell pos
			if legal_cells.size() == 1: # Only 1 valid pos in unit => hidden single found
				var pos := legal_cells[0]
				_place_value(board, candidates, pos.x, pos.y, num)
				return true
	return false


## A naked pair is a set of exactly 2 candidate numbers sitting in 2 cells that
## share at least 1 common unit. This makes it clear that the solution will 
## contain those values in those 2 cells, so they can be erased as candidates
## from all other cells in the units in common. Finds a naked pair and
## attempts to eliminate those as candidates from cells in the unit the pair was
## found in. Returns true if the naked pair reduced the number of candidates in
## the shared units, returns false otherwise.
## See for explanation: https://www.sudokuwiki.org/Naked_Candidates#NP
@warning_ignore("unused_parameter")
func _apply_naked_pair(board: Array[Array], candidates: Array[Array]) -> bool:
	var board_units := SudokuRules.get_units()
	for unit in board_units:
		# Find cells that contain exactly 2 candidates
		var pair_cells: Array[Vector2i] = []
		for pos in unit:
			if candidates[pos.x][pos.y].size() == 2:
				pair_cells.append(pos)
			
		# Now test every combination of cell pairs to check if the candidates
		# in the cells are equal
		for index_a in range(pair_cells.size()):
			for index_b in range(index_a + 1, pair_cells.size()):
				var pos_a := pair_cells[index_a]
				var pos_b := pair_cells[index_b]
				# Are candidates in the 2 cells equal?
				if candidates[pos_a.x][pos_a.y] == candidates[pos_b.x][pos_b.y]:
					# Naked pair found! Try to remove candidates from other
					# cells in all units they share
					var eliminated := false
					var shared_units = _units_containing_pos(board_units, [pos_a, pos_b])
					for shared_unit in shared_units:
						for pos in shared_unit:
							if pos == pos_a or pos == pos_b:
								continue
							for num in candidates[pos_a.x][pos_a.y]:
								if num in candidates[pos.x][pos.y]:
									candidates[pos.x][pos.y].erase(num)
									eliminated = true
					if eliminated:
						return true
	return false


## A hidden pair is a set of 2 candidate numbers sitting in 2 cells that
## share at least 1 common unit. This makes it clear that the solution will 
## contain those values in those 2 cells, so all other candidates in those cells
## can be removed. Attempts to find a hidden pair and eliminate all other
## candidates in the cells they were found in. Returns true if the hidden pair
## reduced the number of candidates in those cells, returns false otherwise.
## See for explanation: https://www.sudokuwiki.org/Hidden_Candidates#NP
@warning_ignore("unused_parameter")
func _apply_hidden_pair(board: Array[Array], candidates: Array[Array]) -> bool:
	for unit in SudokuRules.get_units():
		var num_locations := {}
		for num in range(1, 10):
			num_locations[num] = []
		for pos in unit:
			for num in candidates[pos.x][pos.y]:
				num_locations[num].append(pos)
		
		# Filter candidates that appear EXACTLY twice in the unit
		var pair_candidates: Array[int] = []
		for num in range(1, 10):
			if num_locations[num].size() == 2:
				pair_candidates.append(num)
		
		# Test every pair of candidates to see if they occupy same 2 cells
		for index_a in range(pair_candidates.size()):
			for index_b in range(index_a + 1, pair_candidates.size()):
				var num_a := pair_candidates[index_a]
				var num_b := pair_candidates[index_b]
				
				# Hidden pair found! Remove all other candidates in the two
				# cells they're found in
				if num_locations[num_a] == num_locations[num_b]:
					var hidden_pair := [num_a, num_b]
					var eliminated := false
					for pos in num_locations[num_a]:
						for candidate in candidates[pos.x][pos.y].duplicate():
							if candidate not in hidden_pair:
								candidates[pos.x][pos.y].erase(candidate)
								eliminated = true
					if eliminated:
						return true
	return false


## In short, if a candidate appears 2-3 times in a box and they happen to
## align on the same row or col, we can remove the num from the list of
## candidates of all cells in the same row/col. This works for pointing pairs
## and pointing triples. Returns true if the pointing pair/triple reduced the
## number of candidates in other cells, returns false otherwise.
## See for explanation: https://www.sudokuwiki.org/Intersection_Removal
@warning_ignore("unused_parameter")
func _apply_pointing_pair(board: Array[Array], candidates: Array[Array]) -> bool:
	# Check each box for a pointing pair/triple, within each box check each num
	for box in SudokuRules.get_boxes():
		for num in range(1, 10):
			var cells_with_num: Array[Vector2i] = []
			for pos in box:
				if num in candidates[pos.x][pos.y]:
					cells_with_num.append(pos)
			
			# Need at least 2 cells with same candidate in box. Allows func to
			# work with pointing triples as well.
			if cells_with_num.size() < 2:
				continue
			
			var first: Vector2i = cells_with_num[0]
			
			# For each cell with num, check if they are all the same row/col
			var same_row := cells_with_num.all(func(p): return p.x == first.x)
			var same_col := cells_with_num.all(func(p): return p.y == first.y)
			if not (same_row or same_col):
				continue
			
			# Get all the pos of the row/col the pointing pair/triple is on
			var line: Array[Vector2i] = _row_cells(first.x) if same_row else _col_cells(first.y)
			
			# Eliminate num from list of candidates in all other cells in line
			var eliminated := false
			for pos in line:
				if pos in box:
					continue  # cells inside the box are handled by other techniques
				if num in candidates[pos.x][pos.y]:
					candidates[pos.x][pos.y].erase(num)
					eliminated = true
			if eliminated:
				return true
	return false


## In short, if we find the same candidate in any row/col, grouped together in
## the same box, we can remove that candidate from all the other cells in that
## box. Returns true if this strategy successfuly removed candidates, false
## otherwise.
## See for explanation: https://www.sudokuwiki.org/Intersection_Removal#LBR
@warning_ignore("unused_parameter")
func _apply_box_line_reduction(board: Array[Array], candidates: Array[Array]) -> bool:
	var lines: Array[Array] = []
	lines.append_array(SudokuRules.get_rows())
	lines.append_array(SudokuRules.get_cols())
	
	for line in lines:
		for num in range(1, 10):
			var cells_with_num: Array[Vector2i] = []
			for pos in line:
				if num in candidates[pos.x][pos.y]:
					cells_with_num.append(pos)
			
			# Num must appear multiple times in line to use this strategy.
			if cells_with_num.size() < 2:
				continue
			
			# Find box containing first cell
			var first := cells_with_num[0]
			var target_box: Array[Vector2i]
			for box in SudokuRules.get_boxes():
				if first in box:
					target_box = box
					break
 			
			# Check if all other cells_with_num are in this box.
			var confined_to_box := true
			for pos in cells_with_num:
				if pos not in target_box:
					confined_to_box = false
					break
			# All candidates must be in same box to use this strategy.
			if not confined_to_box:
				continue
			
			# Eliminate num from list of candidates in all other cells in box
			var eliminated := false
			for pos in target_box:
				if pos in line:
					continue  # cells on the line are handled by other techniques
				if num in candidates[pos.x][pos.y]:
					candidates[pos.x][pos.y].erase(num)
					eliminated = true
 			
			if eliminated:
				return true
	return false
 
