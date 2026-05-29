extends PanelContainer

@onready var grid_container: GridContainer = %GridContainer
const CELL = preload("uid://dbdear076ofrm")

var sub_grid_pos: Vector2i

func _ready() -> void:
	reset_cells()


func get_cells() -> Array[Cell]:
	var cell_list: Array[Cell] = []
	for child in grid_container.get_children():
		cell_list.append(child)
	return cell_list


func add_cell(cell: Cell):
	grid_container.add_child(cell)


func reset_cells():
	for child in grid_container.get_children():
		child.queue_free()
