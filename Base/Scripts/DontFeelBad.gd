class_name DontFeelBad
extends Control

@export var has_been_opened := false

@export var fade_duration := 0.5

@onready var comment_bubble : CommentBubble = find_child("CommentBubble")
@onready var button_bubble : ButtonBubble = find_child("ButtonBubble")


func open() -> void:
	if has_been_opened: return
	has_been_opened = true
	visible = true
	
	get_tree().paused = true
	
	var open_tween = create_tween()
	open_tween.tween_property(self, "modulate", Color(1,1,1,1), fade_duration)
	await get_tree().create_timer(fade_duration + 0.1,true,false,true)
	comment_bubble.pop_in("DONT_FEEL_BAD_T1")
	await get_tree().create_timer(fade_duration + 0.1,true,false,true)
	button_bubble.pop_in("DONT_FEEL_BAD_B1")


func close() -> void:
	await get_tree().create_timer(0.5,true,false,true)
	comment_bubble.pop_out()
	await get_tree().create_timer(0.5,true,false,true)
	var close_tween = create_tween()
	close_tween.tween_property(self, "modulate", Color(1,1,1,0), fade_duration)
	
	close_tween.tween_callback(set.bind("visible", false))
	
	await get_tree().create_timer(fade_duration,true,false,true)
	
	get_tree().paused = false
