extends StateMachine
class_name SMDummy

@onready var framedata = %FrameData


func _ready() -> void:
	add_state('STAND')
	add_state('HITSTOP')
	add_state('HITSTUN')
	add_state('AIR')
	call_deferred("set_state", states.STAND)

func get_transition(delta):
	parent.move_and_slide()

		
		
	match state:
		states.STAND:
			if not (parent.GroundL.is_colliding() or not parent.GroundR.is_colliding()):
				framedata._frame()
				return states.AIR
			
		states.HITSTOP:
			print("Dummy is Hitfreeze!")
			if framedata.hitstop_frames == 0:
				framedata._frame()
				parent.velocity.x = kbx
				parent.velocity.y = kby
				parent.hdecay = hd
				parent.vdecay = vd
				return states.HITSTUN
			parent.position = pos
			return
			
		states.HITSTUN:
			print("Dummy is HitSTUN!")
			#if framedata.frame >= parent.hitstun:
				#framedata._frame()
				#return states.STAND
			if parent.knockback == null:
				framedata._frame()
				return states.STAND

			if parent.knockback >= 18:
				var bounce = parent.move_and_collide(parent.velocity * delta)
				if bounce:
					parent.velocity = parent.velocity.bounce(bounce.normal) * .8
					parent.hitstun = round(parent.hitstun * .8)
			if parent.velocity.y < 0:
				parent.velocity.y += parent.vdecay * 0.5 * Engine.time_scale
				parent.velocity.y = clampf(parent.velocity.y, parent.velocity.y, 0)
			if parent.velocity.x < 0:
				parent.velocity.x += parent.hdecay * 0.4 * -1 * Engine.time_scale
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
			elif parent.velocity.x > 0:
				parent.velocity.x -= parent.hdecay * 0.4 * Engine.time_scale
				parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
					
			if framedata.frame >= parent.hitstun:
				if parent.knockback >= 24:
					framedata._frame()
					return states.AIR
				else:
					framedata._frame()
					return states.AIR
			elif framedata.frame > 60 * 5:
				return states.AIR


		states.AIR:
			AIRMOVEMENT()
			
			if parent.is_on_floor():
				framedata._frame()
				parent.velocity.y = 0
				return states.STAND
			


func enter_state(new_state, old_state):
	match new_state:
		states.STAND:
			parent.state_label.text = str("STAND")
		states.HITSTUN:
			parent.state_label.text = str("HITSTUN")
		states.HITSTOP:
			parent.state_label.text = str("HITSTOP")
		states.AIR:
			parent.state_label.text = str("AIR")


func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false

func AIRMOVEMENT():
	if parent.velocity.y <= parent.falling_speed:
		parent.velocity.y -= parent.fall_speed


func Falling():
	if state_includes([states.STAND]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
			return true


var kbx
var kby
var hd
var vd
var pos

func hitfreeze(duration, knocback):
	pos = parent.get_position()
	framedata.hitstop_frames = duration
	kbx = knocback[0]
	kby = knocback[1]
	hd = knocback[2]
	vd = knocback[3]
