@tool 
extends RichTextLabel

#@export var label: RichTextLabel = null

@export var min_width := 150
@export var max_width := 250
@export var min_char_threshold := 8
@export var max_char_threshold := 16

@export var old_text := ""

#func _ready() -> void:
	# set the label minimum width to 200px
	#label.custom_minimum_size.x = 200
	# set autowrap
	#label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# set the size flags to begin to avoid the label being positioned incorrectly when changing the size
	#label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	#label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	# When the label gets resized, change the size of this panel container to the minimum size of the label
	#label.finished.resized.connect(_resize)



func _process(delta: float) -> void:
	if get_parsed_text() != old_text:
		old_text = get_parsed_text()
		_resize()


func _resize() -> void:
	print("resize time")
	
	custom_minimum_size = Vector2(max_width,0)
	await get_tree().process_frame 
	var max_line_length = 0
	for i in get_line_count():
		print("line index = ",i,", range = ", get_line_range(i), "sub = ", get_line_range(i).y - get_line_range(i).x)
		max_line_length = maxi(get_line_range(i).y - get_line_range(i).x, max_line_length)
	
	var min_size = clamp(remap(max_line_length,min_char_threshold,max_char_threshold,min_width,max_width),min_width,max_width)
	
	
	print("get_line_count() = ",get_line_count(),"max_line_length = ",max_line_length,", min_size = ",min_size)
	
	
	custom_minimum_size = Vector2(min_size,0)
		
	
	#get_parsed_text().length()
	
	#if visible_ratio < 1:
	
	#size = Vector2i(clampi(label.get_minimum_size().x,150,250),0)	
