@tool 
extends TextureController
class_name CharacterController



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

func pose_path(pose:Constants.CharacterPoses) -> String:
	var poseEnum = (Constants.CharacterPoses.keys()[pose] as String)
	var langEnum = (Constants.LanguageCode.keys()[language] as String).capitalize()
	return "res://AssetPacks/1_Character"+langEnum+"/Character"+langEnum+"_"+poseEnum+".png"

func pose_from_string(poseName:String) -> Constants.CharacterPoses:
	if !Constants.CharacterPoses.has(poseName):
		push_error("[CharacterController] ERROR -> Could not find pose '",poseName,"'! Returning default.")
		return 0 as Constants.CharacterPoses
	return Constants.CharacterPoses.get(poseName)

#func switch_pose(pose:Constants.CharacterPoses) -> void:	
	#if debugging: print("[CharacterController] Switching pose to ",pose," (at '",pose_path(auto_pose),"')")
	#texture = load(pose_path(pose))
	#current_pose = pose
#
#func fade_to_pose(pose:Constants.CharacterPoses, duration:float) -> void:
	#if debugging: print("[CharacterController] Fading pose to ",pose," (at '",pose_path(auto_pose),"') over ",duration," seconds...")
	#var image = load(pose_path(pose))
	#fade_to_image(image,duration)

func switch_pose(poseName:String) -> void:
	language = LanguageManager.currentLanguage
	var pose = pose_from_string(poseName)
	if debugging: print("[CharacterController] Switching pose to ",pose," (at '",pose_path(auto_pose),"')")
	texture = load(pose_path(pose))
	current_pose = pose

func fade_to_pose(poseName:String, duration:float) -> void:
	language = LanguageManager.currentLanguage
	var pose = pose_from_string(poseName)
	if debugging: print("[CharacterController] Fading pose to ",pose," (at '",pose_path(auto_pose),"') over ",duration," seconds...")
	var image = load(pose_path(pose))
	fade_to_image(image,duration)


func switch_language() -> void:
	super()
	#language = LanguageManager.currentLanguage
	switch_pose(Constants.CharacterPoses.keys()[current_pose] as String)
