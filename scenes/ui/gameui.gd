extends CanvasLayer

@onready var board: MarginContainer = %Board
@onready var number_selector: GridContainer = %NumberSelector
const NUMBER_BUTTON = preload("uid://lvsotrxoqrq6")

func _ready() -> void:
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
	# Once everything has been created, update the board size to take
	# up available space on screen
	#await get_tree().process_frame
	#await board.resize_elements()


## Receives the number button clicked signal from number buttons. The argument
## represents the number the button represents.
func _on_num_button_clicked(num: int) -> void:
	print("Received signal")
	# Get selected cell
	var cell: Cell = board.focused_cell
	if cell == null or cell.is_clue: return
	
	# Put value in selected cell
	cell.set_value(num)
