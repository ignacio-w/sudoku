extends CanvasLayer

const GAME = preload("uid://ckyn5pj7dq8xq")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_easy_pressed() -> void:
	get_tree().change_scene_to_packed(GAME)
	pass # Replace with function body.


func _on_normal_pressed() -> void:
	pass # Replace with function body.


func _on_hard_pressed() -> void:
	pass # Replace with function body.
