extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func Destroy() -> void:
	get_owner().queue_free()
