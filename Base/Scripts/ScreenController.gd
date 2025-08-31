class_name ScreenController
extends AnimationPlayer

@export var debugging := false


@export var startRecordingStreamPath : StringName = "res://AssetPacks/0_Shared/Audio/SFX/RecordingStart.mp3"
@export var stopRecordingStreamPath : StringName = "res://AssetPacks/0_Shared/Audio/SFX/RecordingStop.mp3"

@export_group("Autostart Properties")
#@export var autostart := true
@export var autoloadPack := "Global"
@export var autoloadScene := "res://AssetPacks/ScenarioShared/Scenario.tscn"

@export_group("Override Properties")
@export var overrideDeactivate := false
@export var overrideResetHierarchy := false
@export var overrideAnswerCheating := false
@export var overrideScreen := false
@export var overrideScreenIndex := 0
@export var overrideAnimSpeed := false
@export var overrideAnimSpeedScale := 1.0
@export var overrideTimeScale := false
@export var overrideTimeScaleFactor := 1.0

@export_group("Screen Sets")
@export var screen_sets : Array[ScreenSet] = []
@export var current_set : ScreenSet = null
var _current_set_index := 0

@export_group("Screens")
@export var current_screen : AnimationLibrary = null
var _current_screen_index := 0


@export_group("Read Only")
@export var loaded_elements = {} ## e.g. {SectionName}~{ScreenName}~{ElementName}[br] ## i.e. Intro~Landing~Logo, Intro~Landing~BG1, Intro~Landing~
@onready var content_parent : String = "MarginContainer/Content" #get_child(0).get_child(0)

@export var sentenceComparer : SentenceComparer = null
@export var recentResult := false
@export var lastSentence := ""
@export var sentenceAnim := ""

@export var audioStreamPlayer : AudioPlayer = null

signal pack_load_finished

signal last_sentence_changed(newSentence)

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	if overrideDeactivate: return
	if overrideResetHierarchy:
		print("[ScreenController] WARNING -> OverrideResetHierarchy! Destroying children + libraries...")
		for child in get_child(0).get_child(0).get_children():
			print("[ScreenController] OverrideResetHierarchy - Destroying child: '",child,"'.")
			child.queue_free()
		for library in get_animation_library_list():
			print("[ScreenController] OverrideResetHierarchy - Removing library: '",library,"'.")
			remove_animation_library(library)
	
	print("[ScreenController] Initialising...")
	
	if !OS.has_feature("editor_runtime"):
		print("[ScreenController] NOT running in Editor, initialising web stuff...")
		
		# Initialise the BridgeManager first
		BridgeManager._initialise()
		
		# Load the shared pack (thus initialising the LoadManager)
		_load_pack("0_Prerequisite")
		await pack_load_finished
		
		# WARNING > This must be initialised AFTER 0_Prerequisite is loaded
		LanguageManager._initialise()
	
	if overrideAnimSpeed: speed_scale = overrideAnimSpeedScale
	
	audioStreamPlayer = get_child(2)
	
	if debugging: print("[ScreenController] Hardsetting the first animation library...")
	_load_screen_set(0)




#region Screen Set functions


func load_next_screen_set():
	if debugging: print("[ScreenController] Attempting to load next screen set (",_current_set_index + 1,")")
	if _current_set_index + 1 < screen_sets.size():
		load_screen_set("",_current_set_index + 1)
	else:
		push_error("[ScreenController] ERROR -> Next screen set would be out of bounds! Ignoring.")


## Load a new screen set, using [b]_name[/b] if possible then falling back on [b]_index[/b] if not
func load_screen_set(_name:String="",_index:int=0):
	# force unload remaining stuff? nah do it bespoke in the animation
	
	# Grab the screen set
	_current_set_index = -1
	if _name != "":
		for i in len(screen_sets):
			if screen_sets[i].resource_name == _name:
				if debugging: print("[ScreenController] Loading screen set '",_name,"' (using name)...")
				_current_set_index = i
				break
		if _current_set_index == -1:
			print("[ScreenController] ERROR -> Bad screen set name '",_name,"'! Falling back on index ",_index,"...")
			_current_set_index = _index
	else:
		if debugging: print("[ScreenController] Loading screen set index '",screen_sets[_index].resource_name,"' ",_index,"...")
		_current_set_index = _index
	#current_set = screen_sets[_current_set_index]
	
	_load_screen_set(_current_set_index)


func _load_screen_set(index:int):
	if index >= screen_sets.size():
		push_error("[ScreenController] ERROR -> ScreenSet index out of range! Cancelling :(")
		return
	
	# Change the current set
	current_set = screen_sets[index]
	
	if !OS.has_feature("editor_runtime"):
		# load required packs
		if debugging: print("[ScreenController] Loading required packs...")
		for pack in current_set.required_packs:
			_load_pack(pack)
			await pack_load_finished
	
	# load first screen (unless overriding for testing)
	if overrideScreen:
		load_screen(overrideScreenIndex, true)
	else: 
		load_screen(0, true)



func _load_pack(_filename:String) -> void:
	if debugging: print("[ScreenController] Attempting to load pack '",_filename,"'...")
	LoadManager.request_successful.connect(_load_pack_callback)
	LoadManager.request_skipped.connect(_load_pack_callback)
	LoadManager._load_pack(_filename)

func _load_pack_callback() -> void:	
	LoadManager.request_successful.disconnect(_load_pack_callback)
	LoadManager.request_skipped.disconnect(_load_pack_callback)
	if debugging: print("[ScreenController] Pack loading complete.")
	await get_tree().process_frame
	pack_load_finished.emit()

#endregion


#region Screen functions

# ADD BACK IN "_name" AS A PROPERTY HERE, LOOK TO LOAD_SCREEN_SET FOR LOGIC
func load_screen(_index:int=0,_play_first_anim:bool=false):
	if debugging: print("[ScreenController] Loading screen at index ",_index,"...")
	
	var animLibrary = current_set.get_screen(_index)
	if animLibrary == null:
		if debugging: print("[ScreenController] No screen at that index! Cancelling :(")
	else:
		# Tell the current set that we are shifting to that screen!
		current_set.current_index = _index
		
		if debugging: print("[ScreenController] Attempting to load screen '",animLibrary,"' (animLibrary)")
		add_animation_library(animLibrary.resource_name,animLibrary)
		
		if _play_first_anim:
			if debugging: print("[ScreenController] Playing first animation: '",current_set.first_anim(),"'")	
			play_animation(current_set.first_anim())


func load_next_screen(_play_first_anim:bool=false):
	if debugging: print("[ScreenController] Loading the next screen...")
	
	var animLibrary = current_set.next_screen()
	if animLibrary == null:
		if debugging: print("[ScreenController] There is no next screen, moving to next screen set...")
		load_next_screen_set()
	else:
		if debugging: print("[ScreenController] Attempting to load screen '",animLibrary,"' (animLibrary)")
		add_animation_library(animLibrary.resource_name,animLibrary)
		
		if _play_first_anim:
			if debugging: print("[ScreenController] Playing first animation: '",current_set.first_anim(),"'")	
			play_animation(current_set.first_anim())

func unload_screen(_name:String):
	if !has_animation_library(_name):
		push_error("[ScreenController] ERROR -> Cannot unload screen '",_name,"' (animLibrary), it cannot be found :(")
		return
	
	if debugging: print("[ScreenController] Unloading screen '",_name,"' (animLibrary)")
	remove_animation_library(_name)

#endregion


#region Animation functions

func play_animation(animName:String,delay:float=0,marker:StringName="") -> void:
	if !has_animation(animName):
		push_error("[ScreenController] ERROR -> No animation with name '",animName,"' found! :(")
		return
	
	if marker != "":
		print("[ScreenController] Playing animation '",animName,"' at marker '",marker,"' after ",delay," second delay.")
		if delay>0: await get_tree().create_timer(delay).timeout  
		play_section_with_markers(animName,marker)
		return
	
	print("[ScreenController] Playing animation '",animName,"' after ",delay," second delay.")
	if delay>0: await get_tree().create_timer(delay).timeout  
	play(animName)


func queue_animation(animName:String, delay:float=0) -> void:
	if !has_animation(animName):
		push_error("[ScreenController] ERROR -> No animation with name '",animName,"' found! :(")
		return		
	print("[ScreenController] Queuing animation '",animName,"' after ",delay," second delay.")
	await get_tree().create_timer(delay).timeout
	queue(animName)

func resume_animation(delay:float=0) -> void:
	print("[ScreenController] Resuming animation after ",delay," second delay.")
	if delay>0: await get_tree().create_timer(delay).timeout  
	play()

#endregion

#region Audio functions

func play_stream(_stream:AudioStream,_volume:float=1.0) -> void:
	if audioStreamPlayer != null:
		print("[ScreenController] Playing audio stream '",_stream,"' at volume ",_volume)
		audioStreamPlayer.play_stream(_stream,_volume)

func play_stream_from_path(_path:StringName,_volume:float=1.0) -> void:
	if audioStreamPlayer != null:
		var _stream : AudioStream = load(_path)
		if _stream == null:
			push_error("[ScreenController] ERROR -> Could not find audio stream! Cancelling :(")
			return
		play_stream(_stream,_volume)

#endregion 

#region Content functions

## Key should be the same name as prefab [br] ## i.e. Intro_Landing_Prefab1, Intro_Landing_Prefab2, etc
func create_prefab(_key:String,_scene:PackedScene, _parent:String=content_parent):
	if debugging: print("[ScreenController] Attemping to create prefab '",_scene,"' + assigning it key '",_key,"'")
	if loaded_elements.has(_key):
		push_error("[ScreenController] ERROR -> Key '",_key,"' already in use! Ignoring.")
		return
	
	# Spawn the packed scene
	var scene = _scene.instantiate()
	scene.name = _key
	get_node(_parent).add_child(scene)
	
	if _parent == content_parent:
		print("[ScreenController] Prefab is directly under 'Content', setting anchor presets")
		
		# Set its layout mode
		var scene_as_control := scene as Control
		scene_as_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Like + Subscribe for speech recognition
	if scene is ScreenPrefab:
		print("[ScreenController] Prefab is a ScreenPrefab! Liking + subscribing.")
		_subscribe(scene as ScreenPrefab)
	elif scene is TapBubble:
		print("[ScreenController] Prefab is a TapBubble! Liking + subscribing.")
		scene.touch_input.connect(_start_recognition)
		last_sentence_changed.connect(scene.answer)
	
	# Add it to the dictionary
	loaded_elements[_key] = scene
	
	if debugging: print("[ScreenController]Prefab '",_scene,"' created.")


func destroy_prefab(_key:String):
	if !loaded_elements.has(_key):
		print("[ScreenController] ERROR -> No key matching '",_key,"' found! Ignoring.")
		return
	
	# Blocked + Unsubscribed
	var scene = loaded_elements[_key]
	if scene is ScreenPrefab:
		print("[ScreenController] Prefab is a ScreenPrefab, unliking + unsubscribing.")
		_unsubscribe(loaded_elements[_key] as ScreenPrefab)
	elif scene is TapBubble:
		print("[ScreenController] Prefab is a TapBubble! Liking + subscribing.")
		scene.touch_input.disconnect(_start_recognition)
		last_sentence_changed.disconnect(scene.answer)
	
	# Destroy the prefab
	loaded_elements[_key].queue_free()
	if loaded_elements.erase(_key):
		if debugging: print("[ScreenController] Prefab at '",_key,"' destroyed.")


func destroy_all_prefabs():
	if debugging: print("[ScreenController] Destroying all loaded prefabs...")
	for key in loaded_elements.keys():
		destroy_prefab(key)


func _subscribe(prefab:ScreenPrefab) -> void:
	prefab.try_start_speech_recognition.connect(_start_recognition)
	last_sentence_changed.connect(prefab.last_sentence_received)
	
	prefab.try_create_prefab.connect(create_prefab)
	prefab.try_destroy_prefab.connect(destroy_prefab)
	
	prefab.try_load_screen.connect(load_screen)
	prefab.try_load_next_screen.connect(load_next_screen)
	
	prefab.try_load_screen_set.connect(load_screen_set)
	prefab.try_load_next_screen_set.connect(load_next_screen_set)
	
	prefab.try_play_animation.connect(play_animation)
	prefab.try_queue_animation.connect(queue_animation)
	
	prefab.try_play_stream_from_path.connect(play_stream_from_path)
	

func _unsubscribe(prefab:ScreenPrefab) -> void:	
	prefab.try_start_speech_recognition.disconnect(_start_recognition)
	last_sentence_changed.disconnect(prefab.last_sentence_received)
	
	prefab.try_create_prefab.disconnect(create_prefab)
	prefab.try_destroy_prefab.disconnect(destroy_prefab)
	
	prefab.try_load_screen.disconnect(load_screen)
	prefab.try_load_next_screen.disconnect(load_next_screen)
	
	prefab.try_load_screen_set.disconnect(load_screen_set)
	prefab.try_load_next_screen_set.disconnect(load_next_screen_set)
	
	prefab.try_play_animation.disconnect(play_animation)
	prefab.try_queue_animation.disconnect(queue_animation)
	
	prefab.try_play_stream_from_path.disconnect(play_stream_from_path)
	

#endregion


#region Speech functions

func set_sentence_comparer(_sentenceComparer:SentenceComparer):
		if debugging: print("[ScreenController] Setting new Sentence Comparer ('",_sentenceComparer,"') and resetting its total attempts.")
		sentenceComparer = _sentenceComparer
		sentenceComparer.reset_attempts()
	

func _start_recognition() -> void:
	
	# WARNING -> This allows cheating in the Editor using ABCD keys, see the _input method below
	#if OS.has_feature("editor_runtime"):
	if overrideAnswerCheating:
		if debugging: print("[ScreenController] OverrideAnswerCheating. Cheat past speech recognition: A = Correct, B = Wrong, C = Mumbo, D = DontKnow")
		speechCheating = true
		# Play sound
		if !OS.has_feature("web_android"):
			play_stream_from_path(startRecordingStreamPath)
		return
	
	if debugging: print("[ScreenController] Starting speech recognition...")
	_connect_bridge()
	BridgeManager._start_recognition()

func _on_speech_start():
	if debugging: print("[ScreenController] OnSpeechStart...")
	recentResult = false
	# Play sound
	if !OS.has_feature("web_android"):
		play_stream_from_path(startRecordingStreamPath)

func _on_speech_error():
	if debugging: printerr("[ScreenController] ERROR -> OnSpeechError returned, checking blank string.")
	_disconnect_bridge()
	lastSentence = ""
	_play_sentence_anim()
	# Play sound
	if !OS.has_feature("web_android"):
		play_stream_from_path(stopRecordingStreamPath)

func _on_speech_end():
	if debugging: print("[ScreenController] OnSpeechEnd, checking for recent results...")
	if recentResult:
		if debugging: print("[ScreenController] OLD recent result was found, ignoring.")
		return
	
	if debugging: print("[ScreenController] OnSpeechEnd waiting for 1 second...")
	await get_tree().create_timer(1).timeout 
	if recentResult:
		if debugging: print("[ScreenController] NEW recent result found, ignoring.")
		return
	
	if debugging: print("[ScreenController] Still no recent result found, checking blank string.")
	_disconnect_bridge()
	lastSentence = "" 
	_play_sentence_anim()
	# Play sound
	if !OS.has_feature("web_android"):
		play_stream_from_path(stopRecordingStreamPath)


func _on_speech_sentence(newSentence:String) -> void:
	if debugging: print("[ScreenController] OnSpeechSentence: '",newSentence,"'")
	_disconnect_bridge()
	recentResult = true
	lastSentence = newSentence
	last_sentence_changed.emit(newSentence)
	_play_sentence_anim()
	# Play sound
	if !OS.has_feature("web_android"):
		play_stream_from_path(stopRecordingStreamPath)

func _play_sentence_anim() -> void:
	if debugging: print("[ScreenController] PlaySentenceAnim, last sentence = '",lastSentence,"'")
	sentenceAnim = sentenceComparer.compare(lastSentence)
	play_animation(sentenceAnim)

func _connect_bridge() -> void:
	BridgeManager.speech_start.connect(_on_speech_start)
	BridgeManager.speech_error.connect(_on_speech_error)
	BridgeManager.speech_end.connect(_on_speech_end)
	BridgeManager.speech_phrase.connect(_on_speech_sentence)

func _disconnect_bridge() -> void:
	BridgeManager.speech_start.disconnect(_on_speech_start)
	BridgeManager.speech_error.disconnect(_on_speech_error)
	BridgeManager.speech_end.disconnect(_on_speech_end)
	BridgeManager.speech_phrase.disconnect(_on_speech_sentence)



# WARNING -> This allows cheating in the Editor using ABCD keys
var speechCheating := false
func _input(event):
	if !speechCheating && !overrideTimeScale: return
	if event is InputEventKey:
		if event.pressed && speechCheating:
			if event.keycode == KEY_A:
				speechCheating = false
				print("[ScreenController] SpeechCheating, the A key was pressed! Sending Correct...")
				lastSentence = "Cheated: Correct"
				last_sentence_changed.emit(lastSentence)
				play_animation(sentenceComparer.correctAnim)
				play_stream_from_path(stopRecordingStreamPath)
			elif event.keycode == KEY_B:
				speechCheating = false
				if !check_attempts_while_cheating():
					print("[ScreenController] SpeechCheating, the B key was pressed! Sending Wrong...")
					lastSentence = "Cheated: Wrong"
					last_sentence_changed.emit(lastSentence)
					play_animation(sentenceComparer.wrongAnim)
					play_stream_from_path(stopRecordingStreamPath)
			elif event.keycode == KEY_C:
				speechCheating = false
				if !check_attempts_while_cheating():
					print("[ScreenController] SpeechCheating, the C key was pressed! Sending Mumbo...")
					lastSentence = "Cheated: Mumbo"
					last_sentence_changed.emit(lastSentence)
					play_animation(sentenceComparer.mumboAnim)
					play_stream_from_path(stopRecordingStreamPath)
			elif event.keycode == KEY_D:
				speechCheating = false
				if !check_attempts_while_cheating():
					print("[ScreenController] SpeechCheating, the D key was pressed! Sending DontKnow...")
					lastSentence = "Cheated: DontKnow"
					last_sentence_changed.emit(lastSentence)
					play_animation(sentenceComparer.dontKnowAnim)
					play_stream_from_path(stopRecordingStreamPath)
		elif overrideTimeScale:
			if event.pressed && event.keycode == KEY_F && !event.is_echo():
				print("[ScreenController] TimeCheating, the F key was pressed! Fastforwarding...")
				Engine.time_scale = overrideTimeScaleFactor
			elif !event.pressed && event.keycode == KEY_F:
				print("[ScreenController] TimeCheating, the F key was released! Normal speed.")
				Engine.time_scale = 1.0

func check_attempts_while_cheating() -> bool:
	if sentenceComparer.attempts > -1:
		sentenceComparer.attempts -= 1
		if sentenceComparer.attempts <= 0:
			if debugging: print("[SentenceComparer] SpeechCheating, ran out of attempts! Sending GiveUp instead...")
			lastSentence = "Cheated: GiveUp"
			last_sentence_changed.emit(lastSentence)
			play_animation(sentenceComparer.giveUpAnim)
			play_stream_from_path(stopRecordingStreamPath)
			return true
		if debugging: print("[SentenceComparer] SpeechCheating, attempts remaining before GiveUp: ",sentenceComparer.attempts)
	return false

#endregion











#region old

	#var library = load(current_set.path+"/Animations/"+animLibrary.resource_name+".tres")
	#if !library:
		#push_error("[ScreenController] ERROR -> No animation library resource_named '",animLibrary.resource_name,"' found! :(")
	#current_set.screens[0]

	#if autoloadPack != "":
		#if debugging: print("[ScreenController] Autoloading pack '",autoloadPack,"'")	
		#LoadManager.request_successful.connect(self._autoload_callback)
		#LoadManager.request_skipped.connect(self._autoload_callback)
		#LoadManager._load_pack(autoloadPack)

#func _autoload_callback() -> void:	
	#LoadManager.request_successful.disconnect(self._autoload_callback)
	#LoadManager.request_skipped.disconnect(self._autoload_callback)
	#
	#if debugging: print("[ScreenController] Autoload complete. Creating scene '",autoloadScene,"'")	
	#_create_scene_instance(autoloadScene)	
	#
	#await get_tree().process_frame	
	#autoload_finished.emit()

#func _create_scene_instance(sceneName:String) -> void:
	#if _scene_instance:		
		#_destroy_scene_instance()
		#await get_tree().process_frame
	#
	#var loaded_scene: PackedScene = load(sceneName)
	#_scene_instance = loaded_scene.instantiate()
	#add_child(_scene_instance)
#
#func _destroy_scene_instance() -> void:
	#if debugging: print("[ScreenController] Destroying current scene instance: '",_scene_instance,"'")		
	#_scene_instance.queue_free()

#endregion
