extends Node


@export var exit_button:ButtonBubble
@export var overlay:Control
@export var menu:Control
#@export var animator:AnimationPlayer
@export var debugging := false
@export var exit_text := "MENU_EXIT"
@export var back_text := "MENU_BACK"

@export_group("Colours")
@export var light_button_text_colour := Color.BLACK
#@export var light_exit_button_bg := Color(1,1,1,0.3)
@export var dark_button_text_colour := Color.WHITE
#@export var exit_button_bg := Color(1,1,1,0.3)
@export var overlay_colour := Color.WHITE


@export_group("Animations")
@export var slide_in_duration := 0.25
@export var slide_in_ease := Tween.EaseType.EASE_IN_OUT
@export var slide_in_transition := Tween.TransitionType.TRANS_BOUNCE
@export var slide_in_menu_pos := Vector2(0,0)
@export var slide_out_duration := 0.25
@export var slide_out_ease := Tween.EaseType.EASE_OUT
@export var slide_out_transition := Tween.TransitionType.TRANS_BOUNCE
@export var slide_out_menu_pos := Vector2(0,0)
@export var fade_overlay_duration := 0.25
@export var fade_overlay_ease := Tween.EaseType.EASE_OUT
@export var fade_overlay_transition := Tween.TransitionType.TRANS_BOUNCE

@export_group("READ ONLY")
@export var is_dark = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	overlay.modulate = Color(overlay_colour,0)
	await get_tree().create_timer(5).timeout 
	exit_button.pop_in(exit_text)


func slide_in() -> void:
	if debugging: print("[ExitMenu] Sliding in menu!")
	get_tree().paused = true
	
	overlay.visible = true
	_fade_overlay(overlay_colour,fade_overlay_duration,fade_overlay_ease,fade_overlay_transition)
	_slide_menu(slide_in_menu_pos,slide_in_duration,slide_in_ease,slide_in_transition)
	
	await get_tree().create_timer(0.3,true,false).timeout 
	exit_button.pop_in(back_text)
	
	#_fade_button(Color(1,1,1,0),0.1,Tween.EaseType.EASE_IN_OUT,Tween.TransitionType.TRANS_LINEAR)
	#fading_button.tween_callback(exit_button._set_text.bind(back_text))
	#fading_button.tween_callback(_fade_button.bind(Color(1,1,1,1),0.1,Tween.EaseType.EASE_IN_OUT,Tween.TransitionType.TRANS_LINEAR))

func slide_out() -> void:
	if debugging: print("[ExitMenu] Sliding in menu!")
	get_tree().paused = false
	
	_fade_overlay(Color(overlay_colour,0),fade_overlay_duration,fade_overlay_ease,fade_overlay_transition)
	fading_overlay.tween_callback(overlay.set.bind("visible",false))
	_slide_menu(slide_out_menu_pos,slide_out_duration,slide_out_ease,slide_out_transition)
	
	await get_tree().create_timer(0.3,true,false).timeout 
	exit_button.pop_in(exit_text)
	
	#_fade_button(Color(1,1,1,0),0.1,Tween.EaseType.EASE_IN_OUT,Tween.TransitionType.TRANS_LINEAR)
	#fading_button.tween_callback(exit_button._set_text.bind(exit_text))
	#fading_button.tween_callback(_fade_button.bind(Color(1,1,1,1),0.1,Tween.EaseType.EASE_IN_OUT,Tween.TransitionType.TRANS_LINEAR))
	#fading_button.tween_callback(get_tree().set.bind("paused",false))

func switch_colours(_dark:bool=false) -> void:
	if _dark == is_dark:
		push_warning("[ExitMenu] WARNING -> Was already ","dark" if _dark else "light","! Ignoring.")
		return
	elif debugging: print("[ExitMenu] Switching to ","dark" if _dark else "light...")
	
	is_dark = _dark
	if is_dark:
		exit_button._set_text_colour(dark_button_text_colour)
	else:
		exit_button._set_text_colour(light_button_text_colour)



var sliding_menu
func _slide_menu(_position:Vector2,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if sliding_menu:
		sliding_menu.kill()
	sliding_menu = create_tween()
	#sliding_menu.set_ignore_time_scale(true)
	
	sliding_menu.tween_property(menu, "position", _position, _duration).set_ease(_ease).set_trans(_transition)
	

var fading_overlay
func _fade_overlay(_colour:Color,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if fading_overlay:
		fading_overlay.kill()
	fading_overlay = create_tween()
	#fading_overlay.set_ignore_time_scale(true)
	
	fading_overlay.tween_property(overlay, "modulate", _colour, _duration).set_ease(_ease).set_trans(_transition)

#
#var fading_button
#func _fade_button(_colour:Color,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	#if fading_button:
		#fading_button.kill()
	#fading_button = create_tween()
	##fading_button.set_ignore_time_scale(true)
	#
	#fading_button.tween_property(exit_button, "modulate", _colour, _duration).set_ease(_ease).set_trans(_transition)
