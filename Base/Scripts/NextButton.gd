@tool
class_name NextButton
extends ButtonBubble


@export_group("READ ONLY")

@export var parent : ScreenPrefab
@export var give_up_anim : StringName = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	super._ready()

func setup_next() -> void:
	if _debug: print("[NextBubble(",name,")] Give up anim = ",parent.screen_controller.current_animation)
	give_up_anim = parent.screen_controller.current_animation

func pop_in(_text:String) -> void:
	setup_next()
	super.pop_in(_text)



func click() -> void:
	if _debug: print("[NextBubble(",name,")] Attempting to play '",give_up_anim,"' at marker 'next_question'")
	parent.screen_controller.play_animation(give_up_anim,0,"next_question")
	super.click()


func check_meta_link_from_button() -> void:
	click()
