extends Node
class_name FrameData

@onready var parent = get_parent()
@onready var anim = %AnimationPlayer

const FPS: float = 60.0

var frame: int = 0
var timeline_on: bool = false
var current_anim: StringName = &""

var global_frame: int = 0

var landing_frames: int = 0
var lag_frames: int = 0
var freeze_frames: int = 0
var cooldown: int = 0
var shield_buffer: int = 0


func start_timeline(anim_name: StringName) -> void:
	timeline_on = true
	frame = 0
	if anim:
		anim.play(anim_name)
		anim.speed_scale = 0.0
		anim.seek(0.0, true)
	
func stop_timeline() -> void:
	timeline_on = false
	if anim:
		anim.speed_scale = 1.0

func update_frames(delta: float) -> void:
	frame += floor(delta * 60)
	
	cooldown -= floor(delta * 60)
	cooldown = clampi(cooldown, 0, cooldown)
	if not Input.is_action_pressed("block_%s" % parent.id):
		shield_buffer = 0
	elif Input.is_action_pressed("block_%s" % parent.id):
		shield_buffer += floor(delta * 60)
		
	if freeze_frames > 0:
		freeze_frames -= floor(delta * 60)
	freeze_frames = clampi(freeze_frames, 0, freeze_frames)
	
func apply_freeze_frames(duration: int) -> void:
	freeze_frames = duration
	
func _frame() -> void:
	frame = 0
	if anim and timeline_on:
		anim.seek(0.0, true)
	
func _physics_process(delta: float) -> void:
	if freeze_frames > 0:
		freeze_frames -= 1
		return
	
	global_frame += 1
	
	frame += 1
	
	if timeline_on:
		if anim:
			anim.seek(float(frame) / FPS, true)
	
	
	
