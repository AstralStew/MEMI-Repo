extends Node2D

#var x = 1
#var y = 1.0
#var z = "sdfsdfsdfsdf"
#var a = true
#var rotSpeed = 50.0
#var center = Vector2(270,480)
#var raining = true


enum MOVE_TYPE {DIRECT, FOLLOW}

@export var move_type := MOVE_TYPE.DIRECT
@export var speed := 3.0
@export var follow_trigger_distance := 1.0
@export var trigger_buffer_distance := 3.0
var follow_trigger_distance_sqrd := 0.0

#@onready var touch_helper: Node = $"/root/MainLevel/TouchHelper"
var in_range := false
signal JustInRange

func _ready() -> void:	
	follow_trigger_distance_sqrd = follow_trigger_distance*follow_trigger_distance

func _physics_process(delta: float) -> void:
	if (move_type == MOVE_TYPE.DIRECT):
		_direct_control(delta)
	else:
		_follow_cursor(delta)



func _direct_control(delta: float) -> void:
	
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction += Vector2.RIGHT
	
	if Input.is_action_pressed("ui_left"):
		direction += Vector2.LEFT
	
	if Input.is_action_pressed("ui_down"):
		direction += Vector2.DOWN
	
	if Input.is_action_pressed("ui_up"):
		direction += Vector2.UP
	
	position += direction.normalized() * speed * delta

func _follow_cursor(delta: float) -> void:
	#if !touch_helper || touch_helper.state.size() == 0:
		#return	
		#
	#var target:Vector2 = touch_helper.state[0]		
	
	if !TouchHelper || TouchHelper.state.size() == 0:
		return
	var target:Vector2 = TouchHelper.state[0]
	target = get_canvas_transform().affine_inverse() * target 
	
	if !in_range && (target-position).length_squared() < follow_trigger_distance_sqrd - trigger_buffer_distance:
		print("[MoveControl] Just in range! Sending signal...")
		in_range = true
		JustInRange.emit()
	elif in_range && (target-position).length_squared() > follow_trigger_distance_sqrd + trigger_buffer_distance:
		print("[MoveControl] Left range!")
		in_range = false
	
	position += (target-position) * speed * delta
