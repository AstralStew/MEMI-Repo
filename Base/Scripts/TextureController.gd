@tool 
extends TextureRect
class_name TextureController


@export var debugging := false
@export var _updateInEditor := false

@export_group("Texture Properties")
@export var auto_check := false
@export var flip_when_RTL := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if auto_check:
		flip_h = flip_when_RTL && is_layout_rtl();
	
	subscribe_to_language_manager()

func subscribe_to_language_manager() -> void:
	if Engine.is_editor_hint(): return
	await LanguageManager != null
	LanguageManager.language_changed.connect(switch_language)

func switch_language() -> void:
	flip_h = flip_when_RTL && is_layout_rtl();


#region Editor only

func _process(delta: float) -> void:
	if _updateInEditor && Engine.is_editor_hint():
		if auto_check:
			flip_h = flip_when_RTL && is_layout_rtl();

#endregion
