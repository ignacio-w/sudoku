extends PanelContainer
class_name Cell

@onready var number: Label = %Number
@onready var notes_container: GridContainer = %NotesContainer
const EMPTY = ""
enum CellState {DEFAULT, SELECTED, NUM_HIGHLIGHT, CONFLICT_HIGHLIGHT}

var font_ratio: float # font size / cell size; for future use
var is_clue: bool
var state: CellState
var value: int
var board_pos: Vector2i
var notes: Array[int]
var cell_styles: Dictionary[String, StyleBoxFlat]

signal cell_highlighted(cell: Cell)
signal cell_selected(cell: Cell)
signal cell_value_changed(cell: Cell)
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
	style.bg_color = Color("361a1a")
	style.set_border_width_all(2)
	style.border_color = Color.RED
	style.set_corner_radius_all(5)
	cell_styles["selected"] = style.duplicate(true)
	style.bg_color = Color("1a1a1a")
	style.border_color = Color.INDIAN_RED
	cell_styles["conflict_highlight"] = style.duplicate(true)
	style.border_color = Color.GREEN
	style.bg_color = Color("1a341a")
	cell_styles["num_highlight"] = style.duplicate(true)

func _ready() -> void:
	font_ratio = number.get_theme_font_size("font_size") / size.y
	number.text = EMPTY
	cell_styles["default"] = get_theme_stylebox("panel")


## Called when the cell recieves an input event (mouse enter, click, etc.)
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		print("cell clicked with value ", number.text, " and is clue: ", is_clue)
		# Cells that aren't clues can be SELECTED (filled)
		if not is_clue:
			if state != CellState.SELECTED:
				cell_selected.emit(self)
			else:
				reset_highlight.emit()
		# Cells that are clues can only be highlighted
		else:
			if state != CellState.NUM_HIGHLIGHT:
				cell_highlighted.emit(self)
			else:
				reset_highlight.emit()


## Sets the value of a selected cell to the player's keyboard input.
func _unhandled_key_input(event: InputEvent) -> void:
	if state != CellState.SELECTED: return
	
	var key_event = event as InputEventKey
	if event.is_pressed() and not event.is_echo():
		if key_event.unicode != 0:
			var num = int(char(key_event.unicode))
			if num != 0:
				set_value(num)


## Sets the value of the cell to the given clue
func set_clue(clue: int, pos: Vector2i) -> void:
	value = clue
	board_pos = pos
	if clue == 0:
		number.text = EMPTY
	else:
		number.text = str(clue)
		is_clue = true


## Sets the value of the cell to the given number. Use this for user
## input.
func set_value(num: int) -> void:
	value = num
	number.remove_theme_color_override("font_color")
	number.add_theme_color_override("font_color", Color.ROYAL_BLUE)
	number.text = str(value)
	cell_value_changed.emit(self)


## Changes the stylebox if selected
func set_state(cell_state: CellState = CellState.DEFAULT) -> void:
	remove_theme_stylebox_override("panel")
	
	## If the current state is equal to the 
	#if state == cell_state:
		#cell_state = CellState.DEFAULT
	
	match cell_state:
		CellState.DEFAULT:
			add_theme_stylebox_override("panel", cell_styles["default"])
			state = CellState.DEFAULT
		CellState.SELECTED:
			add_theme_stylebox_override("panel", cell_styles["selected"])
			state = CellState.SELECTED
		CellState.CONFLICT_HIGHLIGHT:
			add_theme_stylebox_override("panel", cell_styles["conflict_highlight"])
			state = CellState.CONFLICT_HIGHLIGHT
		CellState.NUM_HIGHLIGHT:
			add_theme_stylebox_override("panel", cell_styles["num_highlight"])
			state = CellState.NUM_HIGHLIGHT
			
