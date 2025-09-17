@tool 
extends MarginContainer
class_name TapBubble


@export var _debug := false
@export var _updateInEditor := false

@export_group("References")
@export var default_tap_hint : SpriteFrames = null
@export var pop_in_sound : AudioStream = null
@export var correct_sound : AudioStream = null
@export var incorrect_sound : AudioStream = null

@export_group("Bubble")
@export var bubble_resize_in := 0.25
#@export var bubble_resize_out := 1.0
@export var bubble_resize_ease := Tween.EaseType.EASE_OUT
@export var bubble_resize_trans := Tween.TransitionType.TRANS_SPRING
@export var bubble_fade_in := 0.25
@export var bubble_fade_out := 0.1
@export var bubble_fade_ease := Tween.EaseType.EASE_IN_OUT
@export var bubble_fade_trans := Tween.TransitionType.TRANS_LINEAR

@export_group("Correct")
@export var correct_colour := Color("98d67e")
@export var correct_size := 1.025
@export var correct_inout := 0.075
@export var correct_ease := Tween.EaseType.EASE_OUT_IN
@export var correct_trans := Tween.TransitionType.TRANS_LINEAR

@export_group("Incorrect")
@export var incorrect_colour := Color("2e2e2e")
@export var incorrect_size := 0.99
@export var incorrect_inout := 0.165
@export var incorrect_ease := Tween.EaseType.EASE_OUT
@export var incorrect_trans := Tween.TransitionType.TRANS_BOUNCE
@export var incorrect_pause := 1.5

@export_group("Recieve Touch")
@export var receive_touch_size := 0.985
@export var receive_touch_inout := 0.05
@export var receive_touch_ease := Tween.EaseType.EASE_OUT_IN
@export var receive_touch_trans := Tween.TransitionType.TRANS_LINEAR



@export_group("Touch Hint")
@export var touch_hint_fade_in := 0.25
@export var touch_hint_fade_out := 0.1
@export var touch_hint_ease := Tween.EaseType.EASE_IN_OUT
@export var touch_hint_trans := Tween.TransitionType.TRANS_LINEAR
@export var pulse_start_delay := 3.0
@export var pulse_in := 0.25
@export var pulse_out := 0.25
#@export var bubble_resize_out := 1.0
@export var pulse_in_ease := Tween.EaseType.EASE_IN
@export var pulse_out_ease := Tween.EaseType.EASE_OUT
@export var pulse_in_trans := Tween.TransitionType.TRANS_LINEAR
@export var pulse_out_trans := Tween.TransitionType.TRANS_LINEAR
@export var pulse_size := 1.015

@export_group("Speaking Dots")
@export var speaking_dots_fade_in := 0.25
@export var speaking_dots_fade_out := 0.1
@export var speaking_dots_ease := Tween.EaseType.EASE_IN_OUT
@export var speaking_dots_trans := Tween.TransitionType.TRANS_LINEAR

@export_group("Autostart")
@export var _autostart := false
@export_multiline var _auto_text := ""
@export var _auto_title := ""
@export var _auto_bg_colour := Color.WHITE
@export var _auto_text_colour := Color.BLACK
@export var _auto_touch_hint : TouchHint = TouchHint.Default

@export_group("Read Only")
@export var _current_touch_hint : TouchHint = TouchHint.Default

#@export_group("Size Parametres")
#@export var min_height := 151
#@export var min_width := 228
#@export var max_width := 228
#@export var min_char_threshold := 4
#@export var max_char_threshold := 25
#@export_group("Read Only")
#@export var _old_text := ""

enum TouchHint{Default,Slim,Keep} 

# Private variables
var bubbleText : LabelController
var bubbleBG : NinePatchRect
var bubbleTitle : LabelLiteController
var bubbleTapHint : AnimatedSprite2D
var speakingDots : AnimatedSprite2D
var bubbleTouchButton : Button
var bubbleTouchAudio : AudioStreamPlayer

signal touch_input
#signal meta_link_1
#signal meta_link_2
#signal meta_link_3
#signal meta_link_4
#signal meta_link_5
#signal meta_link_6
#signal meta_link_7
#signal meta_link_8
#signal meta_link_9


#region Initialisation

func _ready() -> void:
	_getrefs()
		
	bubbleText.pivot_offset = bubbleText.size / 2
	bubbleBG.pivot_offset = bubbleBG.size / 2
	
	match LanguageManager.currentLanguage:
		Constants.LanguageCode.en:
			bubbleTitle.layout_direction = Control.LAYOUT_DIRECTION_LTR
		Constants.LanguageCode.ar:
			bubbleTitle.layout_direction = Control.LAYOUT_DIRECTION_RTL
		Constants.LanguageCode.prs:
			bubbleTitle.layout_direction = Control.LAYOUT_DIRECTION_RTL
		Constants.LanguageCode.zh:
			bubbleTitle.layout_direction = Control.LAYOUT_DIRECTION_LTR
	
	if _autostart: 
		if _debug: print("[Bubble(",name,")] Initialising...")
		
		bubbleText.scale = Vector2.ZERO
		modulate = Color(1,1,1,0)
		_current_touch_hint = TouchHint.Default
		
		if Engine.is_editor_hint(): bubbleText.text =_auto_text
		else: bubbleText.populate(_auto_text)
		_set_title(_auto_title)
		_set_colours(_auto_bg_colour,_auto_text_colour)
		_set_touch_hint(_auto_touch_hint)
		
		#bubbleText.text =_auto_text
		#_set_title(_auto_title)
		#_set_colours(_auto_bg_colour,_auto_text_colour)
		#_set_touch_hint(_auto_touch_hint)

func _getrefs() -> void:	
	bubbleText = get_child(0)
	bubbleBG = bubbleText.get_child(0)
	bubbleTitle = bubbleText.get_child(1) #bubbleTitle = bubbleBG.get_child(0)
	bubbleTapHint = bubbleBG.get_child(0)
	speakingDots = bubbleBG.get_child(1)
	bubbleTouchButton = get_child(1)
	bubbleTouchAudio = get_child(2)
	
	## Connect tapping bubble to speech recognition
	## NOTE -> Immediate parent must be screen prefab for this to work
	#var parent = get_parent()
	#if parent && parent is ScreenPrefab:
		#touch_input.connect(parent.start_speech_recognition)
		#parent.last_sentence_changed.connect(answer)

#func _exit_tree() -> void:
	#if touch_input.has_connections():
		#for connection in touch_input.get_connections():
			#touch_input.disconnect(connection.callable)

func _process(delta: float) -> void:
	if _updateInEditor && Engine.is_editor_hint():
		if bubbleText == null: _getrefs()
		
		if _autostart && (bubbleText.text !=_auto_text || bubbleTitle.text != _auto_title || bubbleBG.self_modulate != _auto_bg_colour):
			if _debug: print("[Bubble(",name,")] Auto processing in editor...")			
			bubbleText.text =_auto_text
			_set_title(_auto_title)
			_set_colours(_auto_bg_colour,_auto_text_colour)
			_set_touch_hint(_auto_touch_hint)
		
		#if bubbleText.get_parsed_text() != _old_text:
			#if _debug: print("[TapBubble(",name,")] In-editor resize triggered")
			#_old_text = bubbleText.get_parsed_text()

#endregion




#region MEMI functions

func pop_in() -> void:
	if _debug: print("[TapBubble(",name,")] NOTE -> Popping in!")
	reset()
	visible = true
	
	# resize + fade
	_resize_bubble(true,bubble_resize_in,bubble_resize_ease,bubble_resize_trans)
	_fade_bubble(true,bubble_fade_in,bubble_fade_ease,bubble_fade_trans)
	
	# activate touch once resize is finished
	bubble_resize.tween_callback(activate_touch_input)
	
	# play sound
	bubbleTouchAudio.stream = pop_in_sound
	bubbleTouchAudio.play()

func pop_out() -> void:
	if _debug: print("[TapBubble(",name,")] NOTE -> Popping out!")
	
	# fade out bubble (no resize)
	_fade_bubble(false,bubble_fade_out,bubble_fade_ease,bubble_fade_trans)
	bubble_fade.tween_callback(set.bind("visible",false))

func activate_touch_input() -> void:
	if _debug: print("[TapBubble(",name,")] NOTE -> Ready to answer - activating touch hint...")
	
	await get_tree().create_timer(0.5).timeout
	
	# turn on button to allow tapping
	bubbleTouchButton.visible = true
	
	# fade in touch hint
	match _current_touch_hint:
		TouchHint.Default:
			if _debug: print("[TapBubble(",name,")] TouchHint.Default - Turning on touch hint...")
			_fade_touch_hint(true, touch_hint_fade_in,touch_hint_ease,touch_hint_trans)
			# turn on button to allow tapping
			#touch_hint_fade.tween_callback(bubbleTouchButton.set.bind("visible",true))
		TouchHint.Slim:
			if _debug: print("[TapBubble(",name,")] TouchHint.Slim - Pulsing...")
			_pulse_background()
			# turn on button to allow tapping
			#background_resize.tween_callback(bubbleTouchButton.set.bind("visible",true))
		TouchHint.Keep:
			push_error("[TapBubble(",name,")] ERROR -> CurrentTouchHint is on Keep! Shouldn't be possible. Ignoring :(")
		_:
			push_error("[TapBubble(",name,")] ERROR -> No matching touch hint! Shouldn't be possible. Ignoring :(")

func answer(_text:String) -> void:	
	if _debug: print("[TapBubble(",name,")] NOTE -> Answer received! Setting text...")
	
	# fade out dots
	_fade_speaking_dots(false,speaking_dots_fade_out,speaking_dots_ease,speaking_dots_trans)
	
	# set text once speaking dots have faded out
	speaking_dots_fade.tween_callback(_set_text.bind(_text))
	

func correct() -> void:	
	if _debug: print("[TapBubble(",name,")] NOTE -> Correct answer! Setting to green and bouncing...")
	# fade to correct colour + resize background twice to bounce
	_fade_background(correct_colour,correct_inout,correct_ease,Tween.TransitionType.TRANS_LINEAR)
	_resize_background(correct_size,correct_inout,correct_ease,correct_trans)
	background_resize.tween_callback(_resize_background.bind(1.0,correct_inout,correct_ease,correct_trans))
	
	# play sound
	bubbleTouchAudio.stream = correct_sound
	bubbleTouchAudio.play()

func incorrect() -> void:
	if _debug: print("[TapBubble(",name,")] NOTE -> Incorrect answer. Setting to grey...")
	
	bubbleText.add_theme_color_override("default_color", Color.WHITE)
	
	# fade to incorrect colour + resize background twice to bounce
	_fade_background(incorrect_colour,incorrect_inout,incorrect_ease,Tween.TransitionType.TRANS_LINEAR)
	_resize_background(incorrect_size,incorrect_inout,incorrect_ease,incorrect_trans)
	background_resize.tween_callback(_resize_background.bind(1.0,incorrect_inout,incorrect_ease,incorrect_trans))
	
	# play sound
	bubbleTouchAudio.stream = incorrect_sound
	bubbleTouchAudio.play()
	
	# reset after a second IF we haven't popped out in the meantime
	await get_tree().create_timer(incorrect_pause).timeout
	if !visible: return
	reset()
	
	# re-activate touch
	activate_touch_input()
	
	# play sound
	bubbleTouchAudio.stream = pop_in_sound
	bubbleTouchAudio.play()

func reset() -> void:
	_set_properties(_auto_text,_auto_title,_auto_bg_colour,_auto_text_colour,_auto_touch_hint)
	bubbleTapHint.modulate = Color(1,1,1,0)
	bubbleTapHint.stop()
	speakingDots.modulate = Color(1,1,1,0)
	speakingDots.stop()

#endregion


func _received_touch_input() -> void:
	if _debug: print("[TapBubble(",name,")] ReceivedTouchInput. Disabling hint, enabling speaking dots, and sending touch input...")
	bubbleTouchButton.visible = false
	bubbleText.text = ""
	if _current_touch_hint == TouchHint.Default:
		_fade_touch_hint(false,touch_hint_fade_out,touch_hint_ease,touch_hint_trans)
	elif _current_touch_hint == TouchHint.Slim:
		_pulse_background_finish()
	_fade_speaking_dots(true,speaking_dots_fade_in,speaking_dots_ease,speaking_dots_trans)
	_resize_background(receive_touch_size,receive_touch_inout,receive_touch_ease,receive_touch_trans)
	background_resize.tween_callback(_resize_background.bind(1.0,receive_touch_inout,receive_touch_ease,receive_touch_trans))
	
	touch_input.emit()



#region Set properties


func _set_properties(_text:String,_title:String="",_bgColour:Color=Color.WHITE,_textColour:Color=Color.BLACK,_touchHint:TouchHint=TouchHint.Keep) -> void:
	if _debug: print("[TapBubble(",name,")] NOTE -> Setting all properties...")
	
	_set_text(_text)
	_set_title(_title)
	_set_colours(_bgColour,_textColour)
	_set_touch_hint(_touchHint)
	
	if _debug: print("[TapBubble(",name,")] NOTE -> Finished setting all properties!")



func _set_text(_text:String=""):
	bubbleText.populate(_text)
	if _debug: print("[TapBubble(",name,")] Text set to '",_text,"'")

func _set_title(_title:String="") -> void:
	if Engine.is_editor_hint():
		bubbleTitle.text = _title
	else: 
		bubbleTitle.populate(_title)
	if _debug: print("[TapBubble(",name,")] Title set to '",_title,"'")



func _set_colours(_bgColour:Color=Color.WHITE,_textColour=Color.BLACK):
	_set_background_colour(_bgColour)
	_set_text_colour(_textColour)

func _set_text_colour(_colour:Color=Color.BLACK):
	if _debug: print("[TapBubble(",name,")] Setting text colour to ",_colour)
	bubbleText.add_theme_color_override("default_color",_colour)

func _set_background_colour(_colour:Color=Color.WHITE):
	if _debug: print("[TapBubble(",name,")] Setting background colour to ",_colour)
	# Moved this here to reset just in case? Maybe a dedicated reset anyway
	bubbleBG.self_modulate = _colour




func _set_touch_hint(_touchHint:TouchHint) -> void:
	match _touchHint:
		TouchHint.Default:
			if _debug: print("[TapBubble(",name,")] Setting touch hint to ",_touchHint)
			bubbleTapHint.sprite_frames = default_tap_hint
			_current_touch_hint = TouchHint.Default
		TouchHint.Slim:
			if _debug: print("[TapBubble(",name,")] Setting touch hint to ",_touchHint)
			#bubbleTapHint.sprite_frames = slim_tap_hint
			_current_touch_hint = TouchHint.Slim
			pass
		TouchHint.Keep:	
			if _debug: print("[TapBubble(",name,")] Setting touch hint to ",_touchHint," (i.e. Ignoring)")
			pass # ignore when set to Keep
		_:
			push_error("[TapBubble(",name,")] ERROR -> No matching touch hint! Shouldn't be possible. Setting to Default.")
			bubbleTapHint.sprite_frames = default_tap_hint
			_current_touch_hint = TouchHint.Default


#endregion



#region Tween properties

var bubble_resize
func _resize_bubble(_active:bool,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if bubble_resize:
		bubble_resize.kill()
	bubble_resize = create_tween()
	
	if _active:
		bubble_resize.tween_property(bubbleText, "scale", Vector2.ONE, _duration).from(Vector2.ZERO).set_ease(_ease).set_trans(_transition)
		#touch_hint_fade.tween_callback(bubbleTouchButton.set.bind("visible",true))
	else: 
		bubble_resize.tween_property(bubbleText, "scale", Vector2.ZERO, _duration).from(Vector2.ONE).set_ease(_ease).set_trans(_transition)

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
	#print("resize")
	if background_resize:
		background_resize.kill()
	background_resize = create_tween()
	
	background_resize.tween_property(bubbleBG, "scale", Vector2(_target_size,_target_size), _duration).set_ease(_ease).set_trans(_transition)

var is_pulsing = false
var background_pulse
func _pulse_background() -> void:
	if background_pulse:
		background_pulse.kill()
	is_pulsing = true
	await get_tree().create_timer(pulse_start_delay).timeout  
	if is_pulsing:
		_pulsing()
		background_pulse = create_tween().set_loops()
		background_pulse.tween_callback(_pulsing).set_delay(1)

func _pulsing() -> void:
	_resize_background(pulse_size,pulse_in,pulse_in_ease,pulse_in_trans)
	background_resize.tween_callback(self._resize_background.bind(1,pulse_out,pulse_out_ease,pulse_out_trans))

func _pulse_background_finish() -> void:
	is_pulsing = false
	if background_pulse:
		background_pulse.kill()


var background_fade
func _fade_background(_colour:Color,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if background_fade:
		background_fade.kill()
	background_fade = create_tween()
	
	background_fade.tween_property(bubbleBG, "self_modulate", _colour, _duration).set_ease(_ease).set_trans(_transition)



var touch_hint_fade
func _fade_touch_hint(_active:bool,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if touch_hint_fade:
		touch_hint_fade.kill()
	touch_hint_fade = create_tween()
	
	if _active:
		touch_hint_fade.tween_property(bubbleTapHint, "modulate", Color(1,1,1,1), _duration).from(Color(1,1,1,0)).set_ease(_ease).set_trans(_transition)
		touch_hint_fade.tween_callback(bubbleTapHint.play)
		#touch_hint_fade.tween_callback(bubbleTouchButton.set.bind("visible",true))
	else: 
		touch_hint_fade.tween_property(bubbleTapHint, "modulate", Color(1,1,1,0), _duration).from(Color(1,1,1,1)).set_ease(_ease).set_trans(_transition)
		touch_hint_fade.tween_callback(bubbleTapHint.stop)


var speaking_dots_fade
func _fade_speaking_dots(_active:bool,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if speaking_dots_fade:
		speaking_dots_fade.kill()
	speaking_dots_fade = create_tween()
	
	if _active:
		speaking_dots_fade.tween_property(speakingDots, "modulate", Color(1,1,1,1), _duration).from(Color(1,1,1,0)).set_ease(_ease).set_trans(_transition)
		speaking_dots_fade.tween_callback(speakingDots.play)
	else: 
		speaking_dots_fade.tween_property(speakingDots, "modulate", Color(1,1,1,0), _duration).from(Color(1,1,1,1)).set_ease(_ease).set_trans(_transition)
		speaking_dots_fade.tween_callback(speakingDots.stop)

#endregion




#func set_sizes(_min_height:int,_min_width:int,_max_width:int,_min_char_threshold:int,_max_char_threshold:int):
	#min_height = _min_height
	#min_width = _min_width
	#max_width = _max_width
	#min_char_threshold = _min_char_threshold
	#max_char_threshold = _max_char_threshold


##region Meta links
#
#func _send_meta_link_1():
	#meta_link_1.emit()
#
#func _send_meta_link_2():
	#meta_link_2.emit()
#
#func _send_meta_link_3():
	#meta_link_3.emit()
#
#func _send_meta_link_4():
	#meta_link_4.emit()
#
#func _send_meta_link_5():
	#meta_link_5.emit()
#
#func _send_meta_link_6():
	#meta_link_6.emit()
#
#func _send_meta_link_7():
	#meta_link_7.emit()
#
#func _send_meta_link_8():
	#meta_link_8.emit()
#
#func _send_meta_link_9():
	#meta_link_9.emit()

##endregion
