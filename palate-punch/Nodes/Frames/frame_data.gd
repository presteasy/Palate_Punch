extends Node
class_name FrameData

@onready var parent = get_parent()

@export var input_buffer : Node

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
		
	#if hitstop_frames > 0:
		#hitstop_frames -= floor(delta * 60)
	#hitstop_frames = clampi(hitstop_frames, 0, hitstop_frames)
	
func apply_hitstop_frames(duration: int) -> void:
	hitstop_frames = duration
	
func _frame() -> void:
	#print("🔴 _frame() RESET called! Stack trace:")
	#print_stack()
	frame = 0
	
func _physics_process(delta: float) -> void:
	if InputHandler.is_gameplay_mode() == true:
		#if hitstop_frames > 0:
			#hitstop_frames -= 1
		if input_buffer:
			input_buffer.tick(frame)

		update_frames(delta)


	
	
	
