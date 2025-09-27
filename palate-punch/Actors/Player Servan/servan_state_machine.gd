extends StateMachine
class_name StateMachineServan

@onready var id = get_parent().id

@export_group("Nodes")
@export var framedata : FrameData



func _ready() -> void:
	add_state('STAND')
	add_state('CROUCH')
	add_state('HITFREEZE')
	add_state('HITSTUN')
	#GROUNDED MOVEMENT
	add_state('DASH')
	add_state('RUN')
	add_state('TURN')
	add_state('WALK')
	add_state('CRAWL')
	#AERIAL MOVEMENT
	add_state('JUMP_SQUAT')
	add_state('SHORT_HOP')
	add_state('FULL_HOP')
	add_state('AIR')
	add_state('LANDING')
	add_state('FREE_FALL')
	#Ledge Options
	add_state('LEDGE_CATCH')
	add_state('LEDGE_HOLD')
	add_state('LEDGE_CLIMB')
	add_state('LEDGE_JUMP')
	add_state('LEDGE_ROLL')
	add_state('LEDGE_ATK')
	#Defensive Options
	add_state('CROUCH_BLOCK')
	add_state('BLOCK')
	add_state('ROLL_LEFT')
	add_state('ROLL_RIGHT')
	#Grounded ATK
	add_state('L_ATK')
	add_state('L_ATK_2')
	add_state('L_ATK_3')
	add_state('L_UTILT')
	add_state('CROUCH_L_ATK')
	add_state('L_DASH_ATK')
	add_state('H_ATK')
	add_state('H_UTILT')
	add_state('CROUCH_H_ATK')
	add_state('H_DASH_ATK')
	#Aerial ATK
	add_state('AIR_ATK')
	add_state('L_NAIR')
	add_state('L_FAIR')
	add_state('L_BAIR')
	add_state('L_UAIR')
	add_state('L_DAIR')
	add_state('H_NAIR')
	add_state('H_FAIR')
	add_state('H_BAIR')
	add_state('H_UAIR')
	add_state('H_DAIR')
	#Special ATK
	add_state('N_SPECIAL')
	add_state('F_SPECIAL')
	add_state('U_SPECIAL')
	add_state('D_SPECIAL')
	add_state('JUMP_N_SPECIAL')
	add_state('JUMP_F_SPECIAL')
	add_state('JUMP_U_SPECIAL')
	add_state('JUMP_D_SPECIAL')
	call_deferred("set_state", states.STAND)
	
	
func get_transition(delta):
	#print(parent.GroundL.is_colliding())
	if InputHandler.current_input_mode == InputHandler.InputMode.UI:
		return
	else:
		if parent.can_run:
			parent.move_and_slide()
		else:
			parent.velocity = Vector3.ZERO
		
		if Landing() == true:
			framedata._frame()
			return states.LANDING
	
		if Falling() == true:
			return states.AIR
			
		match state:
			states.STAND:
				parent.reset_jumps()
				
				var move_x = Input.get_action_strength("right_%s" % id) - Input.get_action_strength("left_%s" % id)
				
				var move_vec = Vector3(move_x, 0, 0)
				var input_magnitude = move_vec.length()
				
				move_vec = move_vec.normalized()
				
				if input_magnitude > 0.1 and input_magnitude <= 0.8:
					parent.velocity.x = move_vec.x * parent.walk_speed
					framedata._frame()
					return states.WALK
				elif input_magnitude > 0.8:
					parent.velocity.x = move_vec.x * parent.run_speed * parent.movement_damper
					framedata._frame()
					return states.DASH
				
				if move_vec.x > 0 and parent.velocity.x < 0 or move_vec.x < 0 and parent.velocity.x > 0:
					return states.TURN
								
				if parent.velocity.x > 0:
					parent.velocity.x -= parent.traction
					parent.velocity.x = max(0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.traction
					parent.velocity.x = min(0, parent.velocity.x)
				
				#if Input.is_action_just_pressed("special_%s" % id):
					#parent._frame()
					#return states.N_SPECIAL
				#if Input.is_action_just_pressed("h_attack_%s" % id):
					#parent._frame()
					#return states.H_ATK
					
				if Input.is_action_pressed("down_%s" % id):
					framedata._frame()
					return states.CROUCH
				
				if Input.is_action_just_pressed("block_%s" % id):
					framedata._frame()
					return states.BLOCK
					
				if Input.is_action_just_pressed("jump_%s" % id):
					framedata._frame()
					return states.JUMP_SQUAT
				
				
						
			states.CROUCH:
				parent.use_crouch_hurtbox()
				parent.can_run = false
				#
				#if Input.is_action_pressed("down_%s" % id) and Input.is_action_pressed("left_%s" % id) or Input.is_action_pressed("right_%s" % id):
					#framedata._frame()
					#return states.CRAWL
				#
				#if Input.is_action_just_pressed("l_attack_%s" % id):
					#framedata._frame()
					#return states.CROUCH_L_ATK
				#elif Input.is_action_just_pressed("special_%s" % id):
					#framedata._frame()
					#return states.D_SPECIAL
				#elif Input.is_action_just_pressed("h_attack_%s" % id):
					#framedata._frame()
					#return states.CROUCH_H_ATK
					#
				if not Input.is_action_pressed("down_%s" % id):
					parent.use_stand_hurtbox()
					framedata._frame()
					parent.can_run = true
					return states.STAND
					#
				#if Input.is_action_pressed("block_%s" % id):
					#framedata._frame()
					#parent.can_run = false
					#return states.CROUCH_BLOCK
			
			states.HITFREEZE:
				#print("Lily is Hitfreeze!")
				#if parent.freezeframes == 0:
					#framedata._frame()
					#parent.velocity.x = kbx
					#parent.velocity.y = kby
					#parent.hdecay = hd
					#parent.vdecay = vd
					#return states.HITSTUN
				#parent.position = pos
				return
			states.HITSTUN:
				print("Lily is HitSTUN!")
				if framedata.frame >= parent.hitstun:
					framedata._frame()
					return states.STAND
				if parent.knockback == null:
					framedata._frame()
					return states.STAND

				if parent.knockback >= 3:
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
						
				if framedata.frame == parent.hitstun:
					if parent.knockback >= 24:
						framedata._frame()
						return states.AIR
					else:
						framedata._frame()
						return states.AIR
				elif framedata.frame > 60 * 5:
					return states.AIR
				
	#====== DEFENSIVE OPTIONS ======
			states.BLOCK:
				emit_signal("entered_invulnerable_state")
				parent.switch_to_crouch_collision(false)
				parent.can_run = false
				
				if not Input.is_action_pressed("block_%s" % id):
					emit_signal("exited_invulnerable_state")
					framedata._frame()
					parent.can_run = true
					return states.STAND
					
				if Input.is_action_pressed("down_%s" % id):
					framedata._frame()
					return states.CROUCH_BLOCK
				
				if Input.is_action_pressed("left_%s" % id):
					framedata._frame()
					return states.ROLL_LEFT
				if Input.is_action_pressed("right_%s" % id):
					framedata._frame()
					return states.ROLL_RIGHT
				
			states.ROLL_LEFT:
				parent.can_run = true
				parent.turn(true)
				if framedata.frame == 1:
					parent.velocity.x = 0
				if framedata.frame == 4:
					parent.velocity.x = -parent.roll_distance
					emit_signal("entered_invulnerable_state")
				if framedata.frame == 20:
					emit_signal("exited_invulnerable_state")
				if framedata.frame > 19:
					parent.velocity.x = parent.velocity.x - parent.traction * 5
					parent.velocity.x = clampi(parent.velocity.x, 0, parent.velocity.x)
					if parent.velocity.x == 0:
						framedata.cooldown = 20
						framedata.lag_frames = 10
						framedata._frame()
						return states.LANDING
				
			
			states.ROLL_RIGHT:
				parent.can_run = true
				parent.turn(false)
				if framedata.frame == 1:
					parent.velocity.x = 0
				if framedata.frame == 4:
					parent.velocity.x = parent.roll_distance
					emit_signal("entered_invulnerable_state")
				if framedata.frame == 20:
					emit_signal("exited_invulnerable_state")
				if framedata.frame > 19:
					parent.velocity.x = parent.velocity.x - parent.traction * 5
					parent.velocity.x = clampi(parent.velocity.x, 0, parent.velocity.x)
					if parent.velocity.x == 0:
						framedata.cooldown = 20
						framedata.lag_frames = 10
						framedata._frame()
						return states.LANDING
					
			states.CROUCH_BLOCK:
				return
				#parent.switch_to_crouch_collision(true)
				#emit_signal("entered_invulnerable_state")
				#
				#if not Input.is_action_pressed("block_%s" % id):
					#emit_signal("exited_invulnerable_state")
					#framedata._frame()
					#return states.CROUCH
				#
				#if not Input.is_action_pressed("down_%s" % id):
					#framedata._frame()
					#return states.BLOCK
		#
				#if Input.is_action_pressed("special_%s" % id):
					#framedata._frame()
					#parent.can_run = false
					#return states.SPECIAL

	#====== MOVEMENT ======
			states.DASH:
				if Input.is_action_just_pressed("down_%s" % id):
					framedata._frame()
					return states.CROUCH
					
				if Input.is_action_just_pressed("jump_%s" % id):
					framedata._frame()
					
					if abs(parent.velocity.x) > parent.dash_jump_limit:
						parent.velocity.x = sign(parent.velocity.x) * parent.dash_jump_limit
						
					return states.JUMP_SQUAT
					
				if parent.GroundL.is_colliding() and parent.GroundR.is_colliding():
					if parent.can_run:
						var dash_x = Input.get_action_strength("right_%s" % id) - Input.get_action_strength("left_%s" % id)
					
					
						var dash_vec = Vector3(dash_x, 0, 0)
					
						var input_magnitude = dash_vec.length()
						var speed_multiplier = 1.0
					
						dash_vec = dash_vec.normalized()
					
						if input_magnitude <= 0.8:
							speed_multiplier = lerpf(0, 1, input_magnitude / 0.8)
						else:
							speed_multiplier = 1.0
						
						parent.velocity.x = dash_vec.x * parent.dash_speed * speed_multiplier
						
						if dash_vec == Vector3.ZERO:
							if framedata.frame >= parent.dash_duration-1:
								for state in states:
									if state != "JUMP_SQUAT":
										framedata._frame()
										return states.STAND
						else:
							if abs(dash_vec.x) > 0:
								if framedata.frame <= parent.dash_duration-1:
									parent.turn(dash_vec.x < 0)
									return states.DASH
								else:
									parent.turn(dash_vec.x < 0)
									framedata._frame()
									return states.RUN
									#if not parent.can_run:
										#framedata._frame()
										#return states.STAND
							#if abs(dash_vec.z) > 0:
								#if framedata.frame <= parent.dash_duration-1:
									#parent.turn(dash_vec.z < 0)
									#return states.DASH
								#else:
									#parent.turn(dash_vec.z < 0)
									#framedata._frame()
									#return states.RUN
									#if not parent.can_run:
										#framedata._frame()
										#return states.STAND
				else:
					framedata._frame()
					return states.AIR
					
			states.RUN:
				if Input.is_action_just_pressed("jump_%s" % id):
					framedata._frame()
					return states.JUMP_SQUAT
					
				var run_x = 0
				if parent.can_run and Input.get_action_strength("left_%s" % id) and parent.GroundL.is_colliding() and parent.GroundR.is_colliding():
					run_x = -Input.get_action_strength("left_%s" % id)
					if parent.velocity.x <= 0:
						parent.turn(true)
					else:
						framedata._frame()
						return states.TURN
				elif parent.can_run and Input.get_action_strength("right_%s" % id) and parent.GroundL.is_colliding() and parent.GroundR.is_colliding():
					run_x = Input.get_action_strength("right_%s" % id)
					if parent.velocity.x >= 0:
						parent.turn(false)
					else:
						framedata._frame()
						return states.TURN
				else:
					framedata._frame()
					return states.AIR
						
				var run_vec = Vector3(run_x, 0, 0).normalized()
				var input_strength = run_vec.length()
				
				if input_strength >= 0.8:
					parent.velocity.x = run_vec.x * parent.run_speed
				else:
					parent.velocity.x = run_vec.x * parent.walk_speed
				
				if run_vec == Vector3.ZERO:
					framedata._frame()
					return states.STAND
				
				
				
				#if Input.is_action_just_pressed("l_attack_%s" % id):
					#framedata._frame()
					#return states.L_ATK
				#if Input.is_action_just_pressed("special_%s" % id):
					#framedata._frame()
					#return states.F_SPECIAL
				#if Input.is_action_just_pressed("h_attack_%s" % id):
					#framedata._frame()
					#return states.H_ATK				

			states.TURN:
				if Input.is_action_just_pressed("jump_%s" % id):
					framedata._frame()
					return states.JUMP_SQUAT 
				if parent.velocity.x > 0:
					parent.turn(true)
					parent.velocity.x += -parent.traction*2
					parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.turn(false)
					parent.velocity.x += parent.traction*2
					parent.velocity.x = clampf(parent.velocity.x,parent.velocity.x,0)
				else:
					if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
						framedata._frame()
						return states.STAND
					else:
						framedata._frame()
						return states.RUN
			
			states.WALK:
				if Input.is_action_just_pressed("jump_%s" % id):
					framedata._frame()
					return states.JUMP_SQUAT 
					
				var walk_x = Input.get_action_strength("right_%s" % id) - Input.get_action_strength("left_%s" % id)
				if walk_x < 0:
					if parent.velocity.x <= 0:
						parent.turn(true)
					else:
						framedata._frame()
						return states.TURN
				elif walk_x > 0:
					if parent.velocity.x >= 0:
						parent.turn(false)
					else:
						framedata._frame()
						return states.TURN

				#var walk_z = Input.get_action_strength("down_%s" % id) - Input.get_action_strength("up_%s" % id)
				
				var walk_vec = Vector3(walk_x, 0, 0)
				var input_magnitude = walk_vec.length()
				
				if input_magnitude >= 0.8:
					framedata._frame()
					return states.DASH
				
				walk_vec = walk_vec.normalized()
				
				var speed_multiplier = 1.0
				
				if input_magnitude <= 0.8:
					speed_multiplier = lerpf(0, 1, input_magnitude / 0.8)
				else:
					speed_multiplier = 1.0

				parent.velocity.x = walk_vec.x * parent.walk_speed * speed_multiplier
				
				if walk_vec == Vector3.ZERO:
					framedata._frame()
					return states.STAND
					
			states.CRAWL:
				if Input.is_action_just_pressed("jump_%s" % id):
					framedata._frame()
					return states.JUMP_SQUAT 
					
				var crawl_x = Input.get_action_strength("right_%s" % id) - Input.get_action_strength("left_%s" % id)
				if crawl_x < 0:
					if parent.velocity.x <= 0:
						parent.turn(true)
					else:
						framedata._frame()
						return states.TURN
				elif crawl_x > 0:
					if parent.velocity.x >= 0:
						parent.turn(false)
					else:
						framedata._frame()
						return states.TURN
						
				var crawl_vec = Vector3(crawl_x, 0, 0)
				crawl_vec = crawl_vec.normalized()

				parent.velocity.x = crawl_vec.x * parent.crawl_speed
				
				if crawl_vec == Vector3.ZERO:
					framedata._frame()
					return states.STAND
				
	#====== AERIAL MOVEMENT ======
			states.AIR:
				AIRMOVEMENT()
					#
				#Wave Bounce
				#if Input.is_action_just_pressed("left_%s" % id) or Input.is_action_just_pressed("right_%s" % id):
					#parent.last_direction_input_time = Time.get_ticks_msec() / 1000.0
					#move.perform_wave_bounce()
					#print("wavebounce performed")
				#
				if Input.is_action_just_pressed("jump_%s" % id) and parent.air_jump > 0:
					parent.fastfall = false
					parent.velocity.x = 0
					parent.velocity.y = parent.double_jump_force
					parent.air_jump -= 1
					if Input.is_action_pressed("left_%s" % id):
						parent.velocity.x = -parent.max_air_speed
					elif Input.is_action_pressed("right_%s" % id):
						parent.velocity.x = parent.max_air_speed
				#
				##Air Attacks
				#if Input.is_action_just_pressed("l_attack_%s" % id):
					#framedata._frame()
					#return states.L_NAIR
				#if Input.is_action_just_pressed("h_attack_%s" % id):
					#framedata._frame()
					#return states.H_NAIR
				
			states.LANDING: 
				if framedata.frame <= framedata.landing_frames + framedata.lag_frames:
					if parent.velocity.x > 0:
						parent.velocity.x =  parent.velocity.x - parent.traction/2
						parent.velocity.x = clampf(parent.velocity.x, 0 , parent.velocity.x)
					elif parent.velocity.x < 0:
						parent.velocity.x =  parent.velocity.x + parent.traction/2
						parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0 )
				else:
					if Input.is_action_pressed("down_%s" % id):
						framedata.lag_frames = 0
						framedata._frame()
						parent.reset_jumps()
						return states.CROUCH
					elif Input.is_action_pressed("block_%s" % id):
						framedata.lag_frames = 10
						framedata._frame()
						parent.reset_jumps()
						return states.BLOCK
					else:
						framedata._frame()
						framedata.lag_frames = 0
						parent.reset_jumps()
						return states.STAND
					framedata.lag_frames = 0
				
			states.JUMP_SQUAT:
				if framedata.frame == parent.jump_squat:
					if not Input.is_action_pressed("jump_%s" % id):
						parent.velocity.x = lerpf(parent.velocity.x,0,0.06)
						#parent.velocity.z = lerpf(parent.velocity.z,0,0.06)
						framedata._frame()
						return states.SHORT_HOP
					else:
						parent.velocity.x = lerpf(parent.velocity.x,0,0.06)
						#parent.velocity.z = lerpf(parent.velocity.z,0,0.06)
						framedata._frame()
						return states.FULL_HOP

			states.SHORT_HOP:
				parent.velocity.y = parent.jump_force
				print("shorthop!")
				framedata._frame()
				return states.AIR
				
				#if Input.is_action_just_pressed("down_%s" % id) and !(parent.GroundR.is_colliding() and parent.GroundL.is_colliding()):
					#framedata._frame()
					#parent.velocity.y = 0
					#return states.STAND
				
			states.FULL_HOP:
				parent.velocity.y = parent.max_jump_force
				print("fullhop!")
				framedata._frame()
				return states.AIR

			states.FREE_FALL:
				if parent.velocity.y < parent.max_fall_speed:
					parent.velocity.y -= parent.fall_speed

				if Input.is_action_just_pressed("down_%s" % id) and parent.velocity.y > 0 and parent.fastfall == false:
					parent.velocity.y = -parent.max_fall_speed
					parent.fastfall = true

				if abs(parent.velocity.x) >= abs(parent.max_air_speed):
					if parent.velocity.x > 0:
						if Input.is_action_pressed("left_%s" % id):
							parent.velocity.x += -parent.air_accel
						elif Input.is_action_pressed("right_%s" % id):
								parent.velocity.x = parent.velocity.x
					if parent.velocity.x < 0:
						if Input.is_action_pressed("left_%s" % id):
							parent.velocity.x = parent.velocity.x
						elif Input.is_action_pressed("right_%s" % id):
							parent.velocity.x += parent.air_accel
						
				elif abs(parent.velocity.x) < abs(parent.max_air_speed):
					if Input.is_action_pressed("left_%s" % id):
						parent.velocity.x += -parent.air_accel
					if Input.is_action_pressed("right_%s" % id):
						parent.velocity.x += parent.air_accel
				if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
					#print('Air Deaccel')
					if parent.velocity.x < 0:
						parent.velocity.x += (parent.air_accel/ 2)
					elif parent.velocity.x > 0:
						parent.velocity.x += (-parent.air_accel / 2)

	#====== LEDGE OPTIONS ======
			states.LEDGE_CATCH:
				if Input.is_action_just_pressed("down_%s" % id):
					print("ledge fall")
					parent.fastfall = true
					parent.regrab = 30
					parent.reset_ledge()
					self.parent.position.y += -0.5
					parent.catch = false
					framedata._frame()
					return states.AIR
				
					
				#Facing Right
				if parent.LedgeGrabF.get_target_position().x > 0:
					if Input.is_action_just_pressed("left_%s" % id):
						parent.velocity.x = (parent.air_accel / 2)
						parent.regrab = 30
						parent.reset_ledge()
						self.parent.position.y += -0.5
						parent.catch = false
						framedata._frame()
						return states.AIR
				if Input.is_action_just_pressed("right_%s" % id):
					framedata._frame()
					return states.LEDGE_CLIMB
				if Input.is_action_just_pressed("block_%s" % id):
					framedata._frame()
					return states.LEDGE_ROLL
				if Input.is_action_just_pressed("jump_%s" % id):
					framedata._frame()
					return states.LEDGE_JUMP
					
				#Facing Left
				if parent.LedgeGrabF.get_target_position().x > 0:
					if Input.is_action_just_pressed("right_%s" % id):
						parent.velocity.x = (parent.air_accel / 2)
						parent.regrab = 30
						parent.reset_ledge()
						self.parent.position.y += -0.5
						parent.catch = false
						framedata._frame()
						return states.AIR
				if Input.is_action_just_pressed("left_%s" % id):
					framedata._frame()
					return states.LEDGE_CLIMB
				if Input.is_action_just_pressed("block_%s" % id):
					framedata._frame()
					return states.LEDGE_ROLL
				if Input.is_action_just_pressed("jump_%s" % id):
					framedata._frame()
					return states.LEDGE_JUMP


				if Input.is_action_just_pressed("l_attack_%s" % id) or Input.is_action_just_pressed("h_attack_%s" % id) or Input.is_action_just_pressed("special_%s" % id):
					framedata._frame()
					return states.LEDGE_ATK

				if framedata.frame > 20:
					framedata.lag_frames = 0
					parent.reset_jumps()
					framedata._frame()
					return states.LEDGE_HOLD

			states.LEDGE_HOLD:
				if framedata.frame >= 390: #3.5 sec
					self.parent.position.y += -0.5
					framedata._frame()
					return states.AIR
				if Input.is_action_just_pressed("down_%s" % id):
					print("ledge fall")
					parent.fastfall = true
					parent.regrab = 30
					parent.reset_ledge()
					self.parent.position.y += -0.5
					parent.catch = false
					framedata._frame()
					return states.AIR
					
				#Facing Right
				elif parent.LedgeGrabF.get_target_position().x > 0:
					if Input.is_action_just_pressed("left_%s" % id):
						parent.velocity.x = (parent.air_accel / 2)
						parent.regrab = 30
						parent.reset_ledge()
						self.parent.position.y += -0.5
						parent.catch = false
						framedata._frame()
						return states.AIR
				elif Input.is_action_just_pressed("right_%s" % id):
					framedata._frame()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("block_%s" % id):
					framedata._frame()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s" % id):
					framedata._frame()
					return states.LEDGE_JUMP
					
				#Facing Left
				elif parent.LedgeGrabF.get_target_position().x > 0:
					if Input.is_action_just_pressed("right_%s" % id):
						parent.velocity.x = (parent.air_accel / 2)
						parent.regrab = 30
						parent.reset_ledge()
						self.parent.position.y += -0.5
						parent.catch = false
						framedata._frame()
						return states.AIR
				elif Input.is_action_just_pressed("left_%s" % id):
					framedata._frame()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("block_%s" % id):
					framedata._frame()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s" % id):
					framedata._frame()
					return states.LEDGE_JUMP
		
			states.LEDGE_CLIMB:
				var rise_speed = 0.1
				var max_height_relative = 0.1
				var forward_speed = 0.3
				var starting_height = parent.global_transform.origin.y
				var target_height = starting_height + max_height_relative
				var new_position = parent.global_transform.origin
				
				if framedata.frame >= 0 and framedata.frame < 15:
					new_position.y += rise_speed
					if new_position.y >= target_height:
						framedata.frame = 15
				elif framedata.frame >= 15 and framedata.frame < 20:
					new_position.x += parent.current_direction * forward_speed
				parent.global_transform.origin = new_position
				if framedata.frame >= 20:
					framedata._frame()
					parent.velocity = Vector3.ZERO
					return states.STAND
					
				if parent.global_transform.origin.y < starting_height:
					var corrected_position = parent.global_transform.origin
					corrected_position.y = starting_height
					parent.global_transform.origin = corrected_position
			
			states.LEDGE_JUMP:
				parent.velocity.y = 15
				framedata._frame()
				return states.AIR
			
			states.LEDGE_ROLL:
				var rise_speed = 0.1
				var max_height_relative = 0.1
				var forward_speed = 0.3
				var starting_height = parent.global_transform.origin.y
				var target_height = starting_height + max_height_relative
				var new_position = parent.global_transform.origin
				
				if framedata.frame >= 0 and framedata.frame < 20:
					new_position.y += rise_speed
					emit_signal("entered_invulnerable_state")
					if new_position.y >= target_height:
						framedata.frame = 20
				elif framedata.frame >= 20 and framedata.frame < 35:
					new_position.x += parent.current_direction * forward_speed
				parent.global_transform.origin = new_position
				if framedata.frame >= 35:
					framedata._frame()
					parent.velocity = Vector3.ZERO
					emit_signal("exited_invulnerable_state")
					return states.STAND
					
				if parent.global_transform.origin.y < starting_height:
					var corrected_position = parent.global_transform.origin
					corrected_position.y = starting_height
					parent.global_transform.origin = corrected_position

			
			states.LEDGE_ATK:
				return
				
	#====== GROUNDED ATKS ======
			states.L_ATK:
				return
				#if framedata.frame == 0:
					#atk.L_ATK()
					#parent.combo_start_time = Time.get_ticks_msec()
					#parent.last_punch_time = Time.get_ticks_msec()
					#parent.movement_damper = 0.5
					#pass
					#
				#move.punch_traction()
				#
				#if Time.get_ticks_msec() - parent.last_punch_time > parent.combo_reset_time * 1000:
					#reset_combo()
	#
				#if atk.L_ATK() == true:
					#if is_within_combo_window() and Input.is_action_just_pressed("l_attack_%s" % id):
						#framedata._frame()
						#return states.L_ATK_2
					#else:
						#framedata._frame()
						#parent.movement_damper = 1.0
						#parent.can_run = true
						#return states.STAND
						
			states.L_ATK_2:
				return
				#if Time.get_ticks_msec() - parent.last_punch_time > parent.combo_reset_time * 1000:
					#reset_combo()
				#if framedata.frame == 0:
					#atk.L_ATK_2()
					#parent.last_punch_time = Time.get_ticks_msec()
					#pass
				#move.punch_traction()
				#if atk.L_ATK_2() == true:
					#if is_within_combo_window() and Input.is_action_just_pressed("l_attack_%s" % id):
						#framedata._frame()
						#return states.L_ATK_3
					#else:
						#framedata._frame()
						#return states.STAND
			
			states.L_ATK_3:
				return
				#if Time.get_ticks_msec() - parent.last_punch_time > parent.combo_reset_time * 1000:
					#reset_combo()
				#if framedata.frame == 0:
					#atk.L_ATK_3()
					#parent.last_punch_time = Time.get_ticks_msec()
					#pass
	#
				#move.punch_traction()
				#if atk.L_ATK_3() == true:
						#framedata._frame()
						#return states.STAND
							
			states.L_UTILT:
				return
				
			states.CROUCH_L_ATK:
				return
				#if framedata.frame == 0:
					#atk.CROUCH_L_ATK()
					#pass
				#if framedata.frame >= 1:
					#if parent.velocity.x > 0:
						#parent.velocity.x += -parent.traction*3
						#parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
					#elif parent.velocity.x < 0:
						#parent.velocity.x += parent.traction*3
						#parent.velocity.x = clampf(parent.velocity.x,parent.velocity.x,0)
				#if atk.CROUCH_L_ATK() == true:
					#if Input.is_action_pressed("down_%s" % id) && framedata.frame >= 10:
						#framedata._frame()
						#return states.CROUCH
					#else:
						#framedata._frame()
						#parent.can_run = true
						#return states.STAND
				
			states.L_DASH_ATK:
				return
				
			states.H_ATK:
				return
				#if framedata.frame == 0:
					#atk.H_ATK()
					#pass
					#
				#move.punch_traction()
				#
				#if atk.H_ATK() == true:
					#if framedata.frame >= 40:
						#framedata._frame()
						#parent.can_run = true
						#return states.STAND
						
			states.H_UTILT:
				return

			states.CROUCH_H_ATK:
				return
				#if framedata.frame == 0:
					#atk.CROUCH_H_ATK()
					#pass
				#if framedata.frame >= 1:
					#if parent.velocity.x > 0:
						#parent.velocity.x += -parent.traction*3
						#parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
					#elif parent.velocity.x < 0:
						#parent.velocity.x += parent.traction*3
						#parent.velocity.x = clampf(parent.velocity.x,parent.velocity.x,0)
				#if atk.CROUCH_H_ATK() == true:
					#if Input.is_action_pressed("down_%s" % id) && framedata.frame >= 15:
						#framedata._frame()
						#return states.CROUCH
					#else:
						#framedata._frame()
						#parent.can_run = true
						#return states.STAND
			
			states.H_DASH_ATK:
				return
				
	# ====== AERIAL ATKS ======
			states.AIR_ATK:
				return

			states.L_NAIR:
				return
				#AIRMOVEMENT()
				#if framedata.frame == 0:
					#atk.JUMP_L_ATK()
					#pass
				#if atk.JUMP_L_ATK() == true:
					#if framedata.frame >= 20:
						#framedata._frame()
						#return states.AIR
				#if parent.is_on_floor():
					#parent.reset_jumps()
					#parent.velocity.y = 0
					#return states.LANDING
					
			states.L_FAIR:
				return
				
			states.L_BAIR:
				return

			states.L_UAIR:
				return
				
			states.L_DAIR:
				return
				
			states.H_NAIR:
				return
				#AIRMOVEMENT()
				#if framedata.frame == 0:
					#atk.JUMP_H_ATK()
					#pass
				#if atk.JUMP_H_ATK() == true:
					#if framedata.frame >= 40:
						#framedata._frame()
						#return states.AIR
				#if parent.is_on_floor():
					#if framedata.frame < 40:
						#parent.reset_jumps()
						#parent.velocity.y = 0
						#parent.velocity.x = 0
					#elif framedata.frame >= 40:
						#framedata._frame()
						#return states.STAND

			states.H_FAIR:
				return

			states.H_BAIR:
				return
				
			states.H_UAIR:
				return

			states.H_DAIR:
				return
				
	#====== SPECIAL ATKS ======
			states.N_SPECIAL:
				#if framedata.frame == 0:
					#atk.L_SPECIAL()
					#parent.can_run = false
					#print("FIREBALL!")
					#pass
				#if atk.L_SPECIAL() == true:
					#if framedata.frame >= 40:
						#framedata._frame()
						#parent.can_run = true
						#return states.STAND
				return
			states.F_SPECIAL:
				return
			
			states.U_SPECIAL:
				return


#====== ANIMATIONS ======
func enter_state(new_state, old_state):
	match new_state:
		states.STAND:
			parent.play_animation("STAND")
			parent.state_label.text = str("STAND")
		states.CROUCH:
			parent.play_animation("CROUCH")
			parent.state_label.text = str("CROUCH")
		states.HITSTUN:
			pass
#====== MOVEMENT ======
		states.DASH:
			parent.play_animation("DASH")
			parent.state_label.text = str("DASH")
		states.TURN:
			pass
		states.RUN:
			parent.play_animation("RUN")
			parent.state_label.text = str("RUN")
		states.WALK:
			parent.play_animation("WALK")
			parent.state_label.text = str("WALK")
		states.CRAWL:
			pass
#====== AIREAL MOVEMENT ======
		states.JUMP_SQUAT:
			pass
		states.SHORT_HOP:
			pass
		states.FULL_HOP:
			pass
		states.AIR:
			parent.play_animation("AIR")
			parent.state_label.text = str("AIR")
		states.LANDING:
			pass
		states.FREE_FALL:
			pass
#====== LEDGE OPTIONS ======
		states.LEDGE_CATCH:
			pass
		states.LEDGE_HOLD:
			pass
		states.LEDGE_CLIMB:
			pass
		states.LEDGE_JUMP:
			pass
		states.LEDGE_ROLL:
			pass
#====== DEFENSIVE OPTIONS ======
		states.BLOCK:
			pass
		states.ROLL_LEFT:
			pass
		states.ROLL_RIGHT:
			pass
		states.CROUCH_BLOCK:
			pass
#====== GROUNDED ATKS ======
		states.L_ATK:
			pass
		states.L_ATK_2:
			pass
		states.L_ATK_3:
			pass
		states.CROUCH_L_ATK:
			pass
		states.L_UTILT:
			pass
		states.H_ATK:
			pass
		states.CROUCH_H_ATK:
			pass
		states.H_UTILT:
			pass
#====== AIREAL ATKS ======
		states.L_NAIR:
			pass
		states.L_FAIR:
			pass
		states.L_BAIR:
			pass
		states.L_UAIR:
			pass
		states.L_DAIR:
			pass
		states.H_NAIR:
			pass
		states.H_FAIR:
			pass
		states.H_BAIR:
			pass
		states.H_UAIR:
			pass
		states.H_DAIR:
			pass
#====== SPECIAL ATKS ======
		states.N_SPECIAL:
			pass
		states.F_SPECIAL:
			pass
		states.U_SPECIAL:
			pass
		states.D_SPECIAL:
			pass
		states.JUMP_N_SPECIAL:
			pass
		states.JUMP_F_SPECIAL:
			pass
		states.JUMP_U_SPECIAL:
			pass
		states.JUMP_D_SPECIAL:
			pass



func exit_state(old_state, new_state):
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
	
func AIRMOVEMENT():
	if parent.velocity.y < parent.falling_speed:
		parent.velocity.y -= parent.fall_speed
	if Input.is_action_just_pressed("down_%s" % id) and parent.velocity.y > -1 and parent.fastfall == false:
		parent.velocity.y = -parent.max_fall_speed
		parent.fastfall = true
		print(parent.fastfall)
	if parent.fastfall == true:
		parent.set_collision_mask_value(7,false)
		parent.velocity.y = -parent.max_fall_speed
		
	if  abs(parent.velocity.x) >=  abs(parent.max_air_speed):
		if parent.velocity.x > 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x += -parent.air_accel
			elif Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.velocity.x
		if parent.velocity.x < 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x = parent.velocity.x
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x += parent.air_accel
					
				
	elif abs(parent.velocity.x) < abs(parent.max_air_speed):
		if Input.is_action_pressed("left_%s" % id):
			parent.velocity.x += -parent.air_accel#*2
		if Input.is_action_pressed("right_%s" % id):
			parent.velocity.x += parent.air_accel#*2
		
	if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
		if parent.velocity.x < 0:
			parent.velocity.x += parent.air_accel/ 5
		elif parent.velocity.x > 0:
			parent.velocity.x += -parent.air_accel / 5

func Falling():
	if state_includes([states.STAND, states.DASH, states.CROUCH, states.WALK]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
			return true

func Landing():
	if state_includes([states.AIR,states.L_NAIR,states.H_NAIR,states.FREE_FALL]):
		if (parent.GroundL.is_colliding() or parent.GroundR.is_colliding()) and parent.velocity.y <= 0:
			framedata.frame = 0
			if parent.velocity.y < 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true
