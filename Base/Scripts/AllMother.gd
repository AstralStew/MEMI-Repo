extends Node

class_name AllMother

@export var autostart := true
@export var autoloadPack := "Global"
@export var autoloadScene := "res://AssetPacks/ScenarioShared/Scenario.tscn"

@export var debugging := false

var _scene_instance : Node

signal autoload_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !autostart: return
	
	BridgeManager._initialise()
	#LoadManager._initialise() isn't necessary
	LanguageManager._initialise()
	
	if autoloadPack != "":
		if debugging: print("[AllMother] Autoloading pack '",autoloadPack,"'")	
		LoadManager.request_successful.connect(self._autoload_callback)
		LoadManager.request_skipped.connect(self._autoload_callback)
		LoadManager._load_pack(autoloadPack)

func _autoload_callback() -> void:	
	LoadManager.request_successful.disconnect(self._autoload_callback)
	LoadManager.request_skipped.disconnect(self._autoload_callback)
	
	if debugging: print("[AllMother] Autoload complete. Creating scene '",autoloadScene,"'")	
	_create_scene_instance(autoloadScene)	
	
	await get_tree().process_frame	
	autoload_finished.emit()

func _create_scene_instance(sceneName:String) -> void:
	if _scene_instance:		
		_destroy_scene_instance()
		await get_tree().process_frame
	
	var loaded_scene: PackedScene = load(sceneName)
	_scene_instance = loaded_scene.instantiate()
	add_child(_scene_instance)

func _destroy_scene_instance() -> void:
	if debugging: print("[AllMother] Destroying current scene instance: '",_scene_instance,"'")		
	_scene_instance.queue_free()
