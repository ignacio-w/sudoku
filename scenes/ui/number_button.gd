extends PanelContainer
class_name NumberButton

@onready var number_label: Label = %Number
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var value: int
var is_enabled: bool # Purely cosmetic, doesn't change functionality
var styleboxes: Dictionary[String, StyleBoxFlat]

signal number_button_clicked(num: NumberButton)


func _ready() -> void:
	is_enabled = true
	styleboxes["default"] = get_theme_stylebox("panel")
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel").duplicate(true)
	stylebox.bg_color = Color("303030")
	styleboxes["clicked"] = stylebox


## Sets the number that this button should represent
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


## Receives GUI input events. Emits the number_button_clicked signal
## when clicked.
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		print("Number input received! ", str(value))
		number_button_clicked.emit(self)


## Handles keyboard input for the number this button represents. 
## If a key equal to the number this represents is pressed, emit the 
## number_button_clicked signal as if the user had clicked this button.
func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	
	var key_event = event as InputEventKey
	var num := int(char(key_event.unicode)) if key_event.unicode != 0 else 0
	if num == value:
		print("Number input received! ", str(value))
		number_button_clicked.emit(self)
		get_viewport().set_input_as_handled()


## Changes stylebox on mouse hover.
func _on_mouse_entered() -> void:
	remove_theme_stylebox_override("panel")
	add_theme_stylebox_override("panel", styleboxes["clicked"])

## Changes stylebox on mouse exit.
func _on_mouse_exited() -> void:
	remove_theme_stylebox_override("panel")
	add_theme_stylebox_override("panel", styleboxes["default"])
