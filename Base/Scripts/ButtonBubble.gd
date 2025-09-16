@tool 
extends MarginContainer
class_name ButtonBubble


@export var _debug := false
@export var _updateInEditor := false

@export_group("References")
#@export var pop_in_sound : AudioStream = null
@export var click_sound : AudioStream = null

@export_group("Size Parametres")
@export var min_height := 0
@export var min_width := 100
@export var max_width := 228
@export var min_char_threshold := 4
@export var max_char_threshold := 22
@export var bg_border_size := 5.0
@export var bg_border_hscale := 1.0
@export var bg_border_vscale := 1.25
@export var bg_border_curve : Curve = preload("res://Base/BorderCurve.tres")
@export var final_scale := 1.0

@export_group("Pop")
@export var pop_in_resize_in := 0.25
#@export var bubble_resize_out := 1.0
@export var pop_in_resize_ease := Tween.EaseType.EASE_OUT
@export var pop_in_resize_trans := Tween.TransitionType.TRANS_SPRING
@export var pop_in_fade := 0.25
@export var pop_in_fade_ease := Tween.EaseType.EASE_IN_OUT
@export var pop_in_fade_trans := Tween.TransitionType.TRANS_LINEAR
@export var pop_out_fade := 0.25
@export var pop_out_fade_ease := Tween.EaseType.EASE_IN_OUT
@export var pop_out_fade_trans := Tween.TransitionType.TRANS_LINEAR

@export_group("Click")
@export var click_bg_colour := Color("2e2e2e")
@export var click_text_colour := Color("cccccc")
@export var click_size := 1.025
@export var click_inout := 0.075
@export var click_ease := Tween.EaseType.EASE_OUT_IN
@export var click_trans := Tween.TransitionType.TRANS_LINEAR
@export var unclick_inout := 0.075
@export var unclick_ease := Tween.EaseType.EASE_OUT_IN
@export var unclick_trans := Tween.TransitionType.TRANS_LINEAR

@export_group("Autostart")
@export var _autostart := false
@export_multiline var _auto_text := ""
@export var _auto_bg_colour := Color.WHITE
@export var _auto_text_colour := Color.BLACK



@export_group("Read Only")
@export var _old_text := ""


# Private variables
var bubbleText : LabelController
var bubbleBG : NinePatchRect
var bubbleShadow : NinePatchRect
var bubbleTouchAudio : AudioStreamPlayer

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
		
	bubbleText.pivot_offset = bubbleText.size / 2
	bubbleBG.pivot_offset = bubbleBG.size / 2
	bubbleShadow.pivot_offset = bubbleShadow.size / 2
	pivot_offset = size / 2
	
	if _autostart: 
		if _debug: print("[Bubble(",name,")] Initialising...")
		
		if Engine.is_editor_hint():
			bubbleText.text =_auto_text
		else:
			bubbleText.populate(_auto_text)
		_resize()
		
		bubbleText.scale = Vector2.ZERO
		modulate = Color(1,1,1,0)
		
		#_set_colours(_auto_bg_colour,_auto_text_colour)
		

func _getrefs() -> void:	
	bubbleText = get_child(0)
	bubbleBG = bubbleText.get_child(0)
	bubbleShadow = bubbleBG.get_child(0)
	bubbleTouchAudio = get_child(1)
	
	bg_border_curve = preload("res://Base/BorderCurve.tres")




func _process(delta: float) -> void:
	if _updateInEditor && Engine.is_editor_hint():
		if bubbleText == null: _getrefs()
		
		if _autostart && (bubbleText.text !=_auto_text || bubbleBG.self_modulate != _auto_bg_colour):
			if _debug: print("[Bubble(",name,")] Auto processing in editor...")			
			bubbleText.text =_auto_text
			_set_colours(_auto_bg_colour,_auto_text_colour)
		
		if bubbleText.get_parsed_text() != _old_text:
			if _debug: print("[ButtonBubble(",name,")] In-editor resize triggered")
			_old_text = bubbleText.get_parsed_text()
			_resize()

#endregion




#region MEMI functions

func pop_in(_text:String) -> void:
	if _debug: print("[ButtonBubble(",name,")] NOTE -> Popping in!")

	_set_colours(_auto_bg_colour, _auto_text_colour)
	_set_text(_text)
	_resize()
	visible = true
	await get_tree().create_timer(0.1).timeout
	
	# resize + fade
	_resize_bubble(true,pop_in_resize_in,pop_in_resize_ease,pop_in_resize_trans)
	_fade_bubble(true,pop_in_fade,pop_in_fade_ease,pop_in_fade_trans)
	
	# play sound
	#bubbleTouchAudio.stream = pop_in_sound
	#bubbleTouchAudio.play()

func pop_out() -> void:
	if _debug: print("[ButtonBubble(",name,")] NOTE -> Popping out!")
	
	# fade out bubble (no resize)
	_fade_bubble(false,pop_out_fade,pop_out_fade_ease,pop_out_fade_trans)
	bubble_fade.tween_callback(set.bind("visible",false))


func click() -> void:
	if _debug: print("[ButtonBubble(",name,")] NOTE -> Clicked! Playing click + unclick tweens...")
	# fade to correct colour + resize background twice to bounce
	_fade_background(click_bg_colour,click_inout,click_ease,Tween.TransitionType.TRANS_LINEAR)
	_set_text_colour(click_text_colour)
	_resize_text(click_size,click_inout,click_ease,click_trans)
	text_resize.tween_callback(_resize_text.bind(1.0 * final_scale,unclick_inout,unclick_ease,unclick_trans))
	
	# play sound
	bubbleTouchAudio.stream = click_sound
	bubbleTouchAudio.play()


func reset() -> void:
	_set_properties(_auto_text, _auto_bg_colour,_auto_text_colour)

#endregion





#region Set properties


func _set_properties(_text:String,_bgColour:Color=Color.WHITE,_textColour:Color=Color.BLACK) -> void:
	if _debug: print("[ButtonBubble(",name,")] NOTE -> Setting all properties...")
	
	_set_text(_text)
	_set_colours(_bgColour,_textColour)
	
	if _debug: print("[ButtonBubble(",name,")] NOTE -> Finished setting all properties!")



func _set_text(_text:String=""):
	bubbleText.populate(_text)
	if _debug: print("[ButtonBubble(",name,")] Text set to '",_text,"'")



func _set_colours(_bgColour:Color=Color.WHITE,_textColour=Color.BLACK):
	_set_background_colour(_bgColour)
	_set_text_colour(_textColour)

func _set_text_colour(_colour:Color=Color.BLACK):
	if _debug: print("[ButtonBubble(",name,")] Setting text colour to ",_colour)
	bubbleText.add_theme_color_override("default_color",_colour)

func _set_background_colour(_colour:Color=Color.WHITE):
	if _debug: print("[ButtonBubble(",name,")] Setting background colour to ",_colour)
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
		bubble_resize.tween_property(bubbleText, "scale", Vector2.ONE * final_scale, _duration).from(Vector2.ZERO).set_ease(_ease).set_trans(_transition)
		#touch_hint_fade.tween_callback(bubbleTouchButton.set.bind("visible",true))
	else: 
		bubble_resize.tween_property(bubbleText, "scale", Vector2.ZERO, _duration).from(Vector2.ONE).set_ease(_ease).set_trans(_transition)

var text_resize
func _resize_text(_target_size:float,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if text_resize:
		text_resize.kill()
	text_resize = create_tween()
	
	text_resize.tween_property(bubbleText, "scale", Vector2(_target_size,_target_size) * final_scale, _duration).set_ease(_ease).set_trans(_transition)


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


var background_resize
func _resize_background(_target_size:float,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	print("resize")
	if background_resize:
		background_resize.kill()
	background_resize = create_tween()
	
	background_resize.tween_property(bubbleBG, "scale", Vector2(_target_size,_target_size), _duration).set_ease(_ease).set_trans(_transition)


var background_fade
func _fade_background(_colour:Color,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if background_fade:
		background_fade.kill()
	background_fade = create_tween()
	
	background_fade.tween_property(bubbleBG, "self_modulate", _colour, _duration).set_ease(_ease).set_trans(_transition)



#endregion


func _resize() -> void:
	if _debug: print("[ButtonBubble(",name,")] Resizing bubble to fit text...")
	
	bubbleText.custom_minimum_size = Vector2(max_width,0)
	
	await get_tree().process_frame 
		
	var max_line_length = 0
	for i in bubbleText.get_line_count():
		if _debug: print("[ButtonBubble(",name,")] Line index = ",i,", range = ", bubbleText.get_line_range(i), ", sub = ", bubbleText.get_line_range(i).y - bubbleText.get_line_range(i).x)
		max_line_length = maxi(bubbleText.get_line_range(i).y - bubbleText.get_line_range(i).x, max_line_length)
	
	var min_size = clamp(remap(max_line_length,min_char_threshold,max_char_threshold,min_width,max_width),min_width,max_width) + 15
	
	if _debug: print("[ButtonBubble(",name,")] Get_line_count() = ",bubbleText.get_line_count(),"max_line_length = ",max_line_length,", min_size = ",min_size)
	
	bubbleText.custom_minimum_size = Vector2(min_size,min_height)
	#bubbleBG.custom_minimum_size = bubbleText.size + (Vector2.ONE * bg_border_size)
	bubbleBG.offset_left = -bg_border_size * bg_border_hscale
	bubbleBG.offset_top = (-bg_border_size - (bg_border_size / 2.5)) * bg_border_vscale
	bubbleBG.offset_right = bg_border_size * bg_border_hscale
	bubbleBG.offset_bottom = bg_border_size * bg_border_vscale
	bubbleShadow.anchor_bottom = 1.12 - 0.08 * bg_border_curve.sample(remap(bg_border_vscale, 1, 10, 0, 1))
	
	#vscale = 1, anchor = 1.12
	#vscale = 10, anchor = 1.04
	# 1.2 - vscale * 0.1
	
	await get_tree().process_frame 
	
	
	bubbleText.pivot_offset = bubbleText.size / 2
	bubbleBG.pivot_offset = bubbleBG.size / 2
	bubbleShadow.pivot_offset = bubbleShadow.size / 2
	pivot_offset = size / 2
	
	if _debug: print("[ButtonBubble(",name,")] Finished resizing!")


#func set_sizes(_min_height:int,_min_width:int,_max_width:int,_min_char_threshold:int,_max_char_threshold:int):
	#min_height = _min_height
	#min_width = _min_width
	#max_width = _max_width
	#min_char_threshold = _min_char_threshold
	#max_char_threshold = _max_char_threshold


#region Meta links

func _send_meta_link_1():
	click()
	meta_link_1.emit()

func _send_meta_link_2():
	click()
	meta_link_2.emit()

func _send_meta_link_3():
	click()
	meta_link_3.emit()

func _send_meta_link_4():
	click()
	meta_link_4.emit()

func _send_meta_link_5():
	click()
	meta_link_5.emit()

func _send_meta_link_6():
	click()
	meta_link_6.emit()

func _send_meta_link_7():
	click()
	meta_link_7.emit()

func _send_meta_link_8():
	click()
	meta_link_8.emit()

func _send_meta_link_9():
	click()
	meta_link_9.emit()

#endregion


func check_meta_link_from_button() -> void:
	if bubbleText.text.contains("{"):
		if _debug: print("[ButtonBubble(",name,")] Button clicked, sending link '",bubbleText.text.substr(bubbleText.text.findn("{"),2),"'...")
		bubbleText._link_clicked(bubbleText.text.substr(bubbleText.text.findn("{"),3))
	elif _debug: print("[ButtonBubble(",name,")] Button clicked but no '{' detected, ignoring.")
