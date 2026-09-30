extends VBoxContainer

@onready var undo_button: Button = %UndoButton
@onready var erase_button: Button = %EraseButton
@onready var hint_button: Button = %HintButton
@onready var hints: Label = %Hints

var hints_remaining: int = 3
var buttons: Array[Button] = [undo_button, erase_button, hint_button]

func _ready() -> void:
	hints.text = "Hints left: %d" % hints_remaining
	

func set_tab_focus(path: NodePath):
	for button in buttons:
		button.focus_next = path
		button.focus_previous = path


func _on_focus_entered() -> void:
	undo_button.grab_focus()


func _on_undo_button_pressed() -> void:
	GameEvents.emit_undo_requested()


func _on_erase_button_pressed() -> void:
	GameEvents.emit_erase_requested()


func _on_hint_button_pressed() -> void:
	hints_remaining -= 1
	hints.text = "Hints left: %d" % hints_remaining
	GameEvents.emit_hint_requested()
	if hints_remaining == 0:
		hint_button.disabled = true
