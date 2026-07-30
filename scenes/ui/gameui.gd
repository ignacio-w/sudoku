class_name GameUI extends CanvasLayer

signal num_input_requested(cell: Cell, num: int, is_notes_mode: bool)

const NUMBER_BUTTON = preload("uid://lvsotrxoqrq6")

var notes_mode: bool

@onready var board: BoardUI = %Board
@onready var number_selector: GridContainer = %NumberSelector
@onready var mistake_label: Label = %Mistakes
@onready var stopwatch: Stopwatch = %Stopwatch


func _ready() -> void:
	mistake_label.text = "Mistakes: 0"
	for child in number_selector.get_children():
		child.queue_free()


## Sets up all visual nodes. Creates a visual Sudoku board given a 2D array of
## numbers representing the board. The given Sudoku board is reflected at the 
## start of the game. The given board should not a solved, solution board. Also
## creates the number buttons used to input numbers into the Sudoku board and
## starts the stopwatch.
func setup(board_array: Array[Array]):
	for child in number_selector.get_children():
		child.queue_free()
	
	for num in range(1, 10):
		var num_button = NUMBER_BUTTON.instantiate()
		number_selector.add_child(num_button)
		num_button.set_value(num)
		# Connect the number_button_clicked signal to function in this node.
		num_button.number_button_clicked.connect(_on_num_button_clicked)
	
	await board.create_visual_board(board_array)
	update_number_buttons_active_state()
	stopwatch.start(3)


## Sets the mistake counter to the parameter.
func update_mistakes(s: int) -> void:
	mistake_label.text = "Mistakes: " + str(s)


## Disables number input button if 9 of specified number are found on the board.
## NOTICE: This should only be used if the board doesn't allow incorrect inputs 
## so number inputs are not disabled when the player actually needs them.
func update_number_buttons_active_state() -> void:
	for num in range(1, 10):
		var num_count: int = 0
		for row in board.cell_grid:
			for cell: Cell in row:
				if cell.value == num:
					num_count += 1
		if num_count == 9:
			number_selector.get_children()[num - 1].set_inactive()
		else:
			number_selector.get_children()[num - 1].set_inactive(false)


## Receives the number button clicked signal from number buttons. The argument
## is the number button that emitted the signal. Sends input along with
## focused_cell to game to determine how to handle input.
func _on_num_button_clicked(num_button: NumberButton) -> void:
	print("Received number button signal")
	
	var focused_cell: Cell = board.focused_cell
	# Can't put number in unfocused cell or cell already filled
	if focused_cell == null or focused_cell.value != 0:
		num_button.animation_player.stop()
		num_button.animation_player.play("warning")
		return
	
	# Send Game an input request
	num_input_requested.emit(focused_cell, num_button, notes_mode)


## Change all number buttons to note mode or normal mode.
func _on_notes_toggle_toggled(toggled_on: bool) -> void:
	notes_mode = toggled_on
	for num_button: NumberButton in number_selector.get_children():
		num_button.set_note_mode(notes_mode)
