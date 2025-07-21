extends Node

@export var prefab : PackedScene
@export var count := 1

@export var copies: Array[Node2D] = []

#var index := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in count:
		_populate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _populate() -> void:	
	var instance : Node2D = prefab.instantiate()
	add_child(instance)
	copies.append(instance)

#func _spawn(pos:Vector2) -> Node2D:
	#index = (index + 1) % copies.size()
	#
	#var copy = copies[index]
	#copy.global_position = pos
	#copy.visible = true
	#copy.process_mode = PROCESS_MODE_INHERIT
	#
	#return copies[index]

func _spawn(pos:Vector2) -> Node2D:
	var copy:Node2D = null
	for child in get_children():
		if child.process_mode == PROCESS_MODE_DISABLED && !copy.visible: 
			copy = child
			break
	if copy == null:
		return

	copy.global_position = pos
	copy.visible = true
	copy.process_mode = PROCESS_MODE_INHERIT
	
	return copy

func _despawn(copy:Node2D):
	if !copies.has(copy):
		print("[Spawner] Could not find ",copy," in copies array!")
		return
	elif copy.process_mode == PROCESS_MODE_DISABLED && !copy.visible:
		print("[Spawner] ",copy," is already despawned!")
		return
	
	copy.process_mode = PROCESS_MODE_DISABLED
	copy.visible = false
