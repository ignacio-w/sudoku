extends Node

signal cell_value_changed(cell: Cell)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## Called by cells when the value inside of them changes.
func emit_cell_value_changed(cell: Cell):
	cell_value_changed.emit(cell)
