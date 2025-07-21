extends RichTextEffect
class_name RichTextFadeIn

var bbcode = "fade_in"
var text_index = 0
var range_tmp = 0
var new_text = true

@export var _duration := 0.05
@export var _fade_range := 5
@export var _fade_factor := 0.5

func _init():
	resource_name = "RichTextFadeIn"

# duration lets the fade effect go faster or slower.
# fade_range defines the amount of characters you want to fade in at the same time with a gradient.
# fade_factor is the gradient.
func _process_custom_fx(char_fx):
	var duration = char_fx.env.get("duration", _duration)
	var fade_range = char_fx.env.get("fade_range", _fade_range)
	var fade_factor = char_fx.env.get("fade_factor", _fade_factor)
	var elapsed_time = char_fx.elapsed_time
	
	if new_text and elapsed_time > duration:
		new_text = false
	elif not new_text and elapsed_time < duration:
		text_index = 0
		new_text = true
	
	if ((elapsed_time+duration) / (text_index + duration)) < duration:
		if char_fx.range.x in range(text_index, (text_index+fade_range)):
			var idx = char_fx.range.x - text_index + 1
			char_fx.color.a = elapsed_time / (elapsed_time * (1.0+(idx*fade_factor)))
		elif char_fx.range.x < text_index:
			char_fx.color.a = 1
		else:
			char_fx.color.a = 0
	else:
		text_index += 1
	return true
