class_name LabelController
extends RichTextLabel

@export var debugging := false

@export_group("Text Properties")
@export var fontType : Constants.FontType = Constants.FontType.Normal
@export var default_size := 19
@export var lightSpeakerIcon := false

signal text_populated
signal text_populated_with_text(words)
signal text_populated_with_lines(number)

@export_group("Translation Properties")
@export var change_font := true
@export var autopopulate := false
@export var autokey := ""

var current_size := 0
var last_text_code := ""

signal meta_link_1
signal meta_link_2
signal meta_link_3
signal meta_link_4
signal meta_link_5
signal meta_link_6
signal meta_link_7
signal meta_link_8
signal meta_link_9
signal meta_link_10
signal meta_link_11
signal meta_link_12
signal meta_link_13
signal meta_link_14
signal meta_link_15
signal meta_link_16

const DARK_SPEAKER_PATH := "res://AssetPacks/0_Prerequisite/Images/SpeakerIconDark.png"
const LIGHT_SPEAKER_PATH := "res://AssetPacks/0_Prerequisite/Images/SpeakerIconLight.png"


func _ready() -> void:
	meta_clicked.connect(_link_clicked)
	
	# Register any custom emojis
	#var speakerPath = load("res://AssetPacks/0_Shared/Images/SpeakerIcon.png")
	#add_image(speakerPath, 16, 16, Color(1, 1, 1, 1), 0, Rect2(), "speaker")
	
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
	if debugging: print("[LabelController] Setting text to: '",_newText)
	
	#text = tr(_newText).replacen("{speaker}",_get_speaker_string())
	#text = tr(_newText).replacen("<~","[color=00000000].[/color][bgcolor=F7A420C2]").replacen("~>","[/bgcolor] "+ _get_speaker_string())
	
	# Make sure speaker is always on the right
	if is_layout_rtl():
		text = tr(_newText).replacen("<~",_get_speaker_string() + "[color=00000000]`[/color][bgcolor=F7A420C2]").replacen("~>","[/bgcolor] ").dedent()
	else:
		text = tr(_newText).replacen("<~"," [bgcolor=F7A420C2]").replacen("~>","[/bgcolor][color=00000000]`[/color]" + _get_speaker_string()).dedent()
	
	text_populated.emit()
	text_populated_with_text.emit(text)
	text_populated_with_lines.emit(get_line_count())

func translate(_newKey : String) -> void:
	_check_font()
	if debugging: print("[LabelController] Translating new key = '",_newKey,"', result: '",tr(_newKey))
	await get_tree().create_timer(0.1).timeout
	text = tr(_newKey)

func resize(_newSize:int) -> void:
	if debugging: print("[LabelController] Setting font size to ",_newSize)
	add_theme_font_size_override("normal_font_size",_newSize)
	current_size = _newSize




func populate_by_unlock_status(_unlocked_path:StringName,_fallback:StringName) -> void:
	if LoadManager.menu_unlocked:
		if debugging: print("[LabelController] POPULATE ON UNLOCK STATUS -> Menu unlocked! Text = ",_unlocked_path)
		populate(_unlocked_path)
	else:
		if debugging: print("[LabelController] POPULATE ON UNLOCK STATUS -> Menu still locked! Text = ",_fallback)
		populate(_fallback)




func _get_speaker_string() -> String:
	if debugging: print("[LabelController] Getting speaker string, size string = ",str(current_size + 4))
	var sizeString = str(current_size + 4)
	var speakerPath  = LIGHT_SPEAKER_PATH if lightSpeakerIcon else DARK_SPEAKER_PATH
	if debugging: print("[LabelController] Returning [img=b,b," + sizeString + "x" + sizeString + "]" + speakerPath + "[/img]")
	return "[img=b,b," + sizeString + "x" + sizeString + "]" + speakerPath + "[/img]"


func _check_font() -> void:
	if LanguageManager.enNormalFont == null:
		LanguageManager._initialise()
	if change_font: 
		add_theme_font_override("normal_font",LanguageManager.get_normal_font())
	#else:
		#add_theme_font_override("normal_font",LanguageManager.enNormalFont)
	
	#match (LanguageManager.currentLanguage):
		#Constants.LanguageCode.en:
			#text_direction = Control.TEXT_DIRECTION_LTR
			##layout_direction
		#Constants.LanguageCode.ar:
			#text_direction = Control.TEXT_DIRECTION_RTL
		#Constants.LanguageCode.prs:
			#text_direction = Control.TEXT_DIRECTION_RTL
		#Constants.LanguageCode.zh:
			#text_direction = Control.TEXT_DIRECTION_LTR
		#_:
			#push_error("[LabelController] ERROR -> Bad language code! Should not be possible :(")

func get_font() -> Font:
	if change_font: 
		return LanguageManager.get_normal_font()
	else:
		return LanguageManager.enNormalFont


func get_current_size() -> int:
	return current_size

# `meta` is of Variant type, so convert it to a String to avoid script errors at run-time.
func _link_clicked(meta):
	
	if debugging: print("[LabelController] Meta clicked: '",str(meta),"'")
	
	match meta:
		"{1}":
			if debugging: print("[LabelController] Sending meta 1 signal...")
			meta_link_1.emit()			
		"{2}":
			if debugging: print("[LabelController] Sending meta 2 signal...")
			meta_link_2.emit()			
		"{3}":
			if debugging: print("[LabelController] Sending meta 3 signal...")
			meta_link_3.emit()			
		"{4}":
			if debugging: print("[LabelController] Sending meta 4 signal...")
			meta_link_4.emit()
		"{5}":
			if debugging: print("[LabelController] Sending meta 5 signal...")
			meta_link_5.emit()
		"{6}":
			if debugging: print("[LabelController] Sending meta 6 signal...")
			meta_link_6.emit()
		"{7}":
			if debugging: print("[LabelController] Sending meta 7 signal...")
			meta_link_7.emit()
		"{8}":
			if debugging: print("[LabelController] Sending meta 8 signal...")
			meta_link_8.emit()
		"{9}":
			if debugging: print("[LabelController] Sending meta 9 signal...")
			meta_link_9.emit()
		"{10}":
			if debugging: print("[LabelController] Sending meta 10 signal...")
			meta_link_10.emit()
		"{11}":
			if debugging: print("[LabelController] Sending meta 11 signal...")
			meta_link_11.emit()
		"{12}":
			if debugging: print("[LabelController] Sending meta 12 signal...")
			meta_link_12.emit()
		"{13}":
			if debugging: print("[LabelController] Sending meta 13 signal...")
			meta_link_13.emit()
		"{14}":
			if debugging: print("[LabelController] Sending meta 14 signal...")
			meta_link_14.emit()
		"{15}":
			if debugging: print("[LabelController] Sending meta 15 signal...")
			meta_link_15.emit()
		"{16}":
			if debugging: print("[LabelController] Sending meta 16 signal...")
			meta_link_16.emit()
		_:
			if debugging: print("[LabelController] ERROR -> No match, bad meta link! :(")
		
		#match meta:
		#"{www.google.com}": print("durp")
		#"www.google.com":
			#print("success!")
			#OS.shell_open(str(meta))
		#"{1}":print("this is a bracketed one")
		#"_func_name":print("_func_name_called")


func _on_meta_link_1(extra_arg_0: Color) -> void:
	pass # Replace with function body.
