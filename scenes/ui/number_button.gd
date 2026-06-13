extends PanelContainer
class_name NumberButton

@onready var number: Label = %Number

var value: int
var is_enabled: bool

signal number_button_clicked(num: int)


func _ready() -> void:
	is_enabled = true


func set_value(val: int) -> void:
	value = val
	number.text = str(value)


## Set the button to inactive or active
func set_inactive(inactive: bool = true):
	is_enabled = not inactive
	if is_enabled:
		number.remove_theme_color_override("font_color")
	else:
		number.add_theme_color_override("font_color", Color.DIM_GRAY)


## Forces the cell to be square when the resized signal is emitted
func _force_square() -> void:
	if size.x > size.y:
		custom_minimum_size.y = size.x
	else:
		custom_minimum_size.x = size.y


## Receives GUI input events
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select") and is_enabled:
		print("Number input received! ", str(value))
		number_button_clicked.emit(value)
