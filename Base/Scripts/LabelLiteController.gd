class_name LabelLiteController
extends Label

@export var debugging := false

@export_group("Text Properties")
@export var fontType : Constants.FontType = Constants.FontType.Normal
@export var default_size := 18

signal text_populated
signal text_populated_with_text(words)
signal text_populated_with_lines(number)

@export_group("Translation Properties")
@export var change_font := true
@export var autopopulate := false
@export var autokey := ""

var current_size := 0
var last_text_code := ""


func _ready() -> void:
	
	last_text_code = text
	text_direction = Control.TEXT_DIRECTION_INHERITED
	
	current_size = default_size
	if autopopulate: populate(autokey)
	
	subscribe_to_language_manager()

func subscribe_to_language_manager() -> void:
	await LanguageManager != null
	LanguageManager.language_changed.connect(switch_language)

func switch_language() -> void:
	_check_font()
	populate(last_text_code)


func populate(_newText : String) -> void:
	last_text_code = _newText
	
	if _newText != "":
		_check_font()
	if debugging: print("[LabelLiteControiler] Setting text to: '",_newText)
	
	text = tr(_newText)
	
	text_populated.emit()
	text_populated_with_text.emit(text)
	text_populated_with_lines.emit(get_line_count())

func translate(_newKey : String) -> void:
	_check_font()
	if debugging: print("[LabelLiteControiler] Translating new key = '",_newKey,"', result: '",tr(_newKey))
	await get_tree().create_timer(0.1).timeout
	text = tr(_newKey)

func resize(_newSize:int) -> void:
	if debugging: print("[LabelLiteControiler] Setting font size to ",_newSize)
	add_theme_font_size_override("normal_font_size",_newSize)
	current_size = _newSize



func _check_font() -> void:
	if LanguageManager.enNormalFont == null:
		LanguageManager._initialise()
	if change_font: 
		add_theme_font_override("font",LanguageManager.get_normal_font())
	else:
		add_theme_font_override("font",LanguageManager.enNormalFont)

func get_font() -> Font:
	if change_font: 
		return LanguageManager.get_normal_font()
	else:
		return LanguageManager.enNormalFont


func get_current_size() -> int:
	return current_size
