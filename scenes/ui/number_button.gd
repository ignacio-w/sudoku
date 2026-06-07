extends PanelContainer
class_name NumberButton

@onready var number: Label = %Number

var value: int

signal number_button_clicked(num: int)


func _ready() -> void:
	pass # Replace with function body.


func set_value(val: int) -> void:
	value = val
	number.text = str(value)


## Forces the cell to be square when the resized signal is emitted
func _force_square() -> void:
	if size.x > size.y:
		custom_minimum_size.y = size.x
	else:
		custom_minimum_size.x = size.y


## Receives GUI input events
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		print("Number input received! ", str(value))
		number_button_clicked.emit(value)
