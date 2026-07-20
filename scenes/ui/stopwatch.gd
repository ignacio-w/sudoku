class_name Stopwatch extends Label

var time_elapsed: float
var paused: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	paused = true
	text = "-:--"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not paused:
		text = _format_time()
		time_elapsed += delta


func _format_time() -> String:
	var hours := floori(time_elapsed / 60 / 60)
	var minutes := floori(time_elapsed / 60) % 60
	var seconds := floori(time_elapsed) % 60
	var formatted_time: String
	if hours < 1:
		if minutes < 1:
			formatted_time = ":%02d" % seconds
		else:
			formatted_time = "%2d:%02d" % [minutes, seconds]
	else:
		formatted_time = "%2d:%02d:%02d" % [hours, minutes, seconds]
	
	return formatted_time

## Reset the stop watch to zero. Stops and sets the stopwatch to exactly zero
## seconds. To start the stopwatch, use start()
func reset() -> void:
	time_elapsed = 0
	paused = true
	text = "-:--"
	add_theme_color_override("font_color", Color("ffffff"))


## Start the stop watch with an optional delay. This will continue the stopwatch
## from its current time. Use stop() to pause or reset() to set the time
## to zero.
func start(delay: float = 0) -> void:
	paused = true
	await get_tree().create_timer(delay).timeout
	paused = false
	add_theme_color_override("font_color", Color("ffffff"))


## Stops or pauses the stopwatch. Use start() to resume the timer or reset() to
## set it to zero.
func stop() -> void:
	paused = true
	add_theme_color_override("font_color", Color("b8ae42ff"))
