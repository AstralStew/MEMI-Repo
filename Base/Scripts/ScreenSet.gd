class_name ScreenSet
extends Resource

@export var required_packs : Array[String]
@export var screen_paths : Array[String]
@export var first_anims : Array[StringName]

#@export var path := ""
@export var current_index := 0

func _init(p_required_packs : Array[String] = [""], p_screen_paths : Array[String] = [""], p_current_index : int = 0, p_first_anims : Array[StringName] = [""]):
	required_packs = p_required_packs
	screen_paths = p_screen_paths
	current_index = p_current_index
	first_anims = p_first_anims


func first_anim() -> StringName:
	return first_anims[current_index]

func next_screen() -> AnimationLibrary:
	increment()
	if current_index > 0:
		return _screen_from_index(current_index)
	else:
		print("Reached end of screen set, returning null")
		return null

func get_screen(index:int = 0) -> AnimationLibrary:
	if index < screen_paths.size():
		return _screen_from_index(index)
	else:
		push_error("[ScreenSet] ERROR -> Provided index out of bounds! Returning null")
		return null


func increment():
	current_index = (current_index + 1) % screen_paths.size()


func _screen_from_index(index:int) -> AnimationLibrary:
	var pathToLibrary : StringName = screen_paths[index]
	
	if !ResourceLoader.exists(pathToLibrary):
		push_error("[ScreenSet] ERROR -> Could not find file path '",pathToLibrary,"'")
		return null	
	var library = load(pathToLibrary)
	
	return library
