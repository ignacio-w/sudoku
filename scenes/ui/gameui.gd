extends CanvasLayer

@onready var board: MarginContainer = %Board
@onready var number_selector: GridContainer = %NumberSelector
const NUMBER_BUTTON = preload("uid://lvsotrxoqrq6")

func _ready() -> void:
	pass


# Creates a Sodoku board visually given a Sodoku board. The Sodoku board is
# exactly what should be reflected at the start of the game. The given board
# is not a solved, solution board.
func reflect(board_array: Array[Array]) -> void:
	board.create_visual_board(board_array)


## Creates the number buttons used to input numbers into the Sodoku board
func setup():
	for child in number_selector.get_children():
		child.queue_free()
	
	for num in range(1, 10):
		var num_button = NUMBER_BUTTON.instantiate()
		number_selector.add_child(num_button)
		num_button.set_value(num)
		num_button.number_button_clicked.connect(_on_num_button_clicked)


## Receives the number button clicked signal from number buttons. The argument
## represents the number the button represents.
func _on_num_button_clicked(num: int) -> void:
	print("Received signal")
	# Get selected cell
	
	# Put value in selected cell
