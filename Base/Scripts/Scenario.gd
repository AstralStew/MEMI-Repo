extends Node

@export var debugging : bool = false
var title_L : Label
var info_L : LabelController
var emergency_L : LabelController
var location_L : LabelController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_L = get_child(0).get_child(0)
	info_L = get_child(1).get_child(0).get_child(0).get_child(0)
	emergency_L = get_child(2).get_child(0).get_child(0).get_child(0)
	location_L = get_child(3).get_child(0).get_child(0).get_child(0)


func set_description(_title:String,_info:String,_emergency:String,_location:String):
	if debugging: print("[Scenario] Setting description: Title = ",_title,", Info = ",_info,", Emergency = ",_emergency,", Location = ",_location,"")
	title_L.text = _title
	info_L.populate(_info) 
	emergency_L.populate(_emergency) 
	location_L.populate(_location) 
