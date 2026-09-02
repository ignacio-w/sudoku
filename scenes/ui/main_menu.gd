extends CanvasLayer

const GAME_SCENE = preload("uid://ckyn5pj7dq8xq")

## TODO: Add settings menu that persists on quit
## - Features, cosmetic changes, etc.



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start generating puzzles in the background
	for difficulty in SudokuGenerator.Difficulty.values():
		PuzzlePool.request_refill(difficulty)


func _on_easy_pressed() -> void:
	start_game(SudokuGenerator.Difficulty.EASY)


func _on_medium_pressed() -> void:
	start_game(SudokuGenerator.Difficulty.MEDIUM)


func _on_hard_pressed() -> void:
	start_game(SudokuGenerator.Difficulty.HARD)


func _on_experiments_pressed() -> void:
	pass # Replace with function body.


func start_game(difficulty: SudokuGenerator.Difficulty) -> void:
	# use later when implementing loading screen
	#GameManager.pending_puzzle = PuzzlePool.take_puzzle(difficulty)
	GameManager.cur_difficulty = difficulty
	get_tree().change_scene_to_packed(GAME_SCENE)
