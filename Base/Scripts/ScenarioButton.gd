@tool 
extends MarginContainer
class_name ScenarioButton

@export var _debug := false
@export var _updateInEditor := false

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



var infoText_LB : LabelController
var button_B : Button
var animator_AP : AnimationPlayer

var old_text := ""
var last_anim := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_getrefs()

func _getrefs() -> void:	
	infoText_LB = get_child(0).get_child(0).get_child(0)
	animator_AP = get_child(2)

#region Editor only

func _process(delta: float) -> void:
	if _updateInEditor && Engine.is_editor_hint():
		if infoText_LB == null: _getrefs()
		
		if infoText_LB.get_parsed_text() != old_text:
			if _debug: print("[ScenarioButton] In-editor resize triggered")
			old_text = infoText_LB.get_parsed_text()
			set_margins_from_lines()

#endregion





func set_info(_info:String):
	if _debug: print("[ScenarioButton] Setting description: ",_info)
	infoText_LB.populate(_info)



func pop_in() -> void:
	if _debug: print("[ScenarioButton] Popping in.")
	animator_AP.play("ScenarioButton_Start")

func pop_out() -> void:
	if _debug: print("[ScenarioButton] Popping out...")
	if button_B.visible:
		if _debug: print("[ScenarioButton] Text still out, minimising first...")
		animator_AP.play("ScenarioButton_Minimise")
		await get_tree().process_frame  
		await !animator_AP.is_playing()
	if _debug: print("[ScenarioButton] Text hidden, finishing.")
	animator_AP.play("ScenarioButton_Finish")


func toggle() -> void:
	if _debug: print("[ScenarioButton] Toggling, text is ","visible" if infoText_LB.visible else "not visible...")
	if infoText_LB.visible:
		minimise()
	else:
		press()

func press() -> void:
	if _debug: print("[ScenarioButton] Pressing.")
	animator_AP.play("ScenarioButton_Press")

func minimise() -> void:
	if _debug: print("[ScenarioButton] Minimising.")
	animator_AP.play("ScenarioButton_Minimise")


func enable_button() -> void:
	if _debug: print("[ScenarioButton] Enabling press")
	button_B.visible = false

func disable_button() -> void:
	if _debug: print("[ScenarioButton] Disabling press")
	button_B.visible = true



func set_margins_from_lines(lines:int=infoText_LB.get_line_count()) -> void:
	#if adjust_left: add_theme_constant_override("margin_left",lines*left_multiplier)
	#if adjust_right: add_theme_constant_override("margin_right",lines*right_multiplier)
	var _lines = clampi(lines,min_lines,max_lines)
	if _debug:  print("[ScenarioButton] lines = ",lines,", _lines = ",_lines,", _lines - min_lines = ",_lines-min_lines,", top_multiplier = ",top_multiplier,", final adjust = ",(_lines - min_lines) * top_multiplier)
	
	if adjust_top: add_theme_constant_override("margin_top",(_lines - min_lines) * top_multiplier + top_addition)
	if adjust_bottom: add_theme_constant_override("margin_bottom",(_lines - min_lines) * bottom_multiplier + bottom_addition)
	
	if _debug:  print("[ScenarioButton] Pivot Offset = ",infoText_LB.pivot_offset,", Size = ",infoText_LB.size)
	
	infoText_LB.pivot_offset = Vector2(infoText_LB.pivot_offset.x, infoText_LB.size.y)
	
	if _debug:  print("[ScenarioButton] Pivot Offset = ",infoText_LB.pivot_offset,", Size = ",infoText_LB.size)
