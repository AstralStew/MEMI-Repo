@tool 
extends MarginContainer
class_name CommentBubble


@export var _debug := false
@export var _updateInEditor := false
#@export var overrideLanguage := false
#@export var overrideLanguageIndex := 0

@export_group("References")
@export var pop_in_sound : AudioStream = null

@export_group("Size Parametres")
@export var min_height := 10
@export var min_width := 60
@export var max_width := 228
@export var min_char_threshold := 4
@export var max_char_threshold := 22 #25
@export var bg_border_size := 40.0
@export var ar_multiplier:= 1.0
@export var prs_multiplier:= 1.0
@export var zh_multiplier:= 1.0


#@export_group("Margin Parametres")
#@export var root_margin_left := 24
#@export var root_margin_right := 16
#@export var child_margin_left := 0
#@export var child_margin_right := 17


@export_group("Pop In")
@export var pop_in_text_d = 0.25
@export var pop_in_text_e = Tween.EaseType.EASE_IN_OUT
@export var pop_in_text_t = Tween.TransitionType.TRANS_LINEAR
@export var pop_in_resize_d = 0.25
@export var pop_in_resize_e = Tween.EaseType.EASE_OUT
@export var pop_in_resize_t = Tween.TransitionType.TRANS_BACK
@export var pop_in_bg_fade_d = 0.25
@export var pop_in_bg_fade_e = Tween.EaseType.EASE_IN_OUT
@export var pop_in_bg_fade_t = Tween.TransitionType.TRANS_LINEAR

@export_group("Comment")
@export var comment_text_out_d = 0.1
@export var comment_text_out_e = Tween.EaseType.EASE_IN_OUT
@export var comment_text_out_t = Tween.TransitionType.TRANS_LINEAR
@export var comment_resize_d = 0.2
@export var comment_resize_e = Tween.EaseType.EASE_OUT
@export var comment_resize_t = Tween.TransitionType.TRANS_LINEAR
@export var comment_text_in_d = 0.25
@export var comment_text_in_e = Tween.EaseType.EASE_IN_OUT
@export var comment_text_in_t = Tween.TransitionType.TRANS_LINEAR

@export_group("Pop Out")
@export var pop_out_text_d = 0.15
@export var pop_out_text_e = Tween.EaseType.EASE_IN_OUT
@export var pop_out_text_t = Tween.TransitionType.TRANS_LINEAR
@export var pop_out_resize_d = 0.2
@export var pop_out_resize_e = Tween.EaseType.EASE_IN_OUT
@export var pop_out_resize_t = Tween.TransitionType.TRANS_LINEAR
@export var pop_out_bg_fade_d = 0.25
@export var pop_out_bg_fade_e = Tween.EaseType.EASE_IN_OUT
@export var pop_out_bg_fade_t = Tween.TransitionType.TRANS_LINEAR

#@export_group("Resizing")
#@export var bg_resize_inout := 0.25
#@export var bg_resize_ease := Tween.EaseType.EASE_OUT
#@export var bg_resize_trans := Tween.TransitionType.TRANS_BACK
#@export var text_fade_in := 0.25
#@export var text_fade_out := 0.15
#@export var text_fade_ease := Tween.EaseType.EASE_IN_OUT
#@export var text_fade_trans := Tween.TransitionType.TRANS_LINEAR
#
#@export_group("Bubble")
#@export var bubble_resize_in := 0.25
#@export var bubble_resize_out := 0.2
#@export var bubble_resize_ease := Tween.EaseType.EASE_OUT
#@export var bubble_resize_trans := Tween.TransitionType.TRANS_BACK
#@export var bubble_fade_in := 0.25
#@export var bubble_fade_out := 0.1
#@export var bubble_fade_ease := Tween.EaseType.EASE_IN_OUT
#@export var bubble_fade_trans := Tween.TransitionType.TRANS_LINEAR

@export_group("Autostart")
@export var _autostart := false
@export_multiline var _auto_text := ""
#@export var _auto_title := ""
@export var _auto_bg_colour := Color.WHITE
@export var _auto_text_colour := Color.BLACK

@export_group("Read Only")
@export var _old_text := ""


# Private variables
var marginText : MarginContainer
var bubbleText : LabelController
var bubbleProxy : Control
var bubbleBG : NinePatchRect
#var bubbleTitle : Label
var bubbleAudio : AudioStreamPlayer

signal meta_link_1
signal meta_link_2
signal meta_link_3
signal meta_link_4
signal meta_link_5
signal meta_link_6
signal meta_link_7
signal meta_link_8
signal meta_link_9


#region Initialisation

func _ready() -> void:
	_getrefs()
		
	#bubbleBG.pivot_offset = bubbleBG.size / 2
	
	if _autostart: 
		if _debug: print("[Bubble(",name,")] Initialising...")
		
		bubbleText.scale = Vector2.ZERO
		modulate = Color(1,1,1,0)
		
		# NOTE -> idk where else to put this
		marginText.add_theme_constant_override("margin_right",bg_border_size/2)
		marginText.add_theme_constant_override("margin_bottom",bg_border_size/2)
		
		bubbleText.text =_auto_text
		#_set_title(_auto_title)
		_set_colours(_auto_bg_colour,_auto_text_colour)
		
		#bubbleText.text =_auto_text
		#_set_title(_auto_title)
		#_set_colours(_auto_bg_colour,_auto_text_colour)
		#_set_touch_hint(_auto_touch_hint)

func _getrefs() -> void:
	marginText = get_child(0)
	bubbleText = marginText.get_child(0)
	bubbleProxy = get_child(1)
	bubbleBG = bubbleProxy.get_child(0)
	#bubbleTitle = bubbleBG.get_child(0)
	bubbleAudio = get_child(2)




func _process(delta: float) -> void:
	if _updateInEditor && Engine.is_editor_hint():
		if bubbleText == null: _getrefs()
		
		if _autostart && (bubbleText.text !=_auto_text || bubbleBG.self_modulate != _auto_bg_colour):
			if _debug: print("[Bubble(",name,")] Auto processing in editor...")			
			bubbleText.text =_auto_text
			#_set_title(_auto_title)
			_set_colours(_auto_bg_colour,_auto_text_colour)
			
			# NOTE -> idk where else to put this
			marginText.add_theme_constant_override("margin_right",bg_border_size/2)
			marginText.add_theme_constant_override("margin_bottom",bg_border_size/2)
		
		if bubbleText.get_parsed_text() != _old_text:
			if _debug: print("[CommentBubble(",name,")] In-editor resize triggered")
			_old_text = bubbleText.get_parsed_text()
			_resize()

#endregion


#region MEMI functions

func pop_in(_text:String) -> void:
	if _debug: print("[CommentBubble(",name,")] NOTE -> Popping in with '",_text,"'!")
	
	_set_text(_text)
	_resize(false)
	visible = true
	await get_tree().create_timer(0.1).timeout
	
	# resize + fade
	_resize_bubble(true,pop_in_resize_d,pop_in_resize_e,pop_in_resize_t)
	_fade_bubble(true,pop_in_bg_fade_d,pop_in_bg_fade_e,pop_in_bg_fade_t)
	
	# play sound
	bubbleAudio.stream = pop_in_sound
	bubbleAudio.play()
	
	# fade in text
	await get_tree().create_timer(pop_in_bg_fade_d).timeout
	_fade_text(true,pop_in_text_d,pop_in_text_e,pop_in_text_t)
	


func pop_out() -> void:
	if _debug: print("[CommentBubble(",name,")] NOTE -> Popping out!")
	
	# fade out text
	_fade_text(false,pop_out_text_d,pop_out_text_e,pop_out_text_t)
	await get_tree().create_timer(pop_out_text_d).timeout
	
	# resize + fade
	_resize_bubble(false,pop_out_resize_d,pop_out_resize_e,pop_out_resize_t)
	_fade_bubble(false,pop_out_bg_fade_d,pop_out_bg_fade_e,pop_out_bg_fade_t)
	
	bubble_fade.tween_callback(set.bind("visible",false))
	

func comment(_text:String) -> void:
	if _debug: print("[CommentBubble(",name,")] NOTE -> Changing comment to '",_text,"'!")
	
	_fade_text(false,comment_text_out_d,comment_text_out_e,comment_text_out_t)
	text_fade.tween_callback(_set_text.bind(_text))
	text_fade.tween_callback(_resize)
	await get_tree().create_timer(comment_resize_d).timeout
	_fade_text(true,comment_text_in_d,comment_text_in_e,comment_text_in_t)
	

func reset() -> void:
	_set_properties(_auto_text,_auto_bg_colour,_auto_text_colour)
	

#endregion

##region MEMI functions
#
#func pop_in(_text:String) -> void:
	#if _debug: print("[CommentBubble(",name,")] NOTE -> Popping in with '",_text,"'!")
	#_set_text(_text)
	#_resize(false)
	#visible = true
	#await get_tree().create_timer(0.1).timeout
	#
	## resize + fade
	#_resize_bubble(true,bubble_resize_in,bubble_resize_ease,bubble_resize_trans)
	#_fade_bubble(true,bubble_fade_in,bubble_fade_ease,bubble_fade_trans)
	#
	## play sound
	#bubbleAudio.stream = pop_in_sound
	#bubbleAudio.play()
	#
	## fade in text
	#await get_tree().create_timer(bubble_fade_in).timeout
	#_fade_text(true,text_fade_in,text_fade_ease,text_fade_trans)
	#
#
#
#func pop_out() -> void:
	#if _debug: print("[CommentBubble(",name,")] NOTE -> Popping out!")
	#
	## fade out text
	#_fade_text(false,text_fade_out,text_fade_ease,text_fade_trans)
	#await get_tree().create_timer(text_fade_out).timeout
	#
	## resize + fade
	#_resize_bubble(false,bubble_resize_out,bubble_resize_ease,bubble_resize_trans)
	#_fade_bubble(false,bubble_fade_out,bubble_fade_ease,bubble_fade_trans)
	#
	#bubble_fade.tween_callback(set.bind("visible",false))
	#
#
#func comment(_text:String) -> void:	
	#_fade_text(false,text_fade_out,text_fade_ease,text_fade_trans)
	#text_fade.tween_callback(_set_text.bind(_text))
	#text_fade.tween_callback(_resize)
	#await get_tree().create_timer(bg_resize_inout).timeout
	#_fade_text(true,text_fade_in,text_fade_ease,text_fade_trans)
	#
#
#func reset() -> void:
	#_set_properties(_auto_text,_auto_title,_auto_bg_colour,_auto_text_colour)
	#
#
##endregion



#region Set properties


func _set_properties(_text:String,_bgColour:Color=Color.WHITE,_textColour:Color=Color.BLACK) -> void:
	if _debug: print("[CommentBubble(",name,")] NOTE -> Setting all properties...")
	
	_set_text(_text)
	#_set_title(_title)
	_set_colours(_bgColour,_textColour)
	
	if _debug: print("[CommentBubble(",name,")] NOTE -> Finished setting all properties!")



func _set_text(_text:String=""):
	bubbleText.populate(_text)
	if _debug: print("[CommentBubble(",name,")] Text set to '",_text,"'")

#func _set_title(_title:String="") -> void:
	#bubbleTitle.text = _title
	#if _debug: print("[CommentBubble(",name,")] Title set to '",_title,"'")



func _set_colours(_bgColour:Color=Color.WHITE,_textColour=Color.BLACK):
	_set_background_colour(_bgColour)
	_set_text_colour(_textColour)

func _set_text_colour(_colour:Color=Color.BLACK):
	if _debug: print("[CommentBubble(",name,")] Setting text colour to ",_colour)
	bubbleText.add_theme_color_override("default_color",_colour)

func _set_background_colour(_colour:Color=Color.WHITE):
	if _debug: print("[CommentBubble(",name,")] Setting background colour to ",_colour)
	# Moved this here to reset just in case? Maybe a dedicated reset anyway
	bubbleBG.self_modulate = _colour




#endregion



#region Tween properties

var bubble_resize
func _resize_bubble(_active:bool,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if bubble_resize:
		bubble_resize.kill()
	bubble_resize = create_tween()
	
	if _active:
		bubble_resize.tween_property(self, "scale", Vector2.ONE, _duration).from(Vector2.ZERO).set_ease(_ease).set_trans(_transition)
		#touch_hint_fade.tween_callback(bubbleTouchButton.set.bind("visible",true))
	else: 
		bubble_resize.tween_property(self, "scale", Vector2.ZERO, _duration).from(Vector2.ONE).set_ease(_ease).set_trans(_transition)

var bubble_fade
func _fade_bubble(_active:bool,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if bubble_fade:
		bubble_fade.kill()
	bubble_fade = create_tween()
	
	if _active:
		bubble_fade.tween_property(self, "modulate", Color(1,1,1,1), _duration).from(Color(1,1,1,0)).set_ease(_ease).set_trans(_transition)
		#touch_hint_fade.tween_callback(bubbleTouchButton.set.bind("visible",true))
	else: 
		bubble_fade.tween_property(self, "modulate", Color(1,1,1,0), _duration).from(Color(1,1,1,1)).set_ease(_ease).set_trans(_transition)

var text_fade
func _fade_text(_active:bool,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if text_fade:
		text_fade.kill()
	text_fade = create_tween()
	if _active:
		text_fade.tween_property(bubbleText, "self_modulate", Color(1,1,1,1), _duration).set_ease(_ease).set_trans(_transition)
	else: 
		text_fade.tween_property(bubbleText, "self_modulate", Color(1,1,1,0), _duration).set_ease(_ease).set_trans(_transition)

var background_resize : Tween
func _resize_background(_target:Vector2,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if background_resize:
		background_resize.kill()
	background_resize = create_tween()
	background_resize.tween_property(bubbleProxy, "custom_minimum_size", _target, _duration).set_ease(_ease).set_trans(_transition)


var background_fade
func _fade_background(_colour:Color,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if background_fade:
		background_fade.kill()
	background_fade = create_tween()
	
	background_fade.tween_property(bubbleBG, "self_modulate", _colour, _duration).set_ease(_ease).set_trans(_transition)


#endregion


func _resize(_doTween:bool=true) -> void:
	if _debug: print("[CommentBubble(",name,")] Resizing bubble to fit text...")
	
	
	#bubbleText.custom_minimum_size = Vector2(1000,0)
	#bubbleText.custom_minimum_size = Vector2(max_width + 20,0)
	bubbleText.custom_minimum_size = Vector2(max_width,0)
	
	await get_tree().process_frame 
	
	var max_line_length := 0
	var img_count := 0
	var range := 0
	var line_length := 0
	var font = bubbleText.get_font() if !Engine.is_editor_hint() else get_theme_default_font()    #LanguageManager.get_normal_font()
	var parsed_text = bubbleText.get_parsed_text()
	var current_size = bubbleText.get_current_size() if !Engine.is_editor_hint() else 18
	
	var current_mult = 1.0
	#var child : MarginContainer = get_child(0)
	#if overrideLanguage:
		#LanguageManager.currentLanguage = overrideLanguageIndex
	match (LanguageManager.currentLanguage):
		Constants.LanguageCode.en:
			pass
			#add_theme_constant_override("margin_left",root_margin_left)
			#add_theme_constant_override("margin_right",root_margin_right)
			#child.add_theme_constant_override("margin_left",child_margin_left)
			#child.add_theme_constant_override("margin_right",child_margin_right)
		Constants.LanguageCode.ar:
			current_mult *= ar_multiplier
			#add_theme_constant_override("margin_left",root_margin_right)
			#add_theme_constant_override("margin_right",root_margin_left)
			#child.add_theme_constant_override("margin_left",child_margin_right)
			#child.add_theme_constant_override("margin_right",child_margin_left)
		Constants.LanguageCode.prs:
			current_mult *= prs_multiplier
			#add_theme_constant_override("margin_left",root_margin_right)
			#add_theme_constant_override("margin_right",root_margin_left)
			#child.add_theme_constant_override("margin_left",child_margin_right)
			#child.add_theme_constant_override("margin_right",child_margin_left)
		Constants.LanguageCode.zh:
			current_mult *= zh_multiplier
			#add_theme_constant_override("margin_left",root_margin_left)
			#add_theme_constant_override("margin_right",root_margin_right)
			#child.add_theme_constant_override("margin_left",child_margin_left)
			#child.add_theme_constant_override("margin_right",child_margin_right)
	print ("[CommentBubble(",name,")] Current language = ",LanguageManager.currentLanguage,", multiplier = ",current_mult)
	
	for i in bubbleText.get_line_count():
		#var substring = bubbleText.get_parsed_text().substr(bubbleText.get_line_range(i).x,bubbleText.get_line_range(i).y-bubbleText.get_line_range(i).x)
		#print("SUBSTRING = ",substring)
		range = bubbleText.get_line_range(i).y - bubbleText.get_line_range(i).x
		line_length = 0
		if _debug: print ("[CommentBubble(",name,")] Line index = ",i)
		#for char in parsed_text.substr(bubbleText.get_line_range(i).x, range):
			#font.get_char_size(char.unicode_at(0),bubbleText.current_size)
			#line_length += font.get_char_size(char.unicode_at(0),current_size).x			
			#if _debug: print("[CommentBubble(",name,")] Char = '",char,"', unicode = ",char.unicode_at(0),", size = ",font.get_char_size(char.unicode_at(0),18))
		
		#if _debug: print ("[CommentBubble(",name,")] ParsedText.Substr = '",parsed_text,"', ")
		
		line_length += font.get_string_size(parsed_text.substr(bubbleText.get_line_range(i).x, range),bubbleText.horizontal_alignment,-1,bubbleText.current_size,bubbleText.justification_flags,TextServer.DIRECTION_AUTO,TextServer.ORIENTATION_HORIZONTAL).x
		
		
		if _debug: print ("[CommentBubble(",name,")] Normal line length = ",line_length)
		img_count = parsed_text.count("`", bubbleText.get_line_range(i).x ,bubbleText.get_line_range(i).y)
		if _debug: print("[CommentBubble(",name,")] Line index = ",i,", range = ", bubbleText.get_line_range(i),", sub = ", range, ", img_count = ", img_count)
		#max_line_length = maxi(bubbleText.get_line_range(i).y - bubbleText.get_line_range(i).x + (img_count*2), max_line_length)
		
		#line_length *= current_mult
		
		line_length += img_count * 10
		max_line_length = maxi(line_length, max_line_length)
		if _debug: print ("[CommentBubble(",name,")] Post IMG line length = ",line_length)
		
	#var min_size = clamp(remap(max_line_length,min_char_threshold,max_char_threshold,min_width,max_width),min_width,max_width)
	#var min_size = clamp(max_line_length + 10,min_width,max_width)
	var min_size = clamp(max_line_length,min_width,max_width)
	
	
	
	if _debug: print("[CommentBubble(",name,")] Get_line_count() = ",bubbleText.get_line_count(),", max_line_length = ",max_line_length,", min_size = ",min_size)
	
	bubbleText.custom_minimum_size = Vector2(min_size,min_height)
	
	await get_tree().process_frame 
	
	if _doTween:
		if _debug: print("[CommentBubble(",name,")] NOTE -> Resizing Using Tween...")
		_resize_background(bubbleText.size + (Vector2.ONE * bg_border_size),comment_resize_d,comment_resize_e,comment_resize_t)
	else:
		if _debug: print("[CommentBubble(",name,")] NOTE -> Ignoring Tween! Fast setting background instead.")
		bubbleProxy.custom_minimum_size = bubbleText.size + (Vector2.ONE * bg_border_size)
	
	bubbleText.pivot_offset = bubbleText.size / 2
	pivot_offset = size
	
	if _debug: print("[CommentBubble(",name,")] Finished resizing!")



func set_sizes(_min_height:int,_min_width:int,_max_width:int,_min_char_threshold:int,_max_char_threshold:int):
	min_height = _min_height
	min_width = _min_width
	max_width = _max_width
	min_char_threshold = _min_char_threshold
	max_char_threshold = _max_char_threshold


func testing() -> void:
	LanguageManager._initialise()
	LanguageManager.set_language(Constants.LanguageCode.ar)

#region Meta links

func _send_meta_link_1():
	meta_link_1.emit()

func _send_meta_link_2():
	meta_link_2.emit()

func _send_meta_link_3():
	meta_link_3.emit()

func _send_meta_link_4():
	meta_link_4.emit()

func _send_meta_link_5():
	meta_link_5.emit()

func _send_meta_link_6():
	meta_link_6.emit()

func _send_meta_link_7():
	meta_link_7.emit()

func _send_meta_link_8():
	meta_link_8.emit()

func _send_meta_link_9():
	meta_link_9.emit()

#endregion
