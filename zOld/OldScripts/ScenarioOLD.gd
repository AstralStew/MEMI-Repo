extends AnimationPlayer
#
#@export var animations : Array[String] = []
#
#var noChapters = 0
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
#func _next_chapter() -> void:
	#pass
#
#func _play_animation(index:int) -> void:
	#if index >= animations.size():
		#return
	#
	#play(index)

#var savedAnimation := ""

@export var debug := false

@export var initialisingID := 0

var retryAnimation := ""
var nextAnimation := ""


#region Start functions

#func _ready() -> void:
	#_initialise(1)

func _set_ID(newID:int) -> void:
	if debug: print("[Scenario] Setting ID from ",initialisingID," to ",newID)
	initialisingID = newID

func _initialise() -> void:
	pause()
	await get_tree().process_frame
	if debug: print("[Scenario] Initialising as 'Scenario",initialisingID,"'")
	
	#name = "Scenario"+str(initialisingID)
	print("[Scenario] Name = ",name)
	_add_animation_library("Scenario"+str(initialisingID))
	await get_tree().process_frame
	play()
	await get_tree().process_frame
	queue("Scenario"+str(initialisingID)+"/anim_s"+str(initialisingID)+"-0") #e.g. "Scenario1/anim_s1-0"

func _add_animation_library(animLibraryName:String) -> void:
	if has_animation_library(animLibraryName):
		if debug: print("[Scenario] Animation library '",animLibraryName,"' already present, no need to add.")
		return	
	if debug: print("[Scenario] Attempting to add animation library '",animLibraryName,"' from 'res://AssetPacks/"+animLibraryName+"/Animations/AnimLibrary_"+animLibraryName+".res'")
	
	var library = load("res://AssetPacks/"+animLibraryName+"/Animations/AnimLibrary_"+animLibraryName+".res")
	if !library:
		push_error("[Scenario] ERROR -> No animation library named '",animLibraryName,"' found! :(")
	
	add_animation_library(animLibraryName,library)
	if debug: print("[Scenario] Added animation library '",animLibraryName,"'!")

func _reset_to_menu() ->void:
	retryAnimation = ""
	nextAnimation = ""
	initialisingID = 0	
	
	if debug: print("[Scenario] Resetting. First to RESET for a frame...")
	play(&"RESET")
	advance(0)
	await get_tree().process_frame
	
	if debug: print("[Scenario] ... then back to anim_s-Menu.")
	play(&"anim_s-Menu")

#endregion



#region Animation functions

func _play_animation(animName:String) -> void:
	if !has_animation(animName):
		push_error("[Scenario] ERROR -> No animation with name '",animName,"' found! :(")
		return		
	print("[Scenario] Playing animation '",animName,"'")
	play(animName)

func _play_animation_delay(animName:String,delay:float) -> void:
	if animName == "":
		print("[Scenario] Resuming animation after ",delay," second delay.")
		await get_tree().create_timer(delay).timeout  
		play()
		return
	if !has_animation(animName):
		push_error("[Scenario] ERROR -> No animation with name '",animName,"' found! :(")
		return		
	print("[Scenario] Playing animation '",animName,"' after ",delay," second delay.")
	await get_tree().create_timer(delay).timeout  
	play(animName)

func _queue_animation(animName:String, delay:float=0) -> void:
	if !has_animation(animName):
		push_error("[Scenario] ERROR -> No animation with name '",animName,"' found! :(")
		return		
	print("[Scenario] Queuing animation '",animName,"' after ",delay," second delay.")
	await get_tree().create_timer(delay).timeout
	queue(animName)


#func _play_saved_animation() -> void:	0.1
	#if savedAnimation == "":		
		#print("[Scenario] ERROR -> No saved animation found! :(")
		#return		
	#_play_animation(savedAnimation)

#endregion

#region Animation triggers

func _decision(_retryAnim:String, _nextAnim:String):
	pause()	
	retryAnimation = _retryAnim
	nextAnimation = _nextAnim
	if debug: print("[Scenario] Decision. Set retry anim: ", _retryAnim,", Set next anim: ", _nextAnim)

func _retry() -> void:
	play()
	queue(retryAnimation)
	if debug: print("[Scenario] Retry. Queued retry animation: ", retryAnimation)

func _next() -> void:
	play()
	queue(nextAnimation)
	if debug: print("[Scenario] Next. Queued next animation: ", nextAnimation)


func _debug(debugMsg:String) -> void:
	print("[Scenario/AnimationTrack] ",debugMsg)

#endregion

#region Loading functions + callbacks

func _load_pack_from_ID() -> void:
	LoadManager._load_pack("Scenario"+str(initialisingID))

func _load_pack(filename:String) -> void:
	pause()
	if debug: print("[Scenario] Attempting to load pack '",filename,"'")	
	LoadManager.request_successful.connect(self._load_success_callback)
	LoadManager.request_skipped.connect(self._load_success_callback)
	LoadManager.request_failed.connect(self._load_failure_callback)
	LoadManager.request_error.connect(self._load_error_callback)
	LoadManager._load_pack(filename)


func _load_success_callback() -> void:
	LoadManager.request_successful.disconnect(self._load_success_callback)
	LoadManager.request_skipped.disconnect(self._load_success_callback)
	LoadManager.request_failed.disconnect(self._load_failure_callback)
	LoadManager.request_error.disconnect(self._load_failure_callback)	
	if debug: print("[Scenario] Load successful! Resuming playback...")	
	play()

func _load_failure_callback() -> void:
	LoadManager.request_successful.disconnect(self._load_success_callback)
	LoadManager.request_skipped.disconnect(self._load_success_callback)
	LoadManager.request_failed.disconnect(self._load_failure_callback)
	LoadManager.request_error.disconnect(self._load_failure_callback)
	if debug: print("[Scenario] Load failed! Ending here :(")	

func _load_error_callback() -> void:
	LoadManager.request_successful.disconnect(self._load_success_callback)
	LoadManager.request_skipped.disconnect(self._load_success_callback)
	LoadManager.request_failed.disconnect(self._load_failure_callback)
	LoadManager.request_error.disconnect(self._load_failure_callback)
	if debug: print("[Scenario] Load error! Ending here :(")	


#endregion

#region Javascript functions

func _test_javascript() -> void:
	BridgeManager._test_javascript()

func _start_recognition() -> void:
	BridgeManager._start_recognition()

#endregion
