extends Control

@export var debug := false

func _ready() -> void:
	BridgeManager.speech_start.connect(_start)
	BridgeManager.speech_end.connect(_end)
	BridgeManager.speech_error.connect(_end)


func _start() -> void:
	if debug: print("[VisibleOnSpeech] Turning on.")
	visible = true

func _end() -> void:
	if debug: print("[VisibleOnSpeech] Turning off.")
	visible = false
