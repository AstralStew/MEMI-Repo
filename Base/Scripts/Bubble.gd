@tool 
extends MarginContainer

class_name Bubble

@export var _debug := false
@export var _updateInEditor := false

@export_group("Resize Properties")
@export var min_height := 0
@export var min_width := 42
@export var max_width := 250
@export var min_char_threshold := 4
@export var max_char_threshold := 25

@export_group("Optional Autostart")
@export var _autostart := false
@export_multiline var _autoText := ""
@export var _autoTitle := ""
@export var _autoTitleBelow := false
@export var _autoShape : Constants.BubbleShape = Constants.BubbleShape.Default
@export var _autoColor := Color.WHITE
@export var _autoTouchHint := false

@export_group("Read Only")
@export var old_text := ""

# Private variables
var bubbleText : RichTextLabel
var bubbleBG : NinePatchRect
var bubbleTitleTop : Label
var bubbleTitleBottom : Label
var bubbleTouchHint : Control
var bubbleTouchButton : Button

signal touch_input
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
	_getrefs()
	if _autostart: _set_properties(_autoText,_autoTitle,_autoColor,_autoTitleBelow,_autoTouchHint,_autoShape)
	
	# set the label minimum width to 200px
	#label.custom_minimum_size.x = 200
	# set autowrap
	#label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# set the size flags to begin to avoid the label being positioned incorrectly when changing the size
	#label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	#label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	# When the label gets resized, change the size of this panel container to the minimum size of the label
	#label.finished.resized.connect(_resize)

func _getrefs() -> void:	
	bubbleText = get_child(0)
	bubbleBG = bubbleText.get_child(0)
	bubbleTitleTop = bubbleText.get_child(0).get_child(0)
	bubbleTitleBottom = bubbleText.get_child(0).get_child(1)
	bubbleTouchHint = bubbleText.get_child(0).get_child(2)
	bubbleTouchButton = get_child(1)

#region Editor only

func _process(delta: float) -> void:
	if _updateInEditor && Engine.is_editor_hint():
		if bubbleText == null: _getrefs()
		
		if _autostart && bubbleText.text !=_autoText:
			_set_properties(_autoText,_autoTitle,_autoColor,_autoTitleBelow,_autoTouchHint,_autoShape)
		
		if bubbleText.get_parsed_text() != old_text:
			if _debug: print("[Bubble] In-editor resize triggered")
			old_text = bubbleText.get_parsed_text()
			_resize()

#endregion



#region Set properties

func set_text(text:String):
	bubbleText.text = text
	if _debug: print("[Bubble] Text set to '",text,"'")
	_resize()

func set_title(title:String="",titleBelow:bool=false) -> void:
	if title == "":
		if _debug: print("[Bubble] No title, skipping...")
		bubbleTitleTop.visible = false
		bubbleTitleBottom.visible = false
	else:
		if titleBelow:
			bubbleTitleTop.visible = false
			bubbleTitleBottom.visible = true
			bubbleTitleBottom.text = title
			if _debug: print("[Bubble] Bottom title set to '",title,"'")
		else:
			bubbleTitleTop.visible = true
			bubbleTitleBottom.visible = false
			bubbleTitleTop.text = title
			if _debug: print("[Bubble] Top title set to '",title,"'")

func set_touch(touchHint:bool=false) -> void:
	if touchHint: 
		if _debug: print("[Bubble] Touch hint enabled...")
		bubbleTouchHint.visible = true
		bubbleTouchButton.visible = true
	else: 
		if _debug: print("[Bubble] Touch hint disabled...")
		bubbleTouchHint.visible = false
		bubbleTouchButton.visible = false

func set_background(bg:Color=Color.WHITE,shape:Constants.BubbleShape=Constants.BubbleShape.Default):
	if _debug: print("[Bubble] BG shape set to ",shape,"")
	# Moved this here to reset just in case? Maybe a dedicated reset anyway
	match shape:
		Constants.BubbleShape.Rounded:
			bubbleBG.texture = load("res://AssetPacks/0_Shared/Images/RoundedNineSprite.png")
		_:
			bubbleBG.texture = load("res://AssetPacks/0_Shared/Images/BubbleNineSprite.png")
		
	if _debug: print("[Bubble] BG color set to ",bg)
	# Moved this here to reset just in case? Maybe a dedicated reset anyway
	bubbleBG.self_modulate = bg

func _set_properties(text:String,title:String="",bg:Color=Color.WHITE,titleBelow:bool=false,touchHint:bool=false,shape:Constants.BubbleShape = Constants.BubbleShape.Default) -> void:
	if _debug: print("[Bubble(",name,")] Initialising...")
	
	set_text(text)
	set_title(title,titleBelow)	
	set_background(bg,shape)
	set_touch(touchHint)
	
	_resize()


func _set_size_parametres(_min_height:int,_min_width:int,_max_width:int,_min_char_threshold:int,_max_char_threshold:int):
	min_height = _min_height
	min_width = _min_width
	max_width = _max_width
	min_char_threshold = _min_char_threshold
	max_char_threshold = _max_char_threshold

#endregion


func _resize() -> void:
	if _debug: print("[Bubble] Resizing bubble to fit text...")
	
	bubbleText.custom_minimum_size = Vector2(max_width,0)
	#await get_tree().process_frame 
	var max_line_length = 0
	for i in bubbleText.get_line_count():
		if _debug: print("[Bubble] Line index = ",i,", range = ", bubbleText.get_line_range(i), "sub = ", bubbleText.get_line_range(i).y - bubbleText.get_line_range(i).x)
		max_line_length = maxi(bubbleText.get_line_range(i).y - bubbleText.get_line_range(i).x, max_line_length)
	
	var min_size = clamp(remap(max_line_length,min_char_threshold,max_char_threshold,min_width,max_width),min_width,max_width)
		
	if _debug: print("[Bubble] Get_line_count() = ",bubbleText.get_line_count(),"max_line_length = ",max_line_length,", min_size = ",min_size)
		
	bubbleText.custom_minimum_size = Vector2(min_size,min_height)
	
	if _debug: print("[Bubble] Finished resizing!")




func received_touch_input() -> void:
	if _debug: print("[Bubble] ReceivedTouchInput, disabling hint and sending touch input...")
	bubbleTouchButton.visible = false
	bubbleTouchHint.visible = false
	touch_input.emit()

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
