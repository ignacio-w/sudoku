extends MarginContainer

@onready var sodoku_grid: GridContainer = %SodokuGrid
@export var cell: PackedScene
@export var board: Array[Array] # for testing only


func _ready() -> void:
	clear_board()


func create_visual_board(sodoku_board: Array[Array]):
	for row in sodoku_board:
		for value in row:
			var new_cell = cell.instantiate()
			sodoku_grid.add_child(new_cell)
			new_cell.set_value(value)


func update_board():
	pass

func highlight_cells():
	pass

func clear_board():
	for container in sodoku_grid.get_children():
		container.queue_free()
