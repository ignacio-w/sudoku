extends PanelContainer
class_name Cell

@onready var number_label: Label = %Number
@onready var notes_container: GridContainer = %NotesContainer

const EMPTY = ""
enum CellState {
	DEFAULT, ## Normal cell state; no highlights
	SELECTED, ## Focused cell
	CONFLICT_HIGHLIGHT, ## Conflict to the focused cell
	EQUAL_HIGHLIGHT ## Equal in value to the focused cell
	
	}

var font_ratio: float # font size / cell size; for future use
var is_clue: bool
var state: CellState
var value: int
var board_pos: Vector2i
var notes: Array[int]
var cell_styles: Dictionary[String, StyleBoxFlat]

signal cell_highlighted(cell: Cell)
signal cell_selected(cell: Cell)
signal reset_highlight
# TODO: Cell selection
# - Highlight cell
# - Wait for input
# - Display number input if number clicked
# - When focus is gone, stop highlighting


func _init() -> void:
	is_clue = false
	state = CellState.DEFAULT
	
	# Create styleboxes
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(5)
	style.set_border_width_all(2)
	style.bg_color = Color("212121ff")
	style.border_color = Color("004d46")
	cell_styles["empty"] = style.duplicate(true)
	style.bg_color = Color("361a1a")
	style.border_color = Color.RED
	cell_styles["selected"] = style.duplicate(true)
	style.bg_color = Color("133b13ff")
	style.border_color = Color.GREEN
	cell_styles["val_selected"] = style.duplicate(true)
	style.bg_color = Color("1a1a1a")
	style.border_color = Color.INDIAN_RED
	cell_styles["conflict_highlight"] = style.duplicate(true)
	style.bg_color = Color("132613ff")
	style.border_color = Color("00c500ff")
	cell_styles["num_highlight"] = style.duplicate(true)
	style.bg_color = Color("212121ff")
	style.border_color = Color("008500ff")
	cell_styles["note_highlight"] = style.duplicate(true)

func _ready() -> void:
	# Empty number label, set default stylebox, make all notes invisibile
	font_ratio = number_label.get_theme_font_size("font_size") / size.y
	number_label.text = EMPTY
	cell_styles["default"] = get_theme_stylebox("panel")
	number_label.show()
	notes_container.hide()
	for label: Label in notes_container.get_children():
		label.modulate = Color.TRANSPARENT


## Called when the cell recieves an input event (mouse enter, click, etc.)
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		print("cell clicked with value ", number_label.text, " and is clue: ", is_clue)
		emit_clicked_signal()


func emit_clicked_signal(input_validation: bool = true):
	# Cells that aren't clues can be SELECTED (filled)
	# NOTICE: Behavior below assumes inputs are validated
	if input_validation:
		if value == 0:
			if state != CellState.SELECTED:
				cell_selected.emit(self)
			else:
				reset_highlight.emit()
		# Cells that are clues can ONLY be highlighted
		else:
			if state != CellState.EQUAL_HIGHLIGHT:
				cell_highlighted.emit(self)
			else:
				reset_highlight.emit()
	else:
	# NOTICE: Behavior without input validation
		if not is_clue:
			if state != CellState.SELECTED:
				cell_selected.emit(self)
			else:
				reset_highlight.emit()
		# Cells that are clues can only be highlighted
		else:
			if state != CellState.EQUAL_HIGHLIGHT:
				cell_highlighted.emit(self)
			else:
				reset_highlight.emit()

## Sets the value of the cell to the given clue
func set_clue(clue: int, pos: Vector2i) -> void:
	value = clue
	board_pos = pos
	if clue == 0:
		number_label.text = EMPTY
		add_theme_stylebox_override("panel", cell_styles["empty"])
	else:
		number_label.text = str(clue)
		is_clue = true
		add_theme_stylebox_override("panel", cell_styles["default"])


## Sets the value of the cell to the given number. Use this function for user
## input.
func set_value(num: int) -> void:
	value = num
	
	# Change stylebox
	number_label.remove_theme_color_override("font_color")
	number_label.add_theme_color_override("font_color", Color.DEEP_SKY_BLUE)
	number_label.text = str(value)
	add_theme_stylebox_override("panel", cell_styles["empty"])
	
	# Reset all notes to none
	notes.clear()
	for note in notes_container.get_children(): note.hide()
	notes_container.hide()
	number_label.show()
	
	# Emit signals
	GameEvents.emit_cell_value_changed(self)


## Toggle the placement of the specified number in the notes.
func toggle_note(num: int) -> void:
	var note_label: Label = notes_container.get_children()[num - 1]
	# Toggle note visibility
	if num in notes:
		notes.erase(num)
		note_label.modulate = Color.TRANSPARENT
	else:
		notes.append(num)
		note_label.modulate = Color.WHITE
	
	# If there are ANY notes, toggle visibility of notes container on.
	if notes.size() > 0:
		number_label.hide()
		notes_container.show()
	else:
		number_label.show()
		notes_container.hide()


## Changes the stylebox to match the chosen state.
func set_state(cell_state: CellState = CellState.DEFAULT) -> void:
	remove_theme_stylebox_override("panel")
	
	match cell_state:
		CellState.DEFAULT:
			if value == 0:
				add_theme_stylebox_override("panel", cell_styles["empty"])
			else:
				add_theme_stylebox_override("panel", cell_styles["default"])
			state = CellState.DEFAULT
		CellState.SELECTED:
			if value == 0:
				add_theme_stylebox_override("panel", cell_styles["selected"])
			else:
				add_theme_stylebox_override("panel", cell_styles["val_selected"])
			state = CellState.SELECTED
		CellState.CONFLICT_HIGHLIGHT:
			add_theme_stylebox_override("panel", cell_styles["conflict_highlight"])
			state = CellState.CONFLICT_HIGHLIGHT
		CellState.EQUAL_HIGHLIGHT:
			if notes.is_empty(): # different stylebox for notes vs completed cell
				add_theme_stylebox_override("panel", cell_styles["num_highlight"])
			else:
				add_theme_stylebox_override("panel", cell_styles["note_highlight"])
			state = CellState.EQUAL_HIGHLIGHT
