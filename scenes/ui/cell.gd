extends PanelContainer

@onready var number: Label = %Number

var is_clue: bool
const EMPTY = ""


func _ready() -> void:
	number.text = EMPTY


func set_value(value: int) -> void:
	if value == 0:
		number.text = EMPTY
	else:
		number.text = str(value)

# TODO: Cell selection
# - Highlight cell
# - Wait for input
# - Display number input if number clicked
# - When focus is gone, stop highlighting


## Called when the cell recieves an input event (mouse enter, click, etc.)
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		print("cell clicked")
