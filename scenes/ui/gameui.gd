class_name GameUI extends CanvasLayer

@onready var board: MarginContainer = %Board
@onready var number_selector: GridContainer = %NumberSelector
@onready var strike_number: Label = %StrikeNumber
const NUMBER_BUTTON = preload("uid://lvsotrxoqrq6")

var strikes: int
signal num_input_requested(cell: Cell, num: int)

func _ready() -> void:
	strikes = 0
	strike_number.text = str(strikes)
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
		# Connect the number_button_clicked signal to function in this node.
		num_button.number_button_clicked.connect(_on_num_button_clicked)
	
	board.create_visual_board(board_array)


func increment_strikes():
	strikes += 1
	strike_number.text = str(strikes)



## Receives the number button clicked signal from number buttons. The argument
## is the number button that emitted the signal. Sends input along with
## focused_cell to game to determine how to handle input.
func _on_num_button_clicked(num_button: NumberButton) -> void:
	print("Received number button signal")
	
	var focused_cell: Cell = board.focused_cell
	
	# Check if a cell is foucsed
	if focused_cell == null: return
	# Check if cell is empty
	if focused_cell.value != 0: return
	
	var num: int = num_button.value
	# Send Game an input request
	num_input_requested.emit(focused_cell, num)
	
	# TODO Delete everything below, let game parent control when to set value
	
	## Check if number button is disabled
	#if num_button.is_enabled:
		## Put value in selected cell
		#focused_cell.set_value(num_button.value)


## Receives the cell_value_changed signal from the GameEvents autoload (cells).
## Disables number input buttons when 9 of the number are found on the board.
## NOTICE: This should only be used if the board doesn't allow incorrect inputs 
## so number inputs are not disabled when the player actually needs them.
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
