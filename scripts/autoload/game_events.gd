extends Node

signal undo_requested
signal hint_requested
signal erase_requested

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("GameEvents Singleton loaded and ready!")

func emit_undo_requested() -> void:
	print("Undo requested!")
	undo_requested.emit()

func emit_hint_requested() -> void:
	print("Hint requested!")
	hint_requested.emit()

func emit_erase_requested() -> void:
	print("Erasure requested!")
	erase_requested.emit()
