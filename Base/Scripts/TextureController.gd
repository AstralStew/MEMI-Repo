extends TextureRect
class_name TextureController


@export var debugging := false
@export var _updateInEditor := false

@export_group("Texture Properties")
@export var auto_check := false
@export var flip_when_RTL := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if auto_check:
		flip_h = flip_when_RTL && is_layout_rtl();
	
	subscribe_to_language_manager()

func subscribe_to_language_manager() -> void:
	if Engine.is_editor_hint(): return
	await LanguageManager != null
	LanguageManager.language_changed.connect(switch_language)

func switch_language() -> void:
	flip_h = flip_when_RTL && is_layout_rtl();



var fading_to_image
func fade_to_image(_image:Texture2D,_duration:float = 0.25,_ease:Tween.EaseType = Tween.EaseType.EASE_IN_OUT,_transition:Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR) -> void:
	
	var mat = material as ShaderMaterial
	mat.set_shader_parameter("weight",0.0)
	mat.set_shader_parameter("target_texture",_image)
	
	if fading_to_image:
		fading_to_image.kill()
	fading_to_image = create_tween()
	
	fading_to_image.tween_property(mat, "shader_parameter/weight", 1.0, _duration).set_ease(_ease).set_trans(_transition)
	fading_to_image.tween_callback(set.bind("texture",_image))
	fading_to_image.tween_callback(mat.set_shader_parameter.bind("weight",0.0))
	fading_to_image.tween_callback(mat.set_shader_parameter.bind("target_texture",null))
	
