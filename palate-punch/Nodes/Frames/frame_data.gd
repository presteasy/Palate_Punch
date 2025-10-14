extends Node
class_name FrameData

@onready var parent = get_parent()

const FPS: float = 60.0

var frame: int = 0

var global_frame: int = 0

@export var lag_frames: int = 0
@export var landing_lag_frames: int = 0
var hitstop_frames: int = 0


var cooldown: int = 0
var shield_buffer: int = 0



func update_frames(delta: float) -> void:
	frame += floor(delta * 60)
	
	cooldown -= floor(delta * 60)
	cooldown = clampi(cooldown, 0, cooldown)
	
	#if not Input.is_action_pressed("block_%s" % parent.id):
		#shield_buffer = 0
	#elif Input.is_action_pressed("block_%s" % parent.id):
		#shield_buffer += floor(delta * 60)
		
	if hitstop_frames > 0:
		hitstop_frames -= floor(delta * 60)
	hitstop_frames = clampi(hitstop_frames, 0, hitstop_frames)
	
func apply_hitstop_frames(duration: int) -> void:
	hitstop_frames = duration
	
func _frame() -> void:
	frame = 0
	
func _physics_process(delta: float) -> void:
	if hitstop_frames > 0:
		hitstop_frames -= 1
		return
	update_frames(delta)
	

	
	
	
