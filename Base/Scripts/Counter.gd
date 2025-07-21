extends Node

@export var target := 0
var count := 0

@export var once := false
@export var restartCount := false

signal target_reached
signal target_not_reached

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	count = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func increment(amount:int, doTest:bool = true) -> void:
	count += amount
	if doTest: test()

func test() -> void:	
	if count >= target:
		target_reached.emit()
		if once: queue_free()
		if restartCount: count = 0
	else:
		target_not_reached.emit()
