class_name ScreenPrefab
extends Control

@export var debugging := false

signal try_start_speech_recognition()


signal try_load_next_screen()
signal try_load_screen(_name,_index)

signal try_load_next_screen_set()
signal try_load_screen_set(_name,_index)

signal try_create_prefab(_key,_scene)
signal try_destroy_prefab(_key)

signal try_play_animation(_name,_delay)
signal try_queue_animation(_name,_delay)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func start_speech_recognition() -> void:	
	if debugging: print("[ScreenPrefab] Attempting to start speech recognition...")
	try_start_speech_recognition.emit()







#region Animation functions

func play_animation(animName:String,delay:float=0) -> void:
	if debugging: print("[ScreenPrefab] Attempting to play animation '",animName,"'")
	try_play_animation.emit(animName,delay)

func queue_animation(animName:String, delay:float=0) -> void:
	if debugging: print("[ScreenPrefab] Attempting to queue animation '",animName,"'")
	try_queue_animation.emit(animName,delay)

#endregion

#region Prefab functions

func create_prefab(_key:String, _scene:PackedScene):
	if debugging: print("[ScreenPrefab] Attempting to create prefab '",_scene,"' at key '",_key,"'")
	try_create_prefab.emit(_key,_scene)

func destroy_prefab(_key:String):
	if debugging: print("[ScreenPrefab] Attempting to destroy prefab at key '",_key,"'")
	try_destroy_prefab.emit(_key)

#endregion

#region Screen functions

func load_next_screen():
	if debugging: print("[ScreenPrefab] Attempting to load pack")
	try_load_next_screen.emit()

func load_screen(_name:String="",_index:int=0):
	if debugging: print("[ScreenPrefab] Attempting to load screen '", _name,"' or failing that, index ", _index)
	try_load_screen.emit(_name,_index)

#endregion


#region Screen Set functions

func load_next_screen_set():
	if debugging: print("[ScreenPrefab] Attempting to load next screen set...")
	try_load_next_screen_set.emit()

## Load a new screen set, using [b]_name[/b] if possible then falling back on [b]_index[/b] if not
func load_screen_set(_name:String="",_index:int=0):
	if debugging: print("[ScreenPrefab] Attempting to load screen set '", _name,"' or failing that, index ", _index)
	try_load_screen_set.emit(_name,_index)

#endregion
