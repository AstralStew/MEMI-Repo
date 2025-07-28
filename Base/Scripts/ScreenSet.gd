class_name ScreenSet
extends Resource

@export var required_packs : Array[String]
@export var screen_paths : Array[String]

#@export var path := ""
@export var current_index := 0

@export var first_anim : StringName= ""

func _init(p_required_packs : Array[String] = [""], p_screen_paths : Array[String] = [""], p_current_index : int = 0, p_first_anim : StringName = ""):
	required_packs = p_required_packs
	screen_paths = p_screen_paths
	current_index = p_current_index
	first_anim = p_first_anim




func next_screen() -> AnimationLibrary:
	increment()
	return _screen_from_index(current_index)

func get_screen(index:int = 0) -> AnimationLibrary:
	if index < screen_paths.size():
		return _screen_from_index(index)
	else:
		push_error("[ScreenSet] ERROR -> Provided index out of bounds!")
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
