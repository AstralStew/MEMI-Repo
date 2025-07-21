extends Node2D

@export var delay := 0
@export var speed := 1.0
@export var debugging := false

@export var loadPack := "ScenarioShared"
@export var loadScene := "res://AssetPacks/ScenarioShared/Scenario.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if debugging: print("[Landing] Waiting for AllMother initialisation to finish...")
	get_parent().autoload_finished.connect(self._allmother_initialised_callback)	

func _allmother_initialised_callback() -> void:	
	get_parent().autoload_finished.disconnect(self._allmother_initialised_callback)
	
	if delay>0: await get_tree().create_timer(delay).timeout
	
	if loadPack != "":
		if debugging: print("[Landing] Loading pack '",loadPack,"' at ", Time.get_ticks_msec()/1000)
		LoadManager.request_successful.connect(self._pack_loaded_callback)
		LoadManager.request_skipped.connect(self._pack_loaded_callback)
		LoadManager._load_pack(loadPack)

func _pack_loaded_callback() -> void:	
	LoadManager.request_successful.disconnect(self._pack_loaded_callback)
	LoadManager.request_skipped.disconnect(self._pack_loaded_callback)
		
	if debugging: print("[Landing] Load complete at ", Time.get_ticks_msec()/1000,". AllMother should load '",loadScene,"' in ",delay)	
	
	if delay>0: await get_tree().create_timer(delay).timeout
	
	get_parent()._create_scene_instance(loadScene)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_child(0).get_child(0).rotation += speed * delta
