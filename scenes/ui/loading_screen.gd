extends CanvasLayer

## Full-screen loading indicator, shown ONLY when PuzzlePool has no puzzle
## ready and generation has to happen live. Most of the time (pool
## pre-filled), this should never appear at all.

@onready var flavor_label: Label = %FlavorLabel
@onready var spinner: TextureProgressBar = %Spinner  # a simple icon, rotated by an AnimationPlayer

var _flavor_texts := [
	"Shuffling numbers...",
	"Hunting for naked singles...",
	"Untangling hidden pairs...",
	"Double-checking every box...",
	"Making sure there's only one answer...",
]
var _flavor_timer: Timer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep spinning even if paused elsewhere
	hide()
	
	_flavor_timer = Timer.new()
	_flavor_timer.wait_time = 3
	_flavor_timer.timeout.connect(_cycle_flavor_text)
	add_child(_flavor_timer)


func show_loading() -> void:
	flavor_label.text = _flavor_texts[0]
	_flavor_timer.start()
	show()


func hide_loading() -> void:
	_flavor_timer.stop()
	hide()


func _cycle_flavor_text() -> void:
	flavor_label.text = _flavor_texts.pick_random()
