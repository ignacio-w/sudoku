extends CanvasLayer

@onready var time: Label = %Time

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	
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
	get_tree().quit(0)
