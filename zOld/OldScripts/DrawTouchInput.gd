extends Node2D

@export var radius := 40.0
@export var opacity := 0.75

func _process(_delta: float) -> void:
	# Keep redrawing on every frame.
	queue_redraw()


func _draw() -> void:
	# Get the touch helper singleton.
	#var touch_helper: Node = $"/root/MainLevel/TouchHelper"
	# Draw every pointer as a circle.
	for ptr_index: int in TouchHelper.state.keys():
		var pos: Vector2 = TouchHelper.state[ptr_index]
		pos = get_canvas_transform().affine_inverse() * pos 
		#print("[DrawTouchInput] Viewport size = ",get_viewport_rect().size)
		
		var color := _get_color_for_ptr_index(ptr_index)		
		color.a = opacity
		
		draw_circle(pos, radius, color)

## Returns a unique-looking color for the specified index.
func _get_color_for_ptr_index(index: int) -> Color:
	var x := (index % 7) + 1
	return Color(float(bool(x & 1)), float(bool(x & 2)), float(bool(x & 4)))
