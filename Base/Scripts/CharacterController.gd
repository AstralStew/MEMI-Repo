@tool 
extends TextureController
class_name CharacterController


@export_group("Moving")

@export var inactive_pos : Vector2i = Vector2i(150,180)
@export var inactive_dur : float = 0.25
@export var inactive_ease : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var inactive_trans : Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR

@export var active_pos : Vector2i = Vector2i(150,-130)
@export var active_dur : float = 0.25
@export var active_ease : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var active_trans : Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR

@export_group("Auto Pose")

@export var auto_inactive := false
@export var auto_pose : Constants.CharacterPoses = Constants.CharacterPoses.Explain

@export_group("Read Only")

@export var language : Constants.LanguageCode = Constants.LanguageCode.en
@export var current_pose : Constants.CharacterPoses = Constants.CharacterPoses.HalfTryAgain

#@export var test : Array[Texture]= false

#const enCharacter_HalfTryAgain
#const enCharacter_Explain
#const enCharacter_Point
#const enCharacter_Talking
#const enCharacter_ThumbsUp
#const enCharacter_Yay
#const enCharacter_Postbox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if auto_check:
		language = LanguageManager.currentLanguage
		switch_pose(Constants.CharacterPoses.keys()[auto_pose] as String)
		if debugging: print("[CharacterController] Language = ",language,", Pose path = ",pose_path(auto_pose))

func switch_language() -> void:
	super()
	#language = LanguageManager.currentLanguage
	switch_pose(Constants.CharacterPoses.keys()[current_pose] as String)



func pop_in(poseName:String = "") -> void:	
	if debugging: print("[CharacterController(",name,")] NOTE -> Popping in!")

	if poseName != "":
		switch_pose(poseName)
	
	await get_tree().create_timer(0.1).timeout
	
	# move character up
	if position != Vector2(active_pos): _move_char(Vector2(active_pos),active_dur,active_ease,active_trans)

func pop_out() -> void:
	if debugging: print("[CharacterController(",name,")] NOTE -> Popping out!")
	
	# move chacter down + turn invisible after
	if position != Vector2(inactive_pos): _move_char(Vector2(inactive_pos),inactive_dur,inactive_ease,inactive_trans)




#func switch_pose(pose:Constants.CharacterPoses) -> void:	
	#if debugging: print("[CharacterController] Switching pose to ",pose," (at '",pose_path(auto_pose),"')")
	#texture = load(pose_path(pose))
	#current_pose = pose
#
#func fade_to_pose(pose:Constants.CharacterPoses, duration:float) -> void:
	#if debugging: print("[CharacterController] Fading pose to ",pose," (at '",pose_path(auto_pose),"') over ",duration," seconds...")
	#var image = load(pose_path(pose))
	#fade_to_image(image,duration)


var moving_char
func _move_char(_position:Vector2,_duration:float,_ease:Tween.EaseType,_transition:Tween.TransitionType) -> void:
	if moving_char:
		moving_char.kill()
	moving_char = create_tween()	
	moving_char.tween_property(self, "position", _position, _duration).set_ease(_ease).set_trans(_transition)




func switch_pose(poseName:String) -> void:
	language = LanguageManager.currentLanguage
	var pose = pose_from_string(poseName)
	if debugging: print("[CharacterController(",name,")] Switching pose to ",pose," (at '",pose_path(auto_pose),"')")
	texture = load(pose_path(pose))
	current_pose = pose

func fade_to_pose(poseName:String, duration:float) -> void:
	language = LanguageManager.currentLanguage
	var pose = pose_from_string(poseName)
	if debugging: print("[CharacterController(",name,")] Fading pose to ",pose," (at '",pose_path(auto_pose),"') over ",duration," seconds...")
	var image = load(pose_path(pose))
	fade_to_image(image,duration)





func pose_path(pose:Constants.CharacterPoses) -> String:
	var poseEnum = (Constants.CharacterPoses.keys()[pose] as String)
	var langEnum = (Constants.LanguageCode.keys()[language] as String).capitalize()
	return "res://AssetPacks/1_Character"+langEnum+"/Character"+langEnum+"_"+poseEnum+".png"

func pose_from_string(poseName:String) -> Constants.CharacterPoses:
	if !Constants.CharacterPoses.has(poseName):
		push_error("[CharacterController(",name,")] ERROR -> Could not find pose '",poseName,"'! Returning default.")
		return 0 as Constants.CharacterPoses
	return Constants.CharacterPoses.get(poseName)
