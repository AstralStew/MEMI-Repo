class_name ScreenController
extends AnimationPlayer

@export var debugging := false


@export_group("Autostart Properties")
#@export var autostart := true
@export var autoloadPack := "Global"
@export var autoloadScene := "res://AssetPacks/ScenarioShared/Scenario.tscn"

@export_group("Override Properties")
@export var overrideStartAnim := false
@export var overrideAnimIndex := 0
@export var overrideSpeed := false
@export var overrideSpeedScale := 1.0

@export_group("Screen Sets")
@export var screen_sets : Array[ScreenSet] = []
@export var current_set : ScreenSet = null
var _current_set_index := 0

@export_group("Screens")
@export var current_screen : AnimationLibrary = null
var _current_screen_index := 0


@export_group("Read Only")
@export var loaded_elements = {} ## e.g. {SectionName}~{ScreenName}~{ElementName}[br] ## i.e. Intro~Landing~Logo, Intro~Landing~BG1, Intro~Landing~
@onready var content_parent : Control = get_child(0).get_child(0)

@export var sentenceComparer : SentenceComparer = null
@export var recentResult := false
@export var lastSentence := ""
@export var sentenceAnim := ""

signal pack_load_finished

signal last_sentence_changed(newSentence)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("[ScreenController] Initialising...")
	
	if !OS.has_feature("editor_runtime"):
		
		# Initialise the BridgeManager first
		BridgeManager._initialise()
		
		# Load the shared pack (thus initialising the LoadManager)
		_load_pack("0_Shared")
		await pack_load_finished
		
		# WARNING > This must be initialised AFTER 0_Shared is loaded
		LanguageManager._initialise()
	
	if overrideSpeed: speed_scale = overrideSpeedScale
	
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
	if overrideStartAnim:
		load_screen(overrideAnimIndex)
	else: 
		load_screen(0)
	
	if debugging: print("[ScreenController] Loading required packs...")
	
	play_animation(current_set.first_anim)


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
func load_screen(_index:int=0):
	if debugging: print("[ScreenController] Loading screen at index ",_index,"...")
	
	var animLibrary = current_set.get_screen(_index)
	if animLibrary == null:
		if debugging: print("[ScreenController] No screen at that index! Cancelling :(")
	else:
		if debugging: print("[ScreenController] Attempting to load screen '",animLibrary,"' (animLibrary)")
		add_animation_library(animLibrary.resource_name,animLibrary)


func load_next_screen():
	if debugging: print("[ScreenController] Loading the next screen...")
	
	var animLibrary = current_set.next_screen()
	if animLibrary == null:
		if debugging: print("[ScreenController] There is no next screen, moving to next screen set...")
		load_next_screen_set()
	else:
		if debugging: print("[ScreenController] Attempting to load screen '",animLibrary,"' (animLibrary)")
		add_animation_library(animLibrary.resource_name,animLibrary)


#endregion


#region Animation functions

func play_animation(animName:String,delay:float=0) -> void:
	if !has_animation(animName):
		push_error("[ScreenController] ERROR -> No animation with name '",animName,"' found! :(")
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


#region Content functions

## Key should be the same name as prefab [br] ## i.e. Intro_Landing_Prefab1, Intro_Landing_Prefab2, etc
func create_prefab(_key:String,_scene:PackedScene):
	if debugging: print("[ScreenController] Attemping to create prefab '",_scene,"' + assigning it key '",_key,"'")
	if loaded_elements.has(_key):
		print("[ScreenController] ERROR -> Key '",_key,"' already in use! Ignoring.")
		return
	
	# Spawn the packed scene
	var scene = _scene.instantiate()
	content_parent.add_child(scene)
	
	# Set its layout mode
	var scene_as_control := scene as Control
	scene_as_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Like + Subscribe
	_subscribe(scene as ScreenPrefab)
		
	# Add it to the dictionary
	loaded_elements[_key] = scene
	
	if debugging: print("[ScreenController]Prefab '",_scene,"' created.")


func destroy_prefab(_key:String):
	if !loaded_elements.has(_key):
		print("[ScreenController] ERROR -> No key matching '",_key,"' found! Ignoring.")
		return
	
	# Blocked + Unsubscribed
	_unsubscribe(loaded_elements[_key] as ScreenPrefab)
	
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
	

#endregion


#region Speech functions

func _start_recognition() -> void:
	
	# WARNING -> This allows cheating in the Editor using ABCD keys, see the _input method below
	if OS.has_feature("editor_runtime"):
		if debugging: print("[ScreenController] In-Editor, cheating past speech recognition. A = Correct, B = Wrong, C = Mumbo, D = DontKnow")
		speechCheating = true
		return
	
	if debugging: print("[ScreenController] Starting speech recognition...")
	_connect_bridge()
	BridgeManager._start_recognition()

func _on_speech_start():
	if debugging: print("[ScreenController] OnSpeechStart...")
	recentResult = false

func _on_speech_error():
	if debugging: printerr("[ScreenController] ERROR -> OnSpeechError returned, checking blank string.")
	_disconnect_bridge()
	lastSentence = ""
	_play_sentence_anim()

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


func _on_speech_sentence(newSentence:String) -> void:
	if debugging: print("[ScreenController] OnSpeechSentence: '",newSentence,"'")
	_disconnect_bridge()
	recentResult = true
	lastSentence = newSentence
	last_sentence_changed.emit(newSentence)
	_play_sentence_anim()

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
	if !OS.has_feature("editor_runtime") || !speechCheating: return
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_A:
				print("[ScreenController] SpeechCheating, the A key was pressed! Sending Correct...")
				speechCheating = false
				lastSentence = "Cheated: Correct"
				last_sentence_changed.emit(lastSentence)
				play_animation(sentenceComparer.correctAnim)
			elif event.keycode == KEY_B:
				print("[ScreenController] SpeechCheating, the B key was pressed! Sending Wrong...")
				speechCheating = false
				lastSentence = "Cheated: Wrong"
				last_sentence_changed.emit(lastSentence)
				play_animation(sentenceComparer.wrongAnim)
			elif event.keycode == KEY_C:
				print("[ScreenController] SpeechCheating, the C key was pressed! Sending Mumbo...")
				speechCheating = false
				lastSentence = "Cheated: Mumbo"
				last_sentence_changed.emit(lastSentence)
				play_animation(sentenceComparer.mumboAnim)
			elif event.keycode == KEY_D:
				print("[ScreenController] SpeechCheating, the D key was pressed! Sending DontKnow...")
				speechCheating = false
				lastSentence = "Cheated: DontKnow"
				last_sentence_changed.emit(lastSentence)
				play_animation(sentenceComparer.dontKnowAnim)


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
