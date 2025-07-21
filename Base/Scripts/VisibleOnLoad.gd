extends Control

@export var debugging := false
@export var speed := 1.0

func _ready() -> void:
	LoadManager.request_started.connect(_start)	
	LoadManager.request_successful.connect(_end)
	LoadManager.request_skipped.connect(_end)
	LoadManager.request_failed.connect(_end)
	LoadManager.request_error.connect(_end)


func _start() -> void:
	if debugging: print("[VisibleOnLoad] Turning on.")
	visible = true

func _end() -> void:
	if debugging: print("[VisibleOnLoad] Turning off.")
	visible = false

func _process(delta: float) -> void:
	if visible:
		rotation += speed * delta
