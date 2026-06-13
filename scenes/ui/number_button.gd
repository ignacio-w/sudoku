extends PanelContainer
class_name NumberButton

@onready var number_label: Label = %Number

var value: int
var is_enabled: bool # Purely cosmetic, doesn't change functionality

signal number_button_clicked(num: NumberButton)


func _ready() -> void:
	is_enabled = true


func set_value(val: int) -> void:
	value = val
	number_label.text = str(value)


## Set the button to inactive or active
func set_inactive(inactive: bool = true):
	is_enabled = not inactive
	if is_enabled:
		number_label.remove_theme_color_override("font_color")
	else:
		number_label.add_theme_color_override("font_color", Color.DIM_GRAY)


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
		number_button_clicked.emit(self)
