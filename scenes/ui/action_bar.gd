extends HBoxContainer

#@onready var undo_button: Button = %UndoButton
#@onready var erase_button: Button = %EraseButton
#@onready var hint_button: Button = %HintButton


func _on_undo_button_pressed() -> void:
	GameEvents.emit_undo_requested()


func _on_erase_button_pressed() -> void:
	GameEvents.emit_erase_requested()


func _on_hint_button_pressed() -> void:
	GameEvents.emit_hint_requested()
