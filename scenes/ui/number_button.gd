extends PanelContainer
class_name NumberButton

@onready var number_label: Label = %Number
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var value: int
var is_enabled: bool # Purely cosmetic, doesn't change functionality
var is_note_button: bool
var styleboxes: Dictionary[String, StyleBoxFlat]

signal number_button_clicked(num: NumberButton)


func _ready() -> void:
	is_enabled = true
	is_note_button = false
	var stylebox: StyleBoxFlat = StyleBoxFlat.new()
	stylebox.bg_color = Color("1a1a1a")
	stylebox.border_color = Color.ROYAL_BLUE
	stylebox.set_border_width_all(2)
	stylebox.set_corner_radius_all(5)
	styleboxes["default"] = stylebox.duplicate(true)
	stylebox.bg_color = Color("303030")
	styleboxes["clicked"] = stylebox.duplicate(true)
	stylebox.bg_color = Color("a6a6a6")
	styleboxes["notes"] = stylebox.duplicate(true)
	stylebox.bg_color = Color("737373ff")
	styleboxes["notes_clicked"] = stylebox.duplicate(true)
	stylebox.bg_color = Color("4d4d4dff")
	styleboxes["in_notes"] = stylebox.duplicate(true)

## Sets the number that this button should represent
func set_value(val: int) -> void:
	value = val
	number_label.text = str(value)
	set_inactive(false)
	set_note_mode(false)


## Set the button to inactive or active
func set_inactive(inactive: bool = true):
	is_enabled = not inactive
	if is_enabled:
		number_label.remove_theme_color_override("font_color")
	else:
		number_label.add_theme_color_override("font_color", Color.DIM_GRAY)


## Set the button to note mode or normal mode. 
func set_note_mode(note_mode: bool = true):
	is_note_button = note_mode
	if is_note_button:
		number_label.remove_theme_color_override("font_color")
		number_label.add_theme_color_override("font_color", Color("242424"))
		remove_theme_stylebox_override("panel")
		add_theme_stylebox_override("panel", styleboxes["notes"])
	else:
		number_label.remove_theme_color_override("font_color")
		remove_theme_stylebox_override("panel")
		add_theme_stylebox_override("panel", styleboxes["default"])
	if not is_enabled:
		number_label.remove_theme_color_override("font_color")
		number_label.add_theme_color_override("font_color", Color.DIM_GRAY)
		


## Forces the cell to be square when the resized signal is emitted
func _force_square() -> void:
	if size.x > size.y:
		custom_minimum_size.y = size.x
	else:
		custom_minimum_size.x = size.y


## Receives GUI input events. Emits the number_button_clicked signal
## when clicked. Does not emit signal if inactive and note in not mode.
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		if is_enabled or is_note_button:
			print("Number input received! ", str(value))
			number_button_clicked.emit(self)


## Handles keyboard input for the number this button represents. 
## If a key equal to the number this represents is pressed, emit the 
## number_button_clicked signal as if the user had clicked this button.
func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	if not is_note_button and not is_enabled: return
	
	var key_event = event as InputEventKey
	var num := int(char(key_event.unicode)) if key_event.unicode != 0 else 0
	if num == value:
		print("Number input received! ", str(value))
		number_button_clicked.emit(self)
		get_viewport().set_input_as_handled()


## Changes stylebox on mouse hover.
func _on_mouse_entered() -> void:
	if is_note_button:
		remove_theme_stylebox_override("panel")
		add_theme_stylebox_override("panel", styleboxes["notes_clicked"])
	elif is_enabled:
		remove_theme_stylebox_override("panel")
		add_theme_stylebox_override("panel", styleboxes["clicked"])


## Changes stylebox on mouse exit.
func _on_mouse_exited() -> void:
	if is_note_button:
		remove_theme_stylebox_override("panel")
		add_theme_stylebox_override("panel", styleboxes["notes"])
	elif is_enabled:
		remove_theme_stylebox_override("panel")
		add_theme_stylebox_override("panel", styleboxes["default"])
