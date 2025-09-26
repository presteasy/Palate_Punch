extends Node
class_name FrameData

var frame = 0
var freeze_frames = 0
var cooldown = 0
var shield_buffer = 0
@onready var parent = get_parent()
var landing_frames = 0
var lag_frames = 0

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
	
func _physics_process(delta: float) -> void:
	if freeze_frames > 0:
		return
	update_frames(delta)
	
	
	
