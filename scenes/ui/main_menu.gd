extends CanvasLayer

const GAME_SCENE = preload("uid://ckyn5pj7dq8xq")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_easy_pressed() -> void:
	start_game(Sudoku.Difficulty.EASY)


func _on_medium_pressed() -> void:
	start_game(Sudoku.Difficulty.MEDIUM)


func _on_hard_pressed() -> void:
	start_game(Sudoku.Difficulty.HARD)
	


func start_game(difficulty: Sudoku.Difficulty) -> void:
	GameManager.cur_difficulty = difficulty
	get_tree().change_scene_to_packed(GAME_SCENE)
