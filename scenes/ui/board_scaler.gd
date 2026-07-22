@tool
extends Control

func _ready() -> void:
	resized.connect(_on_resized)
	get_viewport().size_changed.connect(_on_resized)
	_update_square_size_deferred.call_deferred()

func _on_resized() -> void:
	_update_square_size()

func _update_square_size_deferred() -> void:
	await get_tree().process_frame
	_update_square_size()

func _update_square_size() -> void:
	# 1. Find the MarginContainer (or top UI parent) above HBoxContainer
	var margin_container = _find_margin_container()
	if not margin_container:
		return

	# 2. Calculate the EXACT usable height inside MarginContainer (minus theme margins)
	var total_height: float = margin_container.size.y
	var margin_top: float = margin_container.get_theme_constant("margin_top")
	var margin_bottom: float = margin_container.get_theme_constant("margin_bottom")
	
	var usable_height: float = total_height - (margin_top + margin_bottom)

	# 3. Constrain BoardScaler's minimum width to fit perfectly inside that usable height
	if usable_height > 0 and custom_minimum_size.x != usable_height:
		custom_minimum_size = Vector2(usable_height, usable_height)
		update_minimum_size()

# Helper to find MarginContainer without hardcoding paths
func _find_margin_container() -> MarginContainer:
	var current: Node = get_parent()
	while current:
		if current is MarginContainer:
			return current as MarginContainer
		current = current.get_parent()
	return null
