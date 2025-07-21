extends Control

@export var autostart := true
@export var reverse := true
@export var loop := true

@export var easeType := Tween.EASE_IN_OUT
@export var trans := Tween.TRANS_LINEAR
@export var start_color = Color(0, 0, 0, 0)
@export var end_color = Color(1, 1, 1, 1)
@export var length := 0.0

var progress := 0.0

var active := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (autostart):
		active = true
		_do()

	#progress = clampf(progress + delta, 0, length)	
	#modulate.a = progress	
	#if progress == length:	
	#var newValue = modulate * ease(delta, 0.33)


func _do(_reverse:bool = false) -> void:
	if (!active): return
	
	print("[Modulator] Do (",_reverse,")")
	var tween = create_tween()
	
	# Use 'ease_in' or 'ease_out' or 'ease_in_out' for different easing types
	tween.set_ease(easeType)  # Example: Use ease_in_out
	tween.set_trans(trans)

	# Do the tween
	if _reverse:
		tween.tween_callback(reverse_callback)
		tween.tween_property(self, "modulate", start_color, length)
		return
	
	tween.tween_callback(done_callback)	
	tween.tween_property(self, "modulate", end_color, length)


func done_callback(): 
	print("[Modulator] Done callback.")
	if (!loop):
		active = false
		return
	
	_do (reverse)

func reverse_callback(): 
	print("[Modulator] Reverse callback.")
	if (!loop):
		active = false
		return
	
	_do (false)
