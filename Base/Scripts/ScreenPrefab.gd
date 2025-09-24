class_name ScreenPrefab
extends Control

@export var debugging := false

signal try_start_speech_recognition()
signal last_sentence_changed(newSentence)

signal try_load_next_screen(_play_first_anim)
signal try_load_screen(_index,_play_first_anim)

signal try_load_next_screen_set()
signal try_load_screen_set(_name,_index,_skip_start)

signal try_create_prefab(_key,_scene)
signal try_destroy_prefab(_key)

signal try_play_animation(_name,_delay)
signal try_queue_animation(_name,_delay)

signal try_play_stream_from_path(_path)

signal try_activate_exit
signal try_deactivate_exit


signal try_reset_to_start
signal try_reset_scenario

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func start_speech_recognition() -> void:	
	if debugging: print("[ScreenPrefab] Attempting to start speech recognition...")
	try_start_speech_recognition.emit()


func reset_to_start() -> void:
	if debugging: print("[ScreenPrefab] Attempting to reset to start...")
	try_reset_to_start.emit()

func reset_scenario() -> void:
	if debugging: print("[ScreenPrefab] Attempting to reset scenario...")
	try_reset_scenario.emit()


#region Animation functions

func activate_exit() -> void:
	if debugging: print("[ScreenPrefab] Attempting to activate exit...")
	try_activate_exit.emit()

func deactivate_exit() -> void:
	if debugging: print("[ScreenPrefab] Attempting to deactivate exit...")
	try_deactivate_exit.emit()

#endregion



#region Animation functions

func play_animation(animName:String,delay:float=0) -> void:
	if debugging: print("[ScreenPrefab] Attempting to play animation '",animName,"'")
	try_play_animation.emit(animName,delay)

func queue_animation(animName:String, delay:float=0) -> void:
	if debugging: print("[ScreenPrefab] Attempting to queue animation '",animName,"'")
	try_queue_animation.emit(animName,delay)

#endregion

#region Audio functions


func play_stream(_path) -> void:	
	if debugging: print("[ScreenPrefab] Attempting to play stream at path '",_path,"'")
	try_play_stream_from_path.emit(_path)

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
func load_screen_set(_name:String="",_index:int=0, _skip_start:bool = false):
	if debugging: print("[ScreenPrefab] Attempting to load screen set '", _name,"' (or failing that, index ", _index, "),"," " if _skip_start else " WITHOUT"," skipping start!")
	try_load_screen_set.emit(_name,_index,_skip_start)

#endregion


#region Speech functions

func last_sentence_received(newSentence:String) -> void:	
	last_sentence_changed.emit(newSentence)

#endregion



#region Language functions

func set_language(_lang:Constants.LanguageCode) -> void:
	if debugging: print("[ScreenPrefab] Attempting to set language to '",_lang,"'...")
	LanguageManager.set_language(_lang)

#endregion



#region Globals functions

func unlock_menu() -> void:
	if debugging: print("[ScreenPrefab] Attempting to unlock the final menu...")
	LoadManager.unlock_menu(true)






#endregion
