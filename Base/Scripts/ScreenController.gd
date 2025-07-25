class_name ScreenController
extends AnimationPlayer

@export var debugging := false

@export_group("Autostart Properties")
@export var autostart := true
@export var autoloadPack := "Global"
@export var autoloadScene := "res://AssetPacks/ScenarioShared/Scenario.tscn"

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
#var _scene_instance : Node
signal pack_load_finished

@export var sentenceComparer : SentenceComparer = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("wot is happening")

	
	#---------TEMPORARY------------------
	if debugging: print("[ScreenController] Hardsetting the first animation library...")

	current_set = screen_sets[0]
	var animLibrary = current_set.get_screen(0)
	if debugging: print("[ScreenController] Attempting to add animation library '",animLibrary,"'")

	var library = load(current_set.path+"/Animations/"+animLibrary.resource_name+".tres")
	if !library:
		push_error("[ScreenController] ERROR -> No animation library resource_named '",animLibrary.resource_name,"' found! :(")
	
	add_animation_library(animLibrary.resource_name,library)
	play_animation("Intro/Intro_Load")
	#---------TEMPORARY-------------------
	
	sentenceComparer.compare("I would like fire department")
	sentenceComparer.compare("I would like ambulance")
	sentenceComparer.compare("I need the police")
	
	if !autostart: return
	BridgeManager._initialise()
	#LoadManager._initialise() isn't necessary
	
	# WARNING > This should be initialised AFTER 0_Shared is loaded instead
	LanguageManager._initialise()
	
	
	


#region Screen Set functions


func load_next_screen_set():
	if debugging: print("[ScreenController] Attempting to load next screen set (",_current_set_index + 1,")")
	if _current_set_index + 1 < screen_sets.size():
		load_screen_set("",_current_set_index + 1)
	else:
		push_error("[ScreenController] ERROR -> Next screen set would be out of bounds! Ignoring.")


## Load a new screen set, using [b]_name[/b] if possible then falling back on [b]_index[/b] if not
func load_screen_set(_name:String="",_index:int=0):
	
	# unload stuff?
	
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
		if debugging: print("[ScreenController] Loading screen set index '",screen_sets[_index].name,"' ",_index,"...")
		_current_set_index = _index
	current_set = screen_sets[_current_set_index]
	
	# load required packs
	if debugging: print("[ScreenController] Loading required packs...")
	for pack in current_set.required_packs:
		_load_pack(pack)
		await pack_load_finished
	
	# load first screen
	load_screen("",0)
	if debugging: print("[ScreenController] Loading required packs...")
	
	current_set.get_screen(0)

func _load_screen_set():
	pass

func _load_pack(_filename:String) -> void:
	if debugging: print("[ScreenController] Attempting to load pack '",_filename,"'...")
	LoadManager.request_successful.connect(self._autoload_callback)
	LoadManager.request_skipped.connect(self._autoload_callback)
	LoadManager._load_pack(_filename)

func _load_pack_callback() -> void:	
	LoadManager.request_successful.disconnect(self._autoload_callback)
	LoadManager.request_skipped.disconnect(self._autoload_callback)	
	if debugging: print("[ScreenController] Pack loading complete.")	
	await get_tree().process_frame
	pack_load_finished.emit()

#endregion


#region Screen functions

func load_screen(_name:String="",_index:int=0):
	current_set.screens[0]

func load_next_screen():
		#---------TEMPORARY------------------
	if debugging: print("[ScreenController] Loading the next screen...")

	#current_set = screen_sets[0]
	var animLibrary = current_set.next_screen()
	
	var library = load(current_set.path+"/Animations/"+animLibrary.resource_name+".tres")
	if !library:
		push_error("[ScreenController] ERROR -> No animation library resource_named '",animLibrary.resource_name,"' found! :(")
	else: 
		if debugging: print("[ScreenController] Attempting to add animation library '",animLibrary,"'")

	add_animation_library(animLibrary.resource_name,library)
	play_animation("Intro_Landing/Intro_Landing_0_Load")
	#---------TEMPORARY-------------------
	
	current_set.next_screen()
	

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
		if debugging: print("[ScreenController]Prefab at '",_key,"' destroyed.")



func _subscribe(prefab:ScreenPrefab) -> void:
	prefab.try_create_prefab.connect(create_prefab)
	prefab.try_destroy_prefab.connect(destroy_prefab)
	
	prefab.try_load_screen.connect(load_screen)
	prefab.try_load_next_screen.connect(load_next_screen)
	
	prefab.try_load_screen_set.connect(load_screen_set)
	prefab.try_load_next_screen_set.connect(load_next_screen_set)
	
	prefab.try_play_animation.connect(play_animation)
	prefab.try_queue_animation.connect(queue_animation)

func _unsubscribe(prefab:ScreenPrefab) -> void:
	prefab.try_create_prefab.disconnect(create_prefab)
	prefab.try_destroy_prefab.disconnect(destroy_prefab)
	
	prefab.try_load_screen.disconnect(load_screen)
	prefab.try_load_next_screen.disconnect(load_next_screen)
	
	prefab.try_load_screen_set.disconnect(load_screen_set)
	prefab.try_load_next_screen_set.disconnect(load_next_screen_set)
	
	prefab.try_play_animation.disconnect(play_animation)
	prefab.try_queue_animation.disconnect(queue_animation)

#endregion














#region old

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
