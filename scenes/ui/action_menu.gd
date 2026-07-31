extends VBoxContainer

#@onready var undo_button: Button = %UndoButton
#@onready var erase_button: Button = %EraseButton
@onready var hint_button: Button = %HintButton
@onready var hints: Label = %Hints

var hints_given: int

func _ready() -> void:
	hints_given = 0
	hints.text = "Hints left: 3"


func _on_undo_button_pressed() -> void:
	GameEvents.emit_undo_requested()


func _on_erase_button_pressed() -> void:
	GameEvents.emit_erase_requested()


func _on_hint_button_pressed() -> void:
	hints_given += 1
	hints.text = "Hints left: %d" % (3 - hints_given)
	GameEvents.emit_hint_requested()
	if hints_given >= 3:
		hint_button.disabled = true
