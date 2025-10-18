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
	#print("Hitbox collided with: ", body.name)
	#if body.character_type == owner_type:
		#if not body in player_list:
			#player_list.append(body)
			#if body.has_node("Health"):
				#var health_node = body.get_node("Health")
				#health_node.take_damage(damage)
##				emit_signal("damage_dealt", damage, body)
			#var charstate 
			#charstate = body.get_node("StateMachine")
			#weight = body.weight
		#
			#knockbackVal = knockback(damage,weight,kb_scaling,base_kb,1)
			#match angle_flipper:
				#0: # No Launch
					#knockbackVal *= 0
				#1: # Standard Launch
					#knockbackVal *= 1
				#2: # Upward Launch
					#knockbackVal *= 2
				#3: # Push Launch
					#knockbackVal *= 3
				#4: #High Standard Launch
					#knockbackVal *= 4
				#5: #High Upward Diagonal Launch
					#knockbackVal *= 7
				#_:
					#knockbackVal *= 0
					#
			#charstate.state = charstate.states.HITFREEZE
			#charstate.hitfreeze(hitlag(damage,hitlag_modifier),angle_flipperv2(Vector3(body.velocity.x,body.velocity.y,body.velocity.z),body.global_position))
			#
			#body.knockback = knockbackVal
			#body.hitstun = getHitstun(knockbackVal/0.3)
			#get_parent().connected = true
			#body._frame()
			#
	##		Globals.hitstun(hitlag(damage,hitlag_modifier),hitlag(damage,hitlag_modifier)/60)
			#get_parent().hit_pause_dur = duration - framez
			#get_parent().temp_pos = get_parent().position
			#get_parent().temp_vel = get_parent().velocity
	#
	#emit_signal("hitbox_collided", self, body, knockbackVal)


func Hitbox_Collide(body):
	#body = body.get_parent()
	var prop_list = body.get_property_list()
	var found: bool = false
	for prop in prop_list:
		if prop.name == "character_type":
			found = true
			break
	if body == parent:
		return
	else:
		if found:
			if body.character_type != owner_type:
				if !(body.get_parent() in player_list):
				#if body.name == "Parrybox":
					#set_collision_mask_value(1,false)
					#parry = true
					#if get_parent().is_on_floor() == false:
						#var selfstate = get_parent().get_node("StateMachine")
						#selfstate.state = selfstate.states.STUNNED
				#else:
					#body = body.get_parent()
					player_list.append(body)
					if body.has_node("Health"):
						var health_node = body.get_node("Health")
						health_node.take_damage(damage)
					var charstate
					charstate = body.get_node("StateMachine")
					weight = body.weight
					body.percentage += damage
					knockbackVal = knockback(body.percentage,damage,weight,kb_scaling,base_kb,1)
					s_angle(body)
					charstate.state = charstate.states.HITSTOP
					charstate.hitfreeze(hitlag(damage,hitlag_modifier),angle_flipperv2(Vector3(body.velocity.x,body.velocity.y,body.velocity.z),body.global_position))
					
					body.knockback = knockbackVal
					body.hitstun = getHitstun(knockbackVal/0.3)
					get_parent().connected = true
					var bodyframe
					bodyframe = body.get_node("FrameData")
					bodyframe._frame()
					
					Global.game_controller.hitstun(hitlag(damage,hitlag_modifier),hitlag(damage,hitlag_modifier)/60)
					get_parent().hit_pause_dur = duration - framez
					get_parent().temp_pos = get_parent().position
					get_parent().temp_vel = get_parent().velocity
					SignalManager.emit_signal("hit_landed")
		else:
			return
	print("Collided with: ", body, " Class: ", body.get_class())

func update_dimensions(radius: float, height: float):
	hitbox.shape.radius = radius
	hitbox.shape.height = height
	
	
func _ready():
	hitbox.shape = CapsuleShape3D.new()
	set_physics_process(false)
	pass
	
func _physics_process(delta):
	if framez<duration:
		framez += 1
	elif framez == duration:
		Engine.time_scale = 1
		queue_free()
		return
	if get_parent().selfState != parentState:
		Engine.time_scale = 1
		queue_free()
		return

func getHitstun (knockback):
	return floor(knockback * 0.533);
	#return floor(knockback * 0.4);

func hitlag(d,hit):
	damage = d
	hitlag_modifier = hit
	#return ((floor(d/3)+4)) 
	return floor((((floor(d) * 0.65) + 6) * hit))

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
	return ((((((((percentage/10) + (percentage*damage/20))*(200*1.4/(weight+100))) +18)*(kb_scaling))+base_kb)*1))*.003

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
	var initialVelocity = knockback * 10; #Gets the initial velocity by multiplying knockback by 30
	var horizontalAngle = cos(angle * angleConversion); #Horizontal angle is calculated by cos formula, angle conversion puts the angle in Radians
	var horizontalVelocity = initialVelocity * horizontalAngle; #Horizontal velocity is found by multiplying initial velocity by horizontal angle
	horizontalVelocity = round(horizontalVelocity * 100000) / 100000; #Round to a whole number
	return horizontalVelocity;

func getVerticalVelocity (knockback, angle):
	var initialVelocity = knockback * 10;
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
		
		8:	# Vertical UP
			pass
		
		9: # Downward Spike
			pass
