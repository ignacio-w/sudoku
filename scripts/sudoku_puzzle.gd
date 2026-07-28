class_name SudokuPuzzle extends RefCounted

var player_board: Array[Array] ## The board the player uses to play the game.
var notes_board: Array[Array] # TODO
var solution_board: Array[Array] ## The end goal of the player's board.
var mistakes: int = 0 ## The number of mistakes the player has made.


## Prints the specified board to the console in an easy to see way.
func print_board(board: Array[Array]) -> void:
	for row in board:
		print(row)


## Checks if the requested input matches the solution board.
func is_solution(row: int, col: int, num: int) -> bool:
	if num == solution_board[row][col]:
		return true
	return false


## Returns true if the player's board is completely filled in and matches
## the solution board.
func is_complete() -> bool:
	return player_board == solution_board
