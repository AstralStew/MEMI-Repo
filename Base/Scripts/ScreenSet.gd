class_name ScreenSet
extends Resource

@export var required_packs : Array[String]
@export var screens : Array[AnimationLibrary]

@export var path := ""
@export var current_index := 0


func _init(p_required_packs : Array[String] = [""], p_screens : Array[AnimationLibrary] = [null], p_current_index : int = 0):
	required_packs = p_required_packs
	screens = p_screens
	current_index = p_current_index




func next_screen() -> AnimationLibrary:
	increment()
	return screens[current_index]

func get_screen(index:int = 0) -> AnimationLibrary:
	if index < screens.size():
		return screens[index]
	else:
		push_error("[ScreenSet] ERROR -> Provided index out of bounds!")
		return null	

func increment():
	current_index = (current_index + 1) % screens.size()
