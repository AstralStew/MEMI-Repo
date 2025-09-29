extends Control


@export var auto_start := false

@export var debugging := false
#@export var speed := 1.0
@export var print_text := false

var debug_text : Label = null

func _ready() -> void:
	if !auto_start: return
	LoadManager.request_started.connect(_start)
	LoadManager.request_successful.connect(_end)
	LoadManager.request_skipped.connect(_end)
	LoadManager.request_failed.connect(_end)
	LoadManager.request_error.connect(_end)
	
	if print_text:
		debug_text = get_child(0)
		if debug_text: LoadManager.request_started_with.connect(_start_with)


func _start() -> void:
	if debugging: print("[VisibleOnLoad] Turning on.")
	visible = true

func _start_with(_filename:String):
	_start()
	debug_text.text = "Loading pack: '" + _filename + "'"

func _end() -> void:
	if debugging: print("[VisibleOnLoad] Turning off.")
	visible = false
	if print_text: debug_text.text = ""

#func _process(delta: float) -> void:
#	if visible:
#		rotation += speed * delta
