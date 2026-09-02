class_name SudokuPuzzle extends RefCounted

var player_board: Array[Array] ## The board the player uses to play the game.
var notes_board: Array[Array] # TODO: Array[Array[Array[int]]]
var solution_board: Array[Array] ## The end goal of the player's board.
var mistakes: int = 0 ## The number of mistakes the player has made.

# TODO: add puzzle stats :)
var difficulty
var max_technique_tier

## Places num at the given position and clears any notes there, since a
## filled cell can't also hold pencil marks. This is the ONLY place
## player_board should be written to during play.
func set_value(pos: Vector2i, num: int) -> void:
	var row = pos.x
	var col = pos.y
	player_board[row][col] = num
	(notes_board[row][col] as Array).clear()


## Toggles num in the notes at the given position. Returns true if the note
## was added, false if it was removed.
func toggle_note(pos: Vector2i, num: int) -> bool:
	var row = pos.x
	var col = pos.y
	if num in notes_board[row][col]:
		notes_board[row][col].erase(num)
		return false
	else:
		notes_board[row][col].append(num)
		return true


## Returns the current notes at the given position.
func get_notes(pos: Vector2i) -> Array[int]:
	return notes_board[pos.x][pos.y]


## Prints the specified board to the console in an easy to see way.
func print_board(board: Array[Array]) -> void:
	for row in board:
		print(row)


## Checks if the requested input matches the solution board.
func is_solution(pos: Vector2i, num: int) -> bool:
	if num == solution_board[pos.x][pos.y]:
		return true
	return false


## Returns true if the player's board is completely filled in and matches
## the solution board.
func is_complete() -> bool:
	return player_board == solution_board
