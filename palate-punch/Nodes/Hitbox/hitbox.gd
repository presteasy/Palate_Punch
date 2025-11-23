extends Area3D
class_name Hitbox

@onready var parent = get_parent()
@onready var hitbox = get_node("Hitbox_Shape")
@onready var parentState = get_parent().selfState

@export var radius = 300
@export var height = 400
@export var depth = 300
@export var damage = 50
@export var angle = 90
@export var base_kb = 100
@export var kb_scaling = 0.5
@export var duration = 1500
@export var hitlag_modifier = 1
@export var type = 'normal'
@export var angle_flipper = 0
@export var freezeframes_duration: int = 10
@export var owner_type = 'player'



var knockbackVal
var framez = 0.0
var player_list = []

#signals
signal damage_inflicted(amount)
signal hitbox_collided(hitbox, body, knockbackVal, damage)

func set_parameters(ot,r,h,de,d,a,b_kb,kb_s,dur,t,p,af,hit,parent=get_parent()):
		self.position = Vector3(0,0,0)
		player_list.append(parent)
		player_list.append(self)
		owner_type = ot
		radius = r
		height = h
		depth = de
		damage = d
		angle = a
		base_kb = b_kb
		kb_scaling = kb_s
		duration = dur
		type = t
		self.position = p
		hitlag_modifier = hit
		angle_flipper = af
		update_dimensions(r, h)
		connect("body_entered",Callable(self,"Hitbox_Collide"))
		set_physics_process(true)

#func Hitbox_Collide(body):
	#print("🔴 HIT DETECTED! Body: ", body.name, " | Hitlag modifier: ", hitlag_modifier)
	##body = body.get_parent()
	#var prop_list = body.get_property_list()
	#var found: bool = false
	#for prop in prop_list:
		#if prop.name == "character_type":
			#found = true
			#break
	#if found:
		#if body.character_type != owner_type:
			#if !(body.get_parent() in player_list):
			##if body.name == "Parrybox":
				##set_collision_mask_value(1,false)
				##parry = true
				##if get_parent().is_on_floor() == false:
					##var selfstate = get_parent().get_node("StateMachine")
					##selfstate.state = selfstate.states.STUNNED
			##else:
				##body = body.get_parent()
				#player_list.append(body)
				#if body.has_node("Health"):
					#var health_node = body.get_node("Health")
					#health_node.take_damage(damage)
				##var charstate
				##charstate = body.get_node("StateMachine")
				#weight = body.weight
				#body.percentage += damage
				#knockbackVal = knockback(body.percentage,damage,weight,kb_scaling,base_kb,1)
				#s_angle(body)
				##charstate.state = charstate.states.HITSTOP
				##charstate.hitfreeze(hitlag(damage,hitlag_modifier),angle_flipperv2(Vector3(body.velocity.x,body.velocity.y,body.velocity.z),body.global_position))
				#
				#
				#body.knockback = knockbackVal
				#body.hitstun = getHitstun(knockbackVal/0.3)
				#
				#var bodyframe
				#bodyframe = body.get_node("FrameData")
				#bodyframe._frame()
				#
				#get_parent().hit_pause_dur = duration - framez
				#get_parent().temp_pos = get_parent().position
				#get_parent().temp_vel = get_parent().velocity
				#get_parent().connected = true
				#
				#Global.game_controller.freeze_hitstop(hitlag(damage,hitlag_modifier))
				#SignalManager.emit_signal("hit_landed")
	#else:
		#return
	#print("Collided with: ", body, " Class: ", body.get_class())

func Hitbox_Collide(body):
	var prop_list = body.get_property_list()
	var found: bool = false
	for prop in prop_list:
		if prop.name == "character_type":
			found = true
			break
	if not found:
		return
		
	if body.character_type == owner_type:
		return
	if body in player_list:
		return
				
	player_list.append(body)
	print("Hit registered! Applyingdamage and knockback")
	print("   Initial percentage: ", body.percentage)
	print("   Damage to apply: ", damage)
	
	if body.has_node("Health"):
		var health_node = body.get_node("Health")
		health_node.take_damage(damage)

	weight = body.weight
	print("   Weight: ", weight)
	body.percentage += damage
	print("Percentage: ", body.percentage)
	
	
	var charstate = body.get_node("StateMachine")
	knockbackVal = knockback(body.percentage,damage,weight,kb_scaling,base_kb,1)
	s_angle(body)
	print("Knockback: ", knockbackVal)
	
	var kb_data = angle_flipperv2(Vector3(body.velocity.x, body.velocity.y, body.velocity.z), body.global_position)
	print("   KB Data from angle_flipper ", angle_flipper, ": ", kb_data)
	
	body.hdecay = kb_data[3]
	body.vdecay = kb_data[4]
	body.knockback = knockbackVal
	body.hitstun = getHitstun(knockbackVal/0.3)
	
	body.set_meta("pending_kb_x", kb_data[0])
	body.set_meta("pending_kb_y", kb_data[1])
	
	var bodyframe = body.get_node("FrameData")
	bodyframe._frame()
	charstate.state = charstate.states.HITSTUN
	
	get_parent().connected = true
	
	SignalManager.emit_signal("hit_landed")
	print("Collided with: ", body, " Class: ", body.get_class())
	
	print(" Starting Freeze...")
	Global.game_controller.freeze_hitstop(hitlag(damage,hitlag_modifier))
	print(" Freeze Ended!")
	
	#if body.has_meta("pending_kb_x"):
		#body.velocity.x = body.get_meta("pending_kb_x")
		#body.velocity.y = body.get_meta("pending_kb_y")
		#print("   Applied velocity: x=", body.velocity.x, " y=", body.velocity.y)
		#body.remove_meta("pending_kb_x")
		#body.remove_meta("pending_kb_y")
	#
	#print("Applied knockback AFTEr freeze: ", body.velocity)
	
	#set_meta("hit_processed", true)
	


func update_dimensions(radius: float, height: float):
	hitbox.shape.radius = radius
	hitbox.shape.height = height
	
	
func _ready():
	hitbox.shape = CapsuleShape3D.new()
	set_physics_process(false)
	pass
	
func _physics_process(delta):
	#if framez<duration:
		#framez += 1
	#elif framez == duration:
		#Engine.time_scale = 1
		#queue_free()
		#return
	#if get_parent().selfState != parentState:
		#Engine.time_scale = 1
		#queue_free()
		#return
	if framez < duration:
		framez += 1
	else:
		queue_free()
		return
	
	if get_parent() and get_parent().selfState != parentState:
		queue_free()
		return

func getHitstun (knockback):
	return floor(knockback * 0.533);
	#return floor(knockback * 0.4);

func hitlag(d,hit):
	#damage = d
	#hitlag_modifier = hit
	###return ((floor(d/3)+4)) 
	#return floor((((floor(d) * 0.65) + 6) * hit))
	var base = 3.0
	var damage_factor = floor(d / 3.0)
	var result = floor((base + damage_factor) * hit)
	return clamp(result, 2, 15)

@export var percentage = 0
@export var weight = 100
@export var base_knockback = 20
@export var ratio = 1

func knockback(p,d,w,ks,bk,r):
	percentage = p
	damage = d
	weight = w
	kb_scaling = ks
	base_kb = bk
	ratio = r
	return ((((((((percentage/10) + (percentage*damage/20))*(200*1.4/(weight+100))) +18)*(kb_scaling))+base_kb)*1))

func s_angle(body):
		if angle == 361:
			if knockbackVal > 28:
				if !body.is_on_floor() == true:
					angle = 40
				else:
					angle = 38
			else:
				if !body.is_on_floor() == true:
					angle = 40
				else:
					angle = 25
		elif angle == -181:
			if knockbackVal > 28:
				if !body.is_on_floor() == true:
					angle = (-40)+180
				else:
					angle = (-38)+180
			else:
				if !body.is_on_floor() == true:
					angle = (-40)+180
				else:
					angle = (-25)+180


const angleConversion = PI / 180

func getHorizontalDecay (angle): #The rate at which the opponant will slow down after knockback
	var decay = 0.051 * cos(angle * angleConversion) #Rate of decay is 0.051, to get horizontal rate; multiply by horizontal(cos) angle in radians
	decay = round(decay * 100000) / 100000 #Round to a whole number
	decay = decay * 1000 #Enlarge the rate of decay
	return decay

func getVerticalDecay (angle):
	var decay = 0.051 * sin(angle * angleConversion)
	decay = round(decay * 100000) / 100000
	decay = decay * 1000
	return abs(decay)

func getHorizontalVelocity (knockback, angle): # Function gets the horizontal knockback speed with total knockback and angle
	var initialVelocity = knockback * 0.3; #Gets the initial velocity by multiplying knockback by 30
	var horizontalAngle = cos(angle * angleConversion); #Horizontal angle is calculated by cos formula, angle conversion puts the angle in Radians
	var horizontalVelocity = initialVelocity * horizontalAngle; #Horizontal velocity is found by multiplying initial velocity by horizontal angle
	horizontalVelocity = round(horizontalVelocity * 100000) / 100000; #Round to a whole number
	return horizontalVelocity;

func getVerticalVelocity (knockback, angle):
	var initialVelocity = knockback * 0.3;
	var verticalAngle = sin(angle * angleConversion);
	var verticalVelocity = initialVelocity * verticalAngle;
	verticalVelocity = round(verticalVelocity * 100000) / 100000;
	return verticalVelocity

func rad2deg(radians: float) -> float:
	return radians * (180.0 / PI)

func get_azimuth_angle(v: Vector3) -> float:
	return rad2deg(atan2(v.z, v.x))



func angle_flipperv2(body_vel: Vector3, body_position: Vector3, hdecay = 0, vdecay = 0):
	var xangle
	#if get_parent().direction() == -1:
		#xangle = (-(((body_position.direction_to(get_parent().global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180) / PI) + 180
	#else:
	xangle = (((body_position.direction_to(get_parent().global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180) / PI + 180

	match angle_flipper:
		0: # Same Knockback
			body_vel.x = (getHorizontalVelocity(knockbackVal, -angle))
			body_vel.y = (getVerticalVelocity(knockbackVal, angle))
			hdecay = (getHorizontalDecay(-angle))
			vdecay = (getVerticalDecay(-angle))
			return ([body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay])

		1: # Sends away from center of enemy player
			if get_parent().direction() == -1:
				xangle = -(((self.global_transform.origin.direction_to(body_position)).angle_to(get_parent().global_transform.basis.x)) * 180) / PI
			else:
				xangle = (((self.global_transform.origin.direction_to(body_position)).angle_to(get_parent().global_transform.basis.x)) * 180) / PI
			body_vel.x = getHorizontalVelocity(knockbackVal, xangle + 180)
			body_vel.y = getVerticalVelocity(knockbackVal, -xangle)
			hdecay = getHorizontalDecay(angle + 180)
			vdecay = getVerticalDecay(xangle)
			return ([body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay])

		2: # sends toward center of enemy player
			if get_parent().direction() == -1:
				xangle = -(((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180) / PI
			else:
				xangle = (((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180) / PI
			body_vel.x = getHorizontalVelocity(knockbackVal, -xangle + 180)
			body_vel.y = getVerticalVelocity(knockbackVal, -xangle)
			hdecay = getHorizontalDecay(xangle + 180)
			vdecay = getVerticalDecay(xangle)
			return ([body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay])

		3: # horizontal knockback sends away from the center of the hitbox
			if get_parent().direction() == -1:
				xangle = (-(((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180) / PI) + 180
			else:
				xangle = (((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180) / PI
			body_vel.x = getHorizontalVelocity(knockbackVal, xangle + 135)
			body_vel.y = getVerticalVelocity(knockbackVal, angle)
			hdecay = getHorizontalDecay(xangle + 135)
			vdecay = getVerticalDecay(angle)
			return ([body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay])

		4: # horizontal knockback sends toward the center of the hitbox
			if get_parent().direction() == -1:
				xangle = -(((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180) / PI + 180
			else:
				xangle = (((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180) / PI
			body_vel.x = getHorizontalVelocity(knockbackVal, -xangle * 180)
			body_vel.y = getVerticalVelocity(knockbackVal, -angle)
			hdecay = getHorizontalDecay(angle)
			vdecay = getVerticalDecay(angle)
			return ([body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay])

		5: # horizontal knockback is reversed
			body_vel.x = getHorizontalVelocity(knockbackVal, angle + 180)
			body_vel.y = getVerticalVelocity(knockbackVal, -angle)
			hdecay = getHorizontalDecay(angle + 180)
			vdecay = getVerticalDecay(angle)
			return ([body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay])

		6: # horizontal knockback sends away from the enemy player
			body_vel.x = getHorizontalVelocity(knockbackVal, xangle)
			body_vel.y = getVerticalVelocity(knockbackVal, -angle)
			hdecay = getHorizontalDecay(xangle)
			vdecay = getVerticalDecay(angle)
			return ([body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay])

		7: # horizontal knockback sends toward the enemy player
			body_vel.x = getHorizontalVelocity(knockbackVal, -xangle + 180)
			body_vel.y = getVerticalVelocity(knockbackVal, -angle)
			hdecay = getHorizontalDecay(angle)
			vdecay = getVerticalDecay(angle)
			return ([body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay])
		
		8:	# Downward Spike (pure/down-forward, facing-aware)
			# Use 'angle' if it's already negative (e.g., -30), otherwise default to -60
			var send_deg := -60.0
			if float(angle) < 0.0:
				send_deg = float(angle)
			# Flip horizontally if attacker is facing left (add 180)
			if get_parent().direction() == -1:
				send_deg = send_deg + 180.0
			body_vel.x = getHorizontalVelocity(knockbackVal, send_deg)
			body_vel.y = getVerticalVelocity(knockbackVal, send_deg)  # will be negative for downward angles
			hdecay = getHorizontalDecay(abs(send_deg))
			vdecay = getVerticalDecay(abs(send_deg))
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
		
		9: # Vertical
			var up_angle := 90.0
			body_vel.x = 0.0
			body_vel.y = getVerticalVelocity(knockbackVal, up_angle)
			hdecay = 0.0
			vdecay = getVerticalDecay(up_angle)
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

#func angle_flipperv2(body_vel: Vector3, body_position: Vector3, hdecay := 0, vdecay := 0):
	#var xangle := 0.0
	#if get_parent().direction() == -1:
		#xangle = (-(((body_position.direction_to(get_parent().global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI) + 180.0
	#else:
		#xangle = (((body_position.direction_to(get_parent().global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI + 180.0
#
	#match angle_flipper:
		#0: # Same Knockback (use 'angle' as-is)
			#body_vel.x = getHorizontalVelocity(knockbackVal, -float(angle))
			#body_vel.y = getVerticalVelocity(knockbackVal, float(angle))
			#hdecay = getHorizontalDecay(-float(angle))
			#vdecay = getVerticalDecay(-float(angle))
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#1: # Sends away from center of enemy player
			#if get_parent().direction() == -1:
				#xangle = -(((self.global_transform.origin.direction_to(body_position)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI
			#else:
				#xangle = (((self.global_transform.origin.direction_to(body_position)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI
			#body_vel.x = getHorizontalVelocity(knockbackVal, xangle + 180.0)
			#body_vel.y = getVerticalVelocity(knockbackVal, -xangle)
			#hdecay = getHorizontalDecay(float(angle) + 180.0)
			#vdecay = getVerticalDecay(xangle)
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#2: # Sends toward center of enemy player
			#if get_parent().direction() == -1:
				#xangle = -(((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI
			#else:
				#xangle = (((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI
			#body_vel.x = getHorizontalVelocity(knockbackVal, -xangle + 180.0)
			#body_vel.y = getVerticalVelocity(knockbackVal, -xangle)
			#hdecay = getHorizontalDecay(xangle + 180.0)
			#vdecay = getVerticalDecay(xangle)
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#3: # Horizontal knockback away from the hitbox center (with extra +135 skew)
			#if get_parent().direction() == -1:
				#xangle = (-(((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI) + 180.0
			#else:
				#xangle = (((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI
			#body_vel.x = getHorizontalVelocity(knockbackVal, xangle + 135.0)
			#body_vel.y = getVerticalVelocity(knockbackVal, float(angle))
			#hdecay = getHorizontalDecay(xangle + 135.0)
			#vdecay = getVerticalDecay(float(angle))
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#4: # Horizontal knockback toward the center of the hitbox
			#if get_parent().direction() == -1:
				#xangle = -(((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI + 180.0
			#else:
				#xangle = (((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI
			#body_vel.x = getHorizontalVelocity(knockbackVal, -xangle + 180.0)
			#body_vel.y = getVerticalVelocity(knockbackVal, -float(angle))
			#hdecay = getHorizontalDecay(float(angle))
			#vdecay = getVerticalDecay(float(angle))
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#5: # Horizontal knockback reversed (flip 180 relative to 'angle')
			#body_vel.x = getHorizontalVelocity(knockbackVal, float(angle) + 180.0)
			#body_vel.y = getVerticalVelocity(knockbackVal, -float(angle))
			#hdecay = getHorizontalDecay(float(angle) + 180.0)
			#vdecay = getVerticalDecay(float(angle))
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#6: # Horizontal knockback away from the enemy player (uses bearing xangle)
			#body_vel.x = getHorizontalVelocity(knockbackVal, xangle)
			#body_vel.y = getVerticalVelocity(knockbackVal, -float(angle))
			#hdecay = getHorizontalDecay(xangle)
			#vdecay = getVerticalDecay(float(angle))
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#7: # Horizontal knockback toward the enemy player
			#body_vel.x = getHorizontalVelocity(knockbackVal, -xangle + 180.0)
			#body_vel.y = getVerticalVelocity(knockbackVal, -float(angle))
			#hdecay = getHorizontalDecay(float(angle))
			#vdecay = getVerticalDecay(float(angle))
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#8: # Vertical UP (pure vertical launch)
			#var up_angle := 90.0
			#body_vel.x = 0.0
			#body_vel.y = getVerticalVelocity(knockbackVal, up_angle)
			#hdecay = 0.0
			#vdecay = getVerticalDecay(up_angle)
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#9: # Downward Spike (pure/down-forward, facing-aware)
			## Use 'angle' if it's already negative (e.g., -30), otherwise default to -60
			#var send_deg := -60.0
			#if float(angle) < 0.0:
				#send_deg = float(angle)
			## Flip horizontally if attacker is facing left (add 180)
			#if get_parent().direction() == -1:
				#send_deg = send_deg + 180.0
			#body_vel.x = getHorizontalVelocity(knockbackVal, send_deg)
			#body_vel.y = getVerticalVelocity(knockbackVal, send_deg)  # will be negative for downward angles
			#hdecay = getHorizontalDecay(abs(send_deg))
			#vdecay = getVerticalDecay(abs(send_deg))
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#10: # Pure forward (0° if facing right, 180° if facing left)
			#var fwd_deg := 0.0
			#if get_parent().direction() == -1:
				#fwd_deg = 180.0
			#else:
				#fwd_deg = 0.0
			#body_vel.x = getHorizontalVelocity(knockbackVal, fwd_deg)
			#body_vel.y = getVerticalVelocity(knockbackVal, fwd_deg)
			#hdecay = getHorizontalDecay(fwd_deg)
			#vdecay = getVerticalDecay(fwd_deg)
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#11: # Pure down (−90° straight down)
			#var down_deg := -90.0
			#body_vel.x = getHorizontalVelocity(knockbackVal, down_deg)  # ~0
			#body_vel.y = getVerticalVelocity(knockbackVal, down_deg)    # negative
			#hdecay = getHorizontalDecay(abs(down_deg))
			#vdecay = getVerticalDecay(abs(down_deg))
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#12: # Autolink toward attacker with slight upward bias (+20°), clamped
			## Vector from target to attacker (use hitbox's parent as attacker center)
			#var attacker_pos = get_parent().global_transform.origin
			#var to_attacker = attacker_pos - body_position
			## Derive base angle in degrees in X/Y plane
			#var base_deg := rad2deg(atan2(to_attacker.y, to_attacker.x))
			## Add a gentle upward bias
			#var biased_deg := base_deg + 20.0
			## Clamp so it doesn't become a pure vertical launcher
			#if biased_deg > 80.0:
				#biased_deg = 80.0
			#if biased_deg < -80.0:
				#biased_deg = -80.0
			#body_vel.x = getHorizontalVelocity(knockbackVal, biased_deg)
			#body_vel.y = getVerticalVelocity(knockbackVal, biased_deg)
			#hdecay = getHorizontalDecay(abs(biased_deg))
			#vdecay = getVerticalDecay(abs(biased_deg))
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
#
		#_:
			## Fallback: behave like "Same Knockback"
			#body_vel.x = getHorizontalVelocity(knockbackVal, -float(angle))
			#body_vel.y = getVerticalVelocity(knockbackVal, float(angle))
			#hdecay = getHorizontalDecay(-float(angle))
			#vdecay = getVerticalDecay(-float(angle))
			#return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
