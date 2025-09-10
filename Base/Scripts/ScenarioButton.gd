@tool 
extends MarginContainer
class_name ScenarioButton

@export var _debug := false
@export var _updateInEditor := false


@export var _info_default_icon : Texture2D = null
@export var _info_highlight_icon : Texture2D = null
@export var _location_default_icon : Texture2D = null
@export var _location_highlight_icon : Texture2D = null
@export var _emergency_default_icon : Texture2D = null
@export var _emergency_highlight_icon : Texture2D = null

@export_group("Resize Properties")
@export var min_lines := 2
@export var max_lines := 10
#@export var adjust_left := false
#@export var left_multiplier := 1.0
@export var adjust_top := true
@export var top_multiplier := 26.0
@export var top_addition := 5.0
#@export var adjust_right := false
#@export var right_multiplier := 1.0
@export var adjust_bottom := true
@export var bottom_multiplier := 0.0
@export var bottom_addition := 80.0



var text_LB : LabelController
var icon_TR : TextureRect
var button_B : Button
var animator_AP : AnimationPlayer

var old_text := ""
var last_anim := ""
var _default_icon : Texture2D = null
var _highlight_icon : Texture2D = null
var _highlighted := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_getrefs()
	
	# Set icon to the Info texture first
	set_to_info()

func _getrefs() -> void:	
	icon_TR = get_child(0).get_child(0)
	text_LB = icon_TR.get_child(0)
	button_B = get_child(1)
	animator_AP = get_child(2)

#region Editor only

func _process(delta: float) -> void:
	if _updateInEditor && Engine.is_editor_hint():
		if text_LB == null: _getrefs()
		
		if text_LB.get_parsed_text() != old_text:
			if _debug: print("[ScenarioButton] In-editor resize triggered")
			old_text = text_LB.get_parsed_text()
			set_margins_from_lines()

#endregion





func set_text(_text:String):
	if _debug: print("[ScenarioButton] Setting description: ",_text)
	text_LB.populate(_text)



func pop_in() -> void:
	if _debug: print("[ScenarioButton] Popping in.")
	animator_AP.play("ScenarioButton_Start")


func pop_out() -> void:
	if _debug: print("[ScenarioButton] Popping out...")
	if text_LB.visible:
		if _debug: print("[ScenarioButton] Text still out, minimising first...")
		animator_AP.play("ScenarioButton_Minimise")
		await get_tree().create_timer(animator_AP.get_animation("ScenarioButton_Minimise").length).timeout
	if _debug: print("[ScenarioButton] Text hidden, finishing.")
	animator_AP.play("ScenarioButton_Finish")


func toggle() -> void:
	if _debug: print("[ScenarioButton] Toggling, text is ","visible" if text_LB.visible else "not visible...")
	if text_LB.visible:
		minimise()
	else:
		press()

func close() -> void:
	if _debug: print("[ScenarioButton] Close -> Text is ","still visible..." if text_LB.visible else "already not visible.")
	if text_LB.visible:
		minimise()


func press() -> void:
	if _debug: print("[ScenarioButton] Pressing.")
	animator_AP.play("ScenarioButton_Press")

func minimise() -> void:
	if _debug: print("[ScenarioButton] Minimising.")
	animator_AP.play("ScenarioButton_Minimise")

func pulse() -> void:
	if _debug: print("[ScenarioButton] Pulsing.")
	animator_AP.play("ScenarioButton_Pulse")


func enable_button() -> void:
	if _debug: print("[ScenarioButton] Enabling press")
	button_B.disabled = false

func disable_button() -> void:
	if _debug: print("[ScenarioButton] Disabling press")
	#if text_LB.visible:
		#minimise()
	#elif _debug: print("[ScenarioButton] DisableButton -> Text already not visible, skipping minimise...")
	#if _debug: print("[ScenarioButton] DisableButton -> Disabling press.")
	button_B.disabled = true


func highlight(_on:bool=true) -> void:
	if _on:
		icon_TR.texture = _highlight_icon
		_highlighted = true
	else:
		icon_TR.texture = _default_icon
		_highlighted = false


func set_to_info() -> void:
	_default_icon = _info_default_icon
	_highlight_icon = _info_highlight_icon
	icon_TR.texture = _highlight_icon if _highlighted else _default_icon

func set_to_location() -> void:
	_default_icon = _location_default_icon
	_highlight_icon = _location_highlight_icon
	icon_TR.texture = _highlight_icon if _highlighted else _default_icon

func set_to_emergency() -> void:
	_default_icon = _emergency_default_icon
	_highlight_icon = _emergency_highlight_icon
	icon_TR.texture = _highlight_icon if _highlighted else _default_icon



func set_margins_from_lines(lines:int=text_LB.get_line_count()) -> void:
	#if adjust_left: add_theme_constant_override("margin_left",lines*left_multiplier)
	#if adjust_right: add_theme_constant_override("margin_right",lines*right_multiplier)
	var _lines = clampi(lines,min_lines,max_lines)
	if _debug:  print("[ScenarioButton] lines = ",lines,", _lines = ",_lines,", _lines - min_lines = ",_lines-min_lines,", top_multiplier = ",top_multiplier,", final adjust = ",(_lines - min_lines) * top_multiplier)
	
	if adjust_top: add_theme_constant_override("margin_top",(_lines - min_lines) * top_multiplier + top_addition)
	if adjust_bottom: add_theme_constant_override("margin_bottom",(_lines - min_lines) * bottom_multiplier + bottom_addition)
	
	if _debug:  print("[ScenarioButton] Pivot Offset = ",text_LB.pivot_offset,", Size = ",text_LB.size)
	
	text_LB.pivot_offset = Vector2(text_LB.pivot_offset.x, text_LB.size.y)
	
	if _debug:  print("[ScenarioButton] Pivot Offset = ",text_LB.pivot_offset,", Size = ",text_LB.size)
