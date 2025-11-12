extends TextureButton
class_name PBSLogoController

@export var debugging := false

@export_group("Texture Properties")
@export var auto_check := false

@export_group("Read Only")

@export var language : Constants.LanguageCode = Constants.LanguageCode.en


# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	if auto_check:
		language = LanguageManager.currentLanguage
		set_logo_from_lang()
	
	subscribe_to_language_manager()

func subscribe_to_language_manager() -> void:
	if Engine.is_editor_hint(): return
	await LanguageManager != null
	LanguageManager.language_changed.connect(switch_language)

func switch_language() -> void:
	set_logo_from_lang()


func set_logo_from_lang() -> void:
	language = LanguageManager.currentLanguage
	var langEnum = (Constants.LanguageCode.keys()[language] as String).capitalize()
	texture_normal = load("res://AssetPacks/0_Shared/Images/PBSLogo"+langEnum+".png")
