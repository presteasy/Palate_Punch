extends StateMachine
class_name SMDummy

@export var framedata: FrameData


func _ready() -> void:
	add_state('STAND')
	add_state('HITSTOP')
	add_state('HITSTUN')
	add_state('AIR')
	add_state('LANDING')
	add_state('FREE_FALL')
	call_deferred("set_state", states.STAND)

func get_transition(delta):
	parent.move_and_slide()
	if Landing() == true:
		framedata._frame()
		return states.LANDING

	if Falling() == true:
		return states.AIR
		



func AIRMOVEMENT():
	if parent.velocity.y < parent.falling_speed:
		parent.velocity.y -= parent.fall_speed


func Falling():
	if state_includes([states.STAND, states.DASH, states.CROUCH, states.WALK]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
			return true

func Landing():
	if state_includes([states.AIR, states.NAIR, states.BAIR, states.FAIR, states.UAIR, states.DAIR, states.FREE_FALL]):
		if (parent.GroundL.is_colliding() or parent.GroundR.is_colliding()) and parent.velocity.y <= 0:
			framedata.frame = 0
			if parent.velocity.y < 0:
				parent.velocity.y = 0
			return true
