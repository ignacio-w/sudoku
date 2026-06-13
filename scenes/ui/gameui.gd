extends CanvasLayer

@onready var board: MarginContainer = %Board
@onready var number_selector: GridContainer = %NumberSelector
const NUMBER_BUTTON = preload("uid://lvsotrxoqrq6")

func _ready() -> void:
	GameEvents.cell_value_changed.connect(_on_cell_value_changed)
	for child in number_selector.get_children():
		child.queue_free()


## Sets up all visual nodes. Creates a visual Sodoku board given a 2D Array of numbers
## representing the board. The Sodoku board should be exactly what is reflected
## at the start of the game. The given board should not a solved, solution board.
## Also creates the number buttons used to input numbers into the Sodoku board
func setup(board_array: Array[Array]):
	for child in number_selector.get_children():
		child.queue_free()
	
	for num in range(1, 10):
		var num_button = NUMBER_BUTTON.instantiate()
		number_selector.add_child(num_button)
		num_button.set_value(num)
		num_button.number_button_clicked.connect(_on_num_button_clicked)
	
	board.create_visual_board(board_array)


## Receives the number button clicked signal from number buttons. The argument
## is the number button that emitted the signal. Checks if button is disabled
## before setting the value of the focused cell.
func _on_num_button_clicked(num_button: NumberButton) -> void:
	print("Received signal")
	
	# Get selected cell (if any)
	var f_cell: Cell = board.focused_cell
	# Make sure focused cell is able to accept input
	if f_cell == null or f_cell.is_clue: return
	
	# Check if number button is disabled
	if num_button.is_enabled:
		# Put value in selected cell
		f_cell.set_value(num_button.value)


## Sets the value of a selected cell to the player's keyboard input. Handles
## checks to see if the number can be placed.
func _unhandled_key_input(event: InputEvent) -> void:
	var cell: Cell = board.focused_cell
	if cell == null or cell.state != Cell.CellState.SELECTED: return
	if not event.is_pressed() or event.is_echo(): return
	
	var key_event = event as InputEventKey
	var num = int(char(key_event.unicode)) # 0 if 0 or not a number
	if num != 0:
		# Get corresponding number button; check if enabled to place
		for button in number_selector.get_children():
			if (button as NumberButton).value == num:
				if (button as NumberButton).is_enabled:
					cell.set_value(num)
				break
		get_viewport().set_input_as_handled()


## Receives the cell_value_changed signal from the GameEvents autoload (cells).
## This should only be used if the board doesn't allow incorrect inputs so
## number inputs are not disabled when the player actually needs them.
func _on_cell_value_changed(cell_changed: Cell) -> void:
	# Check if there are 9 of the selected number already in the board
	var num_count: int = 0
	for row in board.cell_grid:
		for cell in row:
			if (cell as Cell).value == cell_changed.value:
				num_count += 1
			if num_count == 9:
				number_selector.get_children()[cell_changed.value - 1].set_inactive()
				return
