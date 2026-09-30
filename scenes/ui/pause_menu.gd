extends CanvasLayer

@onready var difficulty: Label = %Difficulty
@onready var time: Label = %Time
@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.grab_focus()
	get_tree().paused = true
	match GameManager.cur_difficulty:
		SudokuGenerator.Difficulty.EASY:
			difficulty.text = "Easy Puzzle"
		SudokuGenerator.Difficulty.MEDIUM:
			difficulty.text = "Medium Puzzle"
		SudokuGenerator.Difficulty.HARD:
			difficulty.text = "Hard Puzzle"
		_:
			difficulty.text = "Puzzle in Progress"
			push_warning("Difficulty not found")
	
	# TODO: Get time in a safer way
	time.text = (get_parent().game_ui as GameUI).stopwatch.text


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = false
		queue_free()
		get_viewport().set_input_as_handled()


func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	queue_free()


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
