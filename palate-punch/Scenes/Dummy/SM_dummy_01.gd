extends StateMachine
class_name SMDummy

@onready var framedata = %FrameData


func _ready() -> void:
	add_state('STAND')
	add_state('HITSTOP')
	add_state('HITSTUN')
	add_state('AIR')
	add_state('LANDING')
	call_deferred("set_state", states.STAND)

func get_transition(delta):
	parent.move_and_slide()

	if Falling() == true:
		return states.AIR
	
	CHASE_PLAYER()
		
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
			return states.AIR
			
		states.HITSTUN:
			
			if framedata.frame == 0:
				if parent.has_meta("pending_kb_x"):
					parent.velocity.x = parent.get_meta("pending_kb_x")
					parent.velocity.y = parent.get_meta("pending_kb_y")
					print("✅ Applied KB in HITSTUN: ", parent.velocity)
					parent.remove_meta("pending_kb_x")
					parent.remove_meta("pending_kb_y")
					if parent.knockback == null or parent.knockback == 0:
						framedata._frame()
						return states.STAND

			print("Dummy is HitStun! Velocity: ", parent.velocity)

			
			if parent.knockback == null or parent.knockback == 0:
				framedata._frame()
				return states.STAND
			
			var decay_rate = 0.98
			parent.velocity.x *= decay_rate
			parent.velocity.y *= decay_rate
			
			if abs(parent.velocity.x) < 0.1:
				parent.velocity.x = 0
			if abs(parent.velocity.y) < 0.1 and abs(parent.velocity.y) > -0.1:
				parent.velocity.y = 0
			
			print(" After decay and gravity: ", parent.velocity)
			
			if parent.knockback >= 18 and parent.get_slide_collision_count() > 0:
				var collision = parent.get_slide_collision(0)
				var normal = collision.get_normal()
				
				var should_bounce = false
				
				if normal.y > 0.7:
					if parent.velocity.y < -5:
						should_bounce = true
						print("SPIKE!!")
					
				elif normal.y < -0.7:
					if parent.velocity.y > 5:
						should_bounce = true
						print("Bounce off Ceiling!")
				
				elif abs(normal.x) > 0.7:
					if abs(parent.velocity.x) > 10:
						should_bounce = true
						print("Wall Bounce!")
						
				if should_bounce:
					parent.velocity = parent.velocity.bounce(normal) * 0.8
					parent.hitstun = round(parent.hitstun * 0.8)
				
				#if bounce_normal.length() > 0:
					#parent.velocity = parent.velocity.bounce(bounce_normal) * 0.8
					#parent.hitstun = round(parent.hitstun * 0.8)
					#print("💥 Bounced off surface! New velocity: ", parent.velocity)
					

			AIRMOVEMENT()	

			if framedata.frame >= parent.hitstun:
				framedata._frame()
				return states.AIR
			elif framedata.frame > 60 * 5:
				framedata.frame()
				return states.AIR


		states.AIR:
			AIRMOVEMENT()
			
			if parent.is_grounded():
				framedata._frame()
				parent.velocity.y = 0
				return states.STAND

		states.LANDING:
			if framedata.frame <= framedata.landing_lag_frames + framedata.lag_frames:
				if parent.velocity.x > 0:
					parent.velocity.x =  parent.velocity.x - parent.traction/2
					parent.velocity.x = clampf(parent.velocity.x, 0 , parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x =  parent.velocity.x + parent.traction/2
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0 )


func enter_state(new_state, old_state):
	match new_state:
		states.STAND:
			parent.play_animation("STAND")
			parent.state_label.text = str("STAND")
		states.HITSTUN:
			parent.play_animation("HITSTUN")
			parent.state_label.text = str("HITSTUN")
		states.HITSTOP:
			parent.state_label.text = str("HITSTOP")
		states.AIR:
			parent.state_label.text = str("AIR")
		states.LANDING:
			parent.state_label.text = str("LANDING")


func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false

func AIRMOVEMENT():
	if parent.velocity.y > -parent.falling_speed:
		parent.velocity.y -= parent.fall_speed


func Falling():
	if state_includes([states.STAND, states.HITSTUN]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
			return true

func CHASE_PLAYER():
	if !state_includes([states.HITSTUN, states.HITSTOP, states.AIR]):
		var direction = (parent.target.global_position - parent.global_position).normalized()
		parent.velocity.x = direction.x * parent.follow_speed

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
