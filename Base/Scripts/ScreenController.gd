class_name ScreenController
extends AnimationPlayer

@export var debugging := false


@export var startRecordingStreamPath : StringName = "res://AssetPacks/0_Shared/Audio/SFX/RecordingStart.mp3"
@export var stopRecordingStreamPath : StringName = "res://AssetPacks/0_Shared/Audio/SFX/RecordingStop.mp3"
@export var exitMenuPath : StringName = "res://AssetPacks/0_Prerequisite/Prefabs/ExitMenu.tscn"


@export_group("Autostart Properties")
#@export var autostart := true
@export var autoloadPack := "Global"
@export var autoloadScene := "res://AssetPacks/ScenarioShared/Scenario.tscn"

@export_group("Override Properties")
@export var overrideDeactivate := false
@export var overrideResetHierarchy := false
@export var overrideAnswerCheating := false
@export var overrideMenuUnlocked := false
@export var overrideLanguageSwitching := false
@export var overrideLanguageIndex := 0
@export var overrideScreen := false
@export var overrideScreenIndex := 0
@export var overrideAnimSpeed := false
@export var overrideAnimSpeedScale := 1.0
@export var overrideTimeScale := false
@export var overrideTimeScaleFactor := 1.0
@export var overrideLogTimers := false
#@export var overrideLoadingLog := false

@export_group("Screen Sets")
@export var screen_sets : Array[ScreenSet] = []
@export var current_set : ScreenSet = null
var _current_set_index := 0

@export_group("Screens")
@export var current_screen : AnimationLibrary = null
var _current_screen_index := 0


@export_group("Speech Recognition")

@export var topup_time := 2.0
@export var max_time := 8.0



@export_group("Read Only")
@export var loaded_elements = {} ## e.g. {SectionName}~{ScreenName}~{ElementName}[br] ## i.e. Intro~Landing~Logo, Intro~Landing~BG1, Intro~Landing~
@onready var content_parent : String = "MarginContainer/Content" #get_child(0).get_child(0)

@export var sentenceComparer : SentenceComparer = null

@onready var speechTimer : Timer = find_child("SpeechTimer")
@export var is_speaking = false
#@export var recentResult := false
@export var lastSentence := ""
@export var sentenceAnim := ""

@export var audioStreamPlayer : AudioPlayer = null


signal switched_menu_button_dark
signal switched_menu_button_light
#signal switched_backgrounds

signal pack_load_finished

signal last_sentence_changed(newSentence)

signal display_loading

signal activate_restarts
signal deactivate_restarts


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
	
	LoadManager.menu_unlocked = overrideMenuUnlocked
	
	audioStreamPlayer = get_child(2)
	
	create_prefab_untracked(load(exitMenuPath),"/root/AllMother/MenuCanvas")
	
	if debugging: print("[ScreenController] Hardsetting the first animation library...")
	_load_screen_set(0)

func _ready() -> void:
	if overrideAnimSpeed: speed_scale = overrideAnimSpeedScale
	if overrideLanguageSwitching: LanguageManager.set_language(overrideLanguageIndex)

func _process(delta: float) -> void:
	if !overrideLogTimers: return
	if speechTimer.is_stopped(): return
	
	if debugging: print("[ScreenController] OverrideLogTimers. SpeechTimer = ", speechTimer.time_left)



#region Menu functions

func activate_exit_menu_restarts():
	if debugging: print("[ScreenController] Activating exit menu restarts")
	activate_restarts.emit()

func deactivate_exit_menu_restarts():
	if debugging: print("[ScreenController] Deactivating exit menu restarts")
	deactivate_restarts.emit()

#func announce_switched_backgrounds():
	#if debugging: print("[ScreenController] Proudly (manually) announcing we switched backgrounds :)")
	#switched_backgrounds.emit()

func set_exit_menu_button_dark():
	if debugging: print("[ScreenController] Exit menu button dark.")
	switched_menu_button_dark.emit()

func set_exit_menu_button_light():
	if debugging: print("[ScreenController] Exit menu button light.")
	switched_menu_button_light.emit()


func reset_scenario():
	
	pause()
	
	#deactivate_exit_button()
	
	if debugging: print("[ScreenController] RESET SCENARIO -> Fading Content + background colour")
	
	# fade out content
	var fade_tween = create_tween()
	var content = get_node(content_parent) as Control
	var background = get_node("Background") as Control
	fade_tween.tween_property(content, "modulate", Color(0,0,0,0), 0.35).set_trans(Tween.TRANS_QUAD)
	#fade_tween.tween_property(background, "modulate", Color(0.157, 0.09, 0.141, 1.0), 0.35).set_trans(Tween.TRANS_QUAD)
	await get_tree().create_timer(0.5).timeout   
	
	fade_tween.kill()
	stop()
	
	if debugging: print("[ScreenController] RESET SCENARIO -> Destroying prefabs + screens")
	
	# unload all prefabs + screens
	destroy_all_prefabs_except(["LetsLearn_Prefab"])
	
	await get_tree().process_frame
	
	var _learn_menu : Control = loaded_elements.get("LetsLearn_Prefab") 
	if _learn_menu != null:
		var anim = _learn_menu.find_child("AnimationPlayer") as AnimationPlayer
		if current_set.resource_name == "Interpreter":
			anim.play("RESET")
		else: anim.play("LetsLearn/LetsLearn_Reset_"+current_set.resource_name)
	
	
	await get_tree().process_frame
	
	# load screen 0
	if current_set.resource_name != "Interpreter" && current_set.resource_name != "Intro":
		load_screen(0, true,"Skip_Start")
	else:
		load_screen(0, true)
	
	if fade_tween: fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(content, "modulate", Color(1,1,1,1), 0.35).set_trans(Tween.TRANS_QUAD)
	
	if debugging: print("[ScreenController] RESET SCENARIO -> Finished resetting scenario.")


func reset_to_start():
	
	#pause()
	
	#deactivate_exit_button()
	
	if debugging: print("[ScreenController] RESET TO START -> Fading Content + background colour")
	
	# fade out content
	var fade_tween = create_tween()
	var content = get_node(content_parent) as Control
	var background = get_node("Background") as Control
	fade_tween.tween_property(content, "modulate", Color(0,0,0,0), 0.35).set_trans(Tween.TRANS_QUAD)
	fade_tween.tween_property(background, "modulate", Color(0.157, 0.09, 0.141, 1.0), 0.35).set_trans(Tween.TRANS_QUAD)
	await get_tree().create_timer(0.5).timeout   
	
	fade_tween.kill()
	stop()
	
	if debugging: print("[ScreenController] RESET TO START -> Destroying prefabs + screens")
	
	# unload all prefabs + screens
	destroy_all_prefabs()
	unload_all_screens()
	
	await get_tree().process_frame
	
	# reset screen set
	_current_set_index = 0
	current_set = screen_sets[0]
	
	await get_tree().process_frame
	
	# load screen 0
	load_screen(0, true)
	
	content.modulate = Color(1,1,1,1)
	if debugging: print("[ScreenController] RESET TO START -> Finished resetting to start.")

#endregion




#region Screen Set functions


func load_next_screen_set():
	
	if LoadManager.menu_unlocked:
		if debugging: print("[ScreenController] MENU UNLOCKED -> Going back the menu instead of next screen set!")
		load_screen_set("FinalMenu")
		return
	
	if debugging: print("[ScreenController] Attempting to load next screen set (",_current_set_index + 1,")")
	if _current_set_index + 1 < screen_sets.size():
		load_screen_set("",_current_set_index + 1)
	else:
		push_error("[ScreenController] ERROR -> Next screen set would be out of bounds! Ignoring.")


## Load a new screen set, using [b]_name[/b] if possible then falling back on [b]_index[/b] if not
func load_screen_set(_name:String="",_index:int=0, _skip_start:bool = false):
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
	
	_load_screen_set(_current_set_index,_skip_start)


func _load_screen_set(index:int, _skip_start:bool = false):
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
		load_screen(overrideScreenIndex if overrideScreen else 0, true, "Skip_Start" if _skip_start else "")
	else: 
		load_screen(0, true, "Skip_Start" if _skip_start else "")



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
func load_screen(_index:int=0,_play_first_anim:bool=false, _optional_marker:String=""):
	if debugging: print("[ScreenController] Loading screen at index ",_index,"...")
	
	var animLibrary = current_set.get_screen(_index)
	if animLibrary == null:
		if debugging: print("[ScreenController] No screen at that index! Cancelling :(")
	else:
		# Tell the current set that we are shifting to that screen!
		current_set.current_index = _index
		
		if !has_animation_library(animLibrary.resource_name):
			if debugging: print("[ScreenController] Attempting to load screen '",animLibrary,"' (animLibrary)")
			add_animation_library(animLibrary.resource_name,animLibrary)
		elif debugging: print("[ScreenController] Skipping loading screen '",animLibrary,"' (animLibrary) as it already exists here!")
		
		if _play_first_anim:
			if _optional_marker == null:
				if debugging: print("[ScreenController] Playing first animation: '",current_set.first_anim(),"'")
				play_animation(current_set.first_anim())
			else:
				if debugging: print("[ScreenController] Playing first animation: '",current_set.first_anim(),"' at marker '",_optional_marker,"'")
				play_animation(current_set.first_anim(),0,_optional_marker)


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

func unload_all_screens():
	if debugging: print("[ScreenController] Unloading all screens...")
	for screen in get_animation_library_list():
		unload_screen(screen)

#endregion


#region Animation functions

func play_animation(animName:String,delay:float=0,marker:StringName="") -> void:
	if !has_animation(animName):
		push_error("[ScreenController] ERROR -> No animation with name '",animName,"' found! :(")
		return
	
	if marker != "":
		if debugging: print("[ScreenController] Playing animation '",animName,"' at marker '",marker,"' after ",delay," second delay.")
		if delay>0: await get_tree().create_timer(delay).timeout  
		play_section_with_markers(animName,marker)
		return
	
	if debugging: print("[ScreenController] Playing animation '",animName,"' after ",delay," second delay.")
	if delay>0: await get_tree().create_timer(delay).timeout  
	play(animName)

func play_marker(marker:StringName) -> void:
	if debugging: print("[ScreenController] Playing marker '",marker,"'")
	play_section_with_markers(current_animation,marker)

func play_between(start_marker:StringName,end_marker:StringName) -> void:
	if debugging: print("[ScreenController] Playing between markers '",start_marker,"' and '",end_marker,"'")
	play_section_with_markers(current_animation,start_marker,end_marker)


func queue_animation(animName:String, delay:float=0) -> void:
	if !has_animation(animName):
		push_error("[ScreenController] ERROR -> No animation with name '",animName,"' found! :(")
		return		
	if debugging: print("[ScreenController] Queuing animation '",animName,"' after ",delay," second delay.")
	await get_tree().create_timer(delay).timeout
	queue(animName)

func resume_animation(delay:float=0) -> void:
	if debugging: print("[ScreenController] Resuming animation after ",delay," second delay.")
	if delay>0: await get_tree().create_timer(delay).timeout  
	play()


#func play_unless_menu_unlocked(animName:String,delay:float=0,marker:StringName="") -> void:
	#if menu_unlocked || overrideMenuUnlocked:
		#if debugging: print("[ScreenController] MENU UNLOCKED > Going back the menu.")
		#play_animation(animName,delay,marker)
		#return
	#
	#if debugging: print("[ScreenController] MENU LOCKED > Moving forward...")
	#play_animation(animName,delay,marker)


func set_anim_speed(speed:float = 1.0) -> void:
	if debugging: print("[ScreenController] Setting animation speed scale to: ",speed)
	speed_scale = speed

func reset_anim_speed() -> void:
	speed_scale = 1.0





func non_en_speed(speed:float) -> void:
	if LanguageManager.currentLanguage != Constants.LanguageCode.en:
		if debugging: print("[ScreenController] Non-English detected; Setting speed to ",speed)
		speed_scale = speed
	elif debugging: print("[ScreenController] English detected, keeping speed at: ",speed_scale)

func quicken_for_en(speed:float) -> void:
	if LanguageManager.currentLanguage == Constants.LanguageCode.en:
		if debugging: print("[ScreenController] English detected; Setting speed to ",speed)
		speed_scale = speed
	elif debugging: print("[ScreenController] No English detected, keeping speed at: ",speed_scale)


func lang_split(english_start:StringName,english_end:StringName,non_english_start:StringName,non_english_end:StringName):
	if LanguageManager.currentLanguage == Constants.LanguageCode.en:
		if debugging: print("[ScreenController] Language splitting to English markers...")
		play_between(english_start,english_end)
	else:
		if debugging: print("[ScreenController] Language splitting to non-English markers...")
		play_between(non_english_start,non_english_end)



#endregion

#region Audio functions

func play_stream(_stream:AudioStream,_volume:float=1.0) -> void:
	if audioStreamPlayer != null:
		if debugging: print("[ScreenController] Playing audio stream '",_stream,"' at volume ",_volume)
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
		print("[ScreenController] CREATE PREFAB -> Prefab is a ScreenPrefab! Liking + subscribing.")
		_subscribe(scene as ScreenPrefab)
	elif scene is TapBubble:
		print("[ScreenController] CREATE PREFAB -> Prefab is a TapBubble! Liking + subscribing.")
		scene.touch_input.connect(_start_recognition)
		last_sentence_changed.connect(scene.answer)
	#elif scene is ExitMenu:
		#print("[ScreenController] CREATE PREFAB -> Prefab is an ExitMenu! Liking + subscribing.")
		#scene.try_reset_scenario.connect(reset_scenario)
		#scene.try_reset_to_start.connect(reset_to_start)
		#switched_menu_button_dark.connect(scene.set_dark)
		#switched_menu_button_light.connect(scene.set_light)
	
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
		print("[ScreenController] DESTROY PREFAB -> Prefab is a ScreenPrefab, unliking + unsubscribing.")
		_unsubscribe(loaded_elements[_key] as ScreenPrefab)
	elif scene is TapBubble:
		print("[ScreenController] DESTROY PREFAB -> Prefab is a TapBubble, unliking + unsubscribing.")
		scene.touch_input.disconnect(_start_recognition)
		last_sentence_changed.disconnect(scene.answer)
	#elif scene is ExitMenu:
		#print("[ScreenController] DESTROY PREFAB -> Prefab is an ExitMenu, unliking + unsubscribing.")
		#scene.try_reset_scenario.disconnect(reset_scenario)
		#scene.try_reset_to_start.disconnect(reset_to_start)
		#switched_menu_button_dark.connect(scene.set_dark)
		#switched_menu_button_light.connect(scene.set_light)
	
	# Destroy the prefab
	loaded_elements[_key].queue_free()
	if loaded_elements.erase(_key):
		if debugging: print("[ScreenController] Prefab at '",_key,"' destroyed.")


func destroy_all_prefabs():
	if debugging: print("[ScreenController] Destroying all loaded prefabs...")
	for key in loaded_elements.keys():
		destroy_prefab(key)

func destroy_all_prefabs_except(_protected:PackedStringArray):
	if debugging: print("[ScreenController] Destroying all loaded prefabs EXCEPT the following: ",_protected,"...")
	for key in loaded_elements.keys():
		if !_protected.has(key):
			destroy_prefab(key)
		elif debugging:
			print("[ScreenController] Prefab '",key,"' was NOT destroyed ;) ...")
			



func _subscribe(prefab:ScreenPrefab) -> void:
	
	prefab.screen_controller = self
	
	prefab.try_start_speech_recognition.connect(_start_recognition)
	last_sentence_changed.connect(prefab.last_sentence_received)
	
	prefab.try_create_prefab.connect(create_prefab)
	prefab.try_destroy_prefab.connect(destroy_prefab)
	
	prefab.try_load_screen.connect(load_screen)
	prefab.try_load_next_screen.connect(load_next_screen)
	
	prefab.try_load_screen_set.connect(load_screen_set)
	prefab.try_load_next_screen_set.connect(load_next_screen_set)
	
	prefab.try_play.connect(play)
	prefab.try_play_animation.connect(play_animation)
	prefab.try_play_animation_marker.connect(play_animation)
	prefab.try_queue_animation.connect(queue_animation)
	
	prefab.try_play_stream_from_path.connect(play_stream_from_path)
	
	prefab.try_activate_restarts.connect(activate_exit_menu_restarts)
	prefab.try_deactivate_restarts.connect(deactivate_exit_menu_restarts)
	
	prefab.try_reset_to_start.connect(reset_to_start)
	prefab.try_reset_scenario.connect(reset_scenario)
	

func _unsubscribe(prefab:ScreenPrefab) -> void:	
	prefab.try_start_speech_recognition.disconnect(_start_recognition)
	last_sentence_changed.disconnect(prefab.last_sentence_received)
	
	prefab.try_create_prefab.disconnect(create_prefab)
	prefab.try_destroy_prefab.disconnect(destroy_prefab)
	
	prefab.try_load_screen.disconnect(load_screen)
	prefab.try_load_next_screen.disconnect(load_next_screen)
	
	prefab.try_load_screen_set.disconnect(load_screen_set)
	prefab.try_load_next_screen_set.disconnect(load_next_screen_set)
	
	prefab.try_play.disconnect(play)
	prefab.try_play_animation.disconnect(play_animation)
	prefab.try_play_animation_marker.disconnect(play_animation)
	prefab.try_queue_animation.disconnect(queue_animation)
	
	prefab.try_play_stream_from_path.disconnect(play_stream_from_path)
	
	prefab.try_activate_restarts.disconnect(activate_exit_menu_restarts)
	prefab.try_deactivate_restarts.disconnect(deactivate_exit_menu_restarts)
	
	prefab.try_reset_to_start.disconnect(reset_to_start)
	prefab.try_reset_scenario.disconnect(reset_scenario)




## Key should be the same name as prefab [br] ## i.e. Intro_Landing_Prefab1, Intro_Landing_Prefab2, etc
func create_prefab_untracked(_scene:PackedScene, _parent:String=content_parent):
	if debugging: print("[ScreenController] Attemping to create prefab '",_scene,"' but untracked")
	
	# Spawn the packed scene
	var scene = _scene.instantiate()
	get_node(_parent).add_child(scene)
	
	if _parent == content_parent:
		print("[ScreenController] Prefab is directly under 'Content', setting anchor presets")
		
		# Set its layout mode
		var scene_as_control := scene as Control
		scene_as_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	if scene is ExitMenu:
		print("[ScreenController] CREATE PREFAB -> Prefab is an ExitMenu! Liking + subscribing.")
		scene.try_reset_scenario.connect(reset_scenario)
		scene.try_reset_to_start.connect(reset_to_start)
		switched_menu_button_dark.connect(scene.set_dark)
		switched_menu_button_light.connect(scene.set_light)
		activate_restarts.connect(scene.enable_level_menu)
		deactivate_restarts.connect(scene.disable_level_menu)	
	
	if debugging: print("[ScreenController]Prefab '",_scene,"' created.")









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
	
	# Reset timers
	speechTimer.start(max_time)
	lastSentence = ""
	is_speaking = true
	
	if debugging: print("[ScreenController] Starting speech recognition...")
	_connect_bridge()
	BridgeManager._start_recognition()

func _stop_recognition() -> void:
	if debugging: print("[ScreenController] Stopping recognition...")
	BridgeManager._stop_recognition()





func _on_speech_start():
	if debugging: print("[ScreenController] OnSpeechStart...")
	#recentResult = false
	# Play sound
	if !OS.has_feature("web_android"):
		play_stream_from_path(startRecordingStreamPath)

func _on_speech_end():
	if debugging: print("[ScreenController] OnSpeechEnd (does nothing now?)")
	
	await get_tree().create_timer(0.5)
	
	if _bridge_connected: _disconnect_bridge()
	
	is_speaking = false
	
	# run check_speech
	_play_sentence_anim()
	
	# Play sound
	if !OS.has_feature("web_android"):
		play_stream_from_path(stopRecordingStreamPath)
	
	#if debugging: print("[ScreenController] OnSpeechEnd, checking for recent results...")
	#if recentResult:
		#if debugging: print("[ScreenController] OLD recent result was found, ignoring.")
		#return
	#
	#if debugging: print("[ScreenController] OnSpeechEnd waiting for 1 second...")
	#await get_tree().create_timer(1).timeout 
	#if recentResult:
		#if debugging: print("[ScreenController] NEW recent result found, ignoring.")
		#return
	#
	#if debugging: print("[ScreenController] Still no recent result found, checking blank string.")
	#if _bridge_connected: _disconnect_bridge()
	#recentResult = true
	#lastSentence = "" 
	#last_sentence_changed.emit("?")
	#_play_sentence_anim()
	## Play sound
	#if !OS.has_feature("web_android"):
		#play_stream_from_path(stopRecordingStreamPath)


func _on_speech_audiostart():
	pass

func _on_speech_audioend():
	pass

func _on_speech_soundstart():
	pass


func _on_speech_soundend():
	pass



func _on_speech_sentence(newSentence:String) -> void:
	if !is_speaking: return
	if debugging: print("[ScreenController] OnSpeechSentence: '",newSentence,"'")
	if newSentence == "": push_warning("[ScreenController] OnSpeechSentence is blank!")
	#lastSentence += "" if newSentence == "" else " " + newSentence	
	lastSentence = newSentence
	last_sentence_changed.emit(lastSentence[0].to_upper() + lastSentence.substr(1))
	
	speechTimer.stop()
	speechTimer.start(topup_time)


func _on_speech_error():
	#if !is_speaking: return
	if debugging: printerr("[ScreenController] ERROR -> OnSpeechError returned! Ignoring.")
	
	#lastSentence += " [__]"
	#last_sentence_changed.emit(lastSentence[0].to_upper() + lastSentence.substr(1))
	
	#speechTimer.stop()
	#speechTimer.start(topup_time)


func _on_speech_nomatch():
	#if !is_speaking: return
	if debugging: printerr("[ScreenController] ERROR -> OnSpeechNoMatch returned, checking blank string.")
	
	#lastSentence += " [__]"
	#last_sentence_changed.emit(lastSentence[0].to_upper() + lastSentence.substr(1))
	
	#speechTimer.stop()
	#speechTimer.start(topup_time)




func _timeout() -> void:
	_stop_recognition()
	
	await get_tree().create_timer(3.5)
	
	if is_speaking: _on_speech_end()






func _play_sentence_anim() -> void:
	if debugging: print("[ScreenController] PlaySentenceAnim, last sentence = '",lastSentence,"'")
	sentenceAnim = sentenceComparer.compare(lastSentence)
	play_animation(sentenceAnim)

var _bridge_connected := false
func _connect_bridge() -> void:
	_bridge_connected = true
	BridgeManager.speech_start.connect(_on_speech_start)
	BridgeManager.speech_error.connect(_on_speech_error)
	BridgeManager.speech_nomatch.connect(_on_speech_nomatch)
	BridgeManager.speech_end.connect(_on_speech_end)
	BridgeManager.speech_phrase.connect(_on_speech_sentence)
	BridgeManager.speech_audiostart.connect(_on_speech_audiostart)
	BridgeManager.speech_audioend.connect(_on_speech_audioend)
	BridgeManager.speech_soundstart.connect(_on_speech_soundstart)
	BridgeManager.speech_soundend.connect(_on_speech_soundend)

func _disconnect_bridge() -> void:
	_bridge_connected = false
	BridgeManager.speech_start.disconnect(_on_speech_start)
	BridgeManager.speech_error.disconnect(_on_speech_error)
	BridgeManager.speech_nomatch.disconnect(_on_speech_nomatch)
	BridgeManager.speech_end.disconnect(_on_speech_end)
	BridgeManager.speech_phrase.disconnect(_on_speech_sentence)
	BridgeManager.speech_audiostart.disconnect(_on_speech_audiostart)
	BridgeManager.speech_audioend.disconnect(_on_speech_audioend)
	BridgeManager.speech_soundstart.disconnect(_on_speech_soundstart)
	BridgeManager.speech_soundend.disconnect(_on_speech_soundend)



# WARNING -> This allows cheating in the Editor using ABCD keys
var speechCheating := false
func _input(event):
	if !speechCheating && !overrideTimeScale && !overrideLanguageSwitching: return
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
		if event.pressed && overrideLanguageSwitching:
			if event.keycode == KEY_L:
				print("[ScreenController] LanguageSwitching, the L key was pressed! Changing language...")
				LanguageManager.cycle_language()
		#if event.pressed && overrideLoadingLog:
			#if event.keycode == KEY_ASCIITILDE:
				#print("[ScreenController] LoadingLog, the tilde key was pressed! Display loading messages...")
				#display_loading.emit()
		if overrideTimeScale:
			if event.pressed && event.keycode == KEY_F && !event.is_echo():
				print("[ScreenController] TimeCheating, the F key was pressed! Fastforwarding...")
				Engine.time_scale = overrideTimeScaleFactor
			elif !event.pressed && event.keycode == KEY_F:
				print("[ScreenController] TimeCheating, the F key was released! Normal speed.")
				Engine.time_scale = 1.0 

func check_attempts_while_cheating() -> bool:
	if debugging: print("[SentenceComparer] SpeechCheating, total attempts = ", sentenceComparer.total_attempts)
	if sentenceComparer.total_attempts > -1:
		sentenceComparer.attempts -= 1
		if sentenceComparer.attempts == 0:
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
