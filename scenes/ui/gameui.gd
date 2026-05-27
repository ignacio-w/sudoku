extends CanvasLayer

@onready var board: MarginContainer = %Board

func _ready() -> void:
	pass


func reflect(board_array: Array[Array]) -> void:
	board.create_visual_board(board_array)
