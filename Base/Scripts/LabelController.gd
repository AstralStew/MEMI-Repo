extends RichTextLabel

@export var debugging := false

@export_group("Text Properties")
@export var fontType : Constants.FontType = Constants.FontType.Normal

signal text_populated
signal text_populated_with_text(words)
signal text_populated_with_lines(number)

@export_group("Translation Properties")
@export var autopopulate := false
@export var autokey := ""

signal meta_link_1
signal meta_link_2
signal meta_link_3
signal meta_link_4
signal meta_link_5
signal meta_link_6
signal meta_link_7
signal meta_link_8
signal meta_link_9



func _ready() -> void:
	meta_clicked.connect(_link_clicked)
	
	if autopopulate: populate(autokey)




func populate(_newText : String) -> void:
	if _newText != "":
		_check_font()
	if debugging: print("[LabelController] Setting text to: '",_newText)
	text = _newText
	
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





func _check_font() -> void:
	if LanguageManager.enNormalFont == null:
		LanguageManager._initialise()
	add_theme_font_override("normal_font",LanguageManager.get_normal_font())


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
