@tool 
extends MarginContainer
class_name Description

@export var _debug := false
@export var _updateInEditor := false

@export_group("Resize Properties")
@export var min_lines := 2
@export var max_lines := 10
#@export var adjust_left := false
#@export var left_multiplier := 1.0
@export var adjust_top := false
@export var top_multiplier := 1.0
@export var top_addition := 0.0
#@export var adjust_right := false
#@export var right_multiplier := 1.0
@export var adjust_bottom := false
@export var bottom_multiplier := 1.0
@export var bottom_addition := 0.0

@export var descriptionText : RichTextLabel = null
var old_text := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_getrefs()


#region Editor only

func _process(delta: float) -> void:
	if _updateInEditor && Engine.is_editor_hint():
		if descriptionText == null: _getrefs()
		
		if descriptionText.get_parsed_text() != old_text:
			if _debug: print("[Description] In-editor resize triggered")
			old_text = descriptionText.get_parsed_text()
			set_margins_from_lines()

#endregion


func _getrefs() -> void:	
	descriptionText = get_child(0).get_child(0).get_child(0)

func set_margins_from_lines(lines:int=descriptionText.get_line_count()) -> void:
	#if adjust_left: add_theme_constant_override("margin_left",lines*left_multiplier)
	#if adjust_right: add_theme_constant_override("margin_right",lines*right_multiplier)
	var _lines = clampi(lines,min_lines,max_lines)
	if _debug:  print("[Description] lines = ",lines,", _lines = ",_lines,", _lines - min_lines = ",_lines-min_lines,", top_multiplier = ",top_multiplier,", final adjust = ",(_lines - min_lines) * top_multiplier)
	
	if adjust_top: add_theme_constant_override("margin_top",(_lines - min_lines) * top_multiplier + top_addition)
	if adjust_bottom: add_theme_constant_override("margin_bottom",(_lines - min_lines) * bottom_multiplier + bottom_addition)
	
	descriptionText.pivot_offset.y = descriptionText.size.y + 8
