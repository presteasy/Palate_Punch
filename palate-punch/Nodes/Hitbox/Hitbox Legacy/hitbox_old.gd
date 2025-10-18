@tool
extends Area3D
class_name Hitbox_old

signal hitbox_collided(hitbox: Hitbox, body: Node, knockback_val: float)


@onready var hitbox_shape: CollisionShape3D = %HitboxShape

@export var owner_type: String = "player"

@export_enum("Capsule", "Box", "Sphere") var shape_type := "Capsule" : set = _set_shape_type
@export var radius: float = 0.35 : set = _set_radius
@export var height: float = 0.75 : set = _set_height
@export var depth: float  = 0.35 : set = _set_depth

#Placement relative to hitbox node
#@export var base_offset: Vector3 = Vector3(0.5, 1.0, 0.0) : set = _set_base_offset
@export var yaw_flip_on_left: bool = false
@export var lock_to_editor_position: bool = false

var facing_dir: int = 1
var _editor_pos: Vector3

@export var damage: int = 50
@export var angle: int = 90
@export var base_kb: float = 100.0
@export var kb_scaling: float = 0.5
@export var duration_ms: int = 1500
@export var hitlag_modifier: int = 1
@export var type: String = "normal"
@export var angle_flipper: int = 0
@export var freezeframes_duration: int = 10



# Optional smash-like fields kept from your logic
@export var percentage: float = 0.0
@export var weight: float = 100.0
@export var base_knockback: float = 20.0
@export var ratio: float = 1.0

# --- Runtime state ---
var knockbackVal: float = 0.0
var framez: float = 0.0
var player_list: Array = []

# Snapshot of parent state name if present
var parent_state_snapshot = null


const ANGLE_CONVERSION: float = PI / 180.0

func _ready() -> void:
	#_editor_pos = position
	connect("body_entered", Callable(self, "_on_body_entered"))
	SignalManager.hit_landed.connect(_on_body_entered)
	#visible = false
	#deactivate()
	
	if hitbox_shape == null:
		return
	monitoring = false
	_ensure_shape()
	_make_shape_unique()
	_apply_dims_to_shape()
	_apply_transform_from_facing()
	




	# Parent state snapshot
	#var p := get_parent()
	#if p != null and p.has_method("selfState"):
		#parent_state_snapshot = p.selfState
	#else:
		#parent_state_snapshot = null
#
	# Update preview in editor
	if Engine.is_editor_hint():
		set_process(true)

	#_zero_shape_local(hitbox_shape)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_apply_dims_to_shape()

func _zero_shape_local(cs: CollisionShape3D) -> void:
	if cs == null: return
	var t := cs.transform
	t.origin = Vector3.ZERO
	t.basis = Basis()
	cs.transform = t

# ---------- Public API ----------



func set_facing_dir(dir: int) -> void:
	if dir < 0:
		facing_dir = -1
	else:
		facing_dir = 1
	_apply_transform_from_facing()

func activate() -> void:
	#set_deferred("monitoring", true)
	#set_deferred("monitorable", true)
	#set_deferred("visible", true)
	#if hitbox_shape:
		#hitbox_shape.set_deferred("disabled", false)
	monitoring = true
	monitorable = true
	visible = true
	hitbox_shape.disabled = false
	framez = 0.0
	print("hb activated")
	

func deactivate() -> void:
	#set_deferred("monitoring", false)
	#set_deferred("monitorable", false)
	#set_deferred("visible", false)
	#if hitbox_shape:
		#hitbox_shape.set_deferred("disabled", true)
	monitoring = false
	monitorable = false
	visible = false
	hitbox_shape.disabled = true
	print("hitbox deactivated")

func set_parameters(ot, r, h, de, d, a, b_kb, kb_s, dur_ms, t, local_pos: Vector3, af, hit_mod, owner = null) -> void:
	owner_type = String(ot)
	radius = float(r)
	height = float(h)
	depth  = float(de)
	damage = int(d)
	angle  = int(a)
	base_kb = float(b_kb)
	kb_scaling = float(kb_s)
	duration_ms = int(dur_ms)
	type = String(t)
	position = local_pos
	angle_flipper = int(af)
	hitlag_modifier = int(hit_mod)
	


# ---------- Dimensions ----------

func _set_shape_type(v: String) -> void:
	shape_type = v
	_ensure_shape()
	_make_shape_unique()
	_apply_dims_to_shape()

func _set_radius(v: float) -> void:
	radius = v
	_apply_dims_to_shape()

func _set_height(v: float) -> void:
	height = v
	_apply_dims_to_shape()

func _set_depth(v: float) -> void:
	depth = v
	_apply_dims_to_shape()

#func _set_base_offset(v: Vector3) -> void:
	#base_offset = v
	#_apply_transform_from_facing()

#----Shape Helpers----

func _ensure_shape() -> void:
	if not hitbox_shape: return
	if hitbox_shape.shape == null:
		match shape_type:
			"Capsule": hitbox_shape.shape = CapsuleShape3D.new()
			"Box": hitbox_shape.shape = BoxShape3D.new()
			"Sphere": hitbox_shape.shape = SphereShape3D.new()
	else:
		match shape_type:
			"Capsule":
				if not (hitbox_shape.shape is CapsuleShape3D):
					hitbox_shape.shape = CapsuleShape3D.new()
			"Box":
				if not (hitbox_shape.shape is BoxShape3D):
					hitbox_shape.shape = BoxShape3D.new()
			"Sphere":
				if not (hitbox_shape.shape is SphereShape3D):
					hitbox_shape.shape = SphereShape3D.new()
					
func _make_shape_unique() -> void:
	if hitbox_shape and hitbox_shape.shape != null:
		hitbox_shape.shape = hitbox_shape.shape.duplicate()

func _apply_dims_to_shape() -> void:
	if hitbox_shape == null or hitbox_shape.shape == null:
		return
	if hitbox_shape.shape is CapsuleShape3D:
		var cap := hitbox_shape.shape as CapsuleShape3D
		cap.radius = max(radius, 0.0)
		cap.height = max(height, 0.0)
	elif hitbox_shape.shape is BoxShape3D:
		var box := hitbox_shape.shape as BoxShape3D
		box.size = Vector3(max(depth, 0.0), max(height, 0.0), max(depth, 0.0))
	elif hitbox_shape.shape is SphereShape3D:
		var sph := hitbox_shape.shape as SphereShape3D
		sph.radius = max(radius, 0.0)
	_refresh_gizmo()
		
func _apply_transform_from_facing() -> void:
	var base := position
	var ax = abs(base.x)
	if facing_dir < 0:
		base.x = -ax
	else:
		base.x = ax
	position = base
	if yaw_flip_on_left:
		if facing_dir < 0:
			rotation.y = PI
		else:
			rotation.y = 0.0
			
func _refresh_gizmo() -> void:
	if Engine.is_editor_hint() and hitbox_shape:
		hitbox_shape.notify_property_list_changed()
		hitbox_shape.update_gizmos()


# ---------- Collision ----------

func _on_body_entered(body: Node) -> void:
	if not monitoring:
		return
	if body == null:
		return

	# Team/type filter
	var body_type := ""
	if body.has_method("character_type"):
		body_type = str(body.character_type)
	elif "character_type" in body:
		body_type = str(body.character_type)
	else:
		# If target has no type info, you can decide to accept or ignore.
		# Here we ignore to match your original filter behavior.
		return

	if body_type != owner_type:
		return

	# Prevent multi-hits per activation
	if body in player_list:
		return
	var gp := body.get_parent()
	if gp != null and gp in player_list:
		return
	player_list.append(body)

	# Apply damage if a Health node exists
	if body.has_node("Health"):
		var health_node := body.get_node("Health")
		if health_node != null and health_node.has_method("take_damage"):
			health_node.take_damage(damage)

	# Smash-like accumulation
	if "percentage" in body:
		var cur := float(body.percentage)
		body.percentage = cur + float(damage)

	# Weight
	var w := 100.0
	if "weight" in body:
		w = float(body.weight)

	# Compute knockback
	var p_val := 0.0
	if "percentage" in body:
		p_val = float(body.percentage)
	knockbackVal = knockback(p_val, float(damage), w, kb_scaling, base_kb, 1.0)

	# Angle rules from your code
	s_angle(body)

	# Optional state machine integration
	var charstate = null
	if body.has_node("StateMachine"):
		charstate = body.get_node("StateMachine")

	if charstate != null and "states" in charstate:
		charstate.state = charstate.states.HITFREEZE
		if charstate.has_method("hitfreeze"):
			var body_vel := Vector3(body.velocity.x, body.velocity.y, body.velocity.z)
			var arr = angle_flipperv2(body_vel, body.global_position)
			charstate.hitfreeze(hitlag(damage, hitlag_modifier), arr)

	# Write knockback/hitstun fields if present
	if "knockback" in body:
		body.knockback = knockbackVal
	if "hitstun" in body:
		body.hitstun = getHitstun(knockbackVal / 0.3)

	# Optional backrefs used by your system
	var par := get_parent()
	if par != null and "connected" in par:
		par.connected = true
	if body.has_method("_frame"):
		body._frame()

	emit_signal("hitbox_collided", self, body, knockbackVal)
	SignalManager.emit_signal("hit_landed", body)
	print("hitbox signal emitted")


# ---------- Timing (optional self-expire for spawned boxes) ----------

func _physics_process(delta: float) -> void:
	if not monitoring:
		return
	framez = framez + (delta * 1000.0)
	if framez >= float(duration_ms):
		monitoring = false
		queue_free()

# ---------- Math ----------

func getHitstun(knockback: float) -> int:
	return int(floor(knockback * 0.533))

func hitlag(d: int, hit: int) -> int:
	var fd := float(d)
	var result = ((floor(fd) * 0.65) + 6.0) * float(hit)
	return int(floor(result))

func knockback(p: float, d: float, w: float, ks: float, bk: float, r: float) -> float:
	var part := (p / 10.0) + (p * d / 20.0)
	var scale := (200.0 * 1.4) / (w + 100.0)
	var total := ((part * scale) + 18.0) * ks + bk
	return total * 0.003

func s_angle(body: Node) -> void:
	# “Sakurai angle” rules
	if angle == 361:
		if knockbackVal > 28.0:
			if body.is_on_floor() == false:
				angle = 40
			else:
				angle = 38
		else:
			if body.is_on_floor() == false:
				angle = 40
			else:
				angle = 25
	elif angle == -181:
		if knockbackVal > 28.0:
			if body.is_on_floor() == false:
				angle = (-40) + 180
			else:
				angle = (-38) + 180
		else:
			if body.is_on_floor() == false:
				angle = (-40) + 180
			else:
				angle = (-25) + 180

func getHorizontalDecay(angle_deg: float) -> float:
	var decay := 0.051 * cos(angle_deg * ANGLE_CONVERSION)
	decay = round(decay * 100000.0) / 100000.0
	return decay * 1000.0

func getVerticalDecay(angle_deg: float) -> float:
	var decay := 0.051 * sin(angle_deg * ANGLE_CONVERSION)
	decay = round(decay * 100000.0) / 100000.0
	return abs(decay) * 1000.0

func getHorizontalVelocity(kb: float, angle_deg: float) -> float:
	var initial_velocity := kb * 10.0
	var h_angle := cos(angle_deg * ANGLE_CONVERSION)
	var hv := initial_velocity * h_angle
	return round(hv * 100000.0) / 100000.0

func getVerticalVelocity(kb: float, angle_deg: float) -> float:
	var initial_velocity := kb * 10.0
	var v_angle := sin(angle_deg * ANGLE_CONVERSION)
	var vv := initial_velocity * v_angle
	return round(vv * 100000.0) / 100000.0

func rad2deg(radians: float) -> float:
	return radians * (180.0 / PI)

func get_azimuth_angle(v: Vector3) -> float:
	return rad2deg(atan2(v.z, v.x))

func angle_flipperv2(body_vel: Vector3, body_position: Vector3, hdecay := 0, vdecay := 0):
	var xangle := 0.0
	if get_parent().direction() == -1:
		xangle = (-(((body_position.direction_to(get_parent().global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI) + 180.0
	else:
		xangle = (((body_position.direction_to(get_parent().global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI + 180.0

	match angle_flipper:
		0: # Same Knockback (use 'angle' as-is)
			body_vel.x = getHorizontalVelocity(knockbackVal, -float(angle))
			body_vel.y = getVerticalVelocity(knockbackVal, float(angle))
			hdecay = getHorizontalDecay(-float(angle))
			vdecay = getVerticalDecay(-float(angle))
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

		1: # Sends away from center of enemy player
			if get_parent().direction() == -1:
				xangle = -(((self.global_transform.origin.direction_to(body_position)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI
			else:
				xangle = (((self.global_transform.origin.direction_to(body_position)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI
			body_vel.x = getHorizontalVelocity(knockbackVal, xangle + 180.0)
			body_vel.y = getVerticalVelocity(knockbackVal, -xangle)
			hdecay = getHorizontalDecay(float(angle) + 180.0)
			vdecay = getVerticalDecay(xangle)
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

		2: # Sends toward center of enemy player
			if get_parent().direction() == -1:
				xangle = -(((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI
			else:
				xangle = (((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI
			body_vel.x = getHorizontalVelocity(knockbackVal, -xangle + 180.0)
			body_vel.y = getVerticalVelocity(knockbackVal, -xangle)
			hdecay = getHorizontalDecay(xangle + 180.0)
			vdecay = getVerticalDecay(xangle)
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

		3: # Horizontal knockback away from the hitbox center (with your extra +135 skew)
			if get_parent().direction() == -1:
				xangle = (-(((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI) + 180.0
			else:
				xangle = (((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI
			body_vel.x = getHorizontalVelocity(knockbackVal, xangle + 135.0)
			body_vel.y = getVerticalVelocity(knockbackVal, float(angle))
			hdecay = getHorizontalDecay(xangle + 135.0)
			vdecay = getVerticalDecay(float(angle))
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

		4: # Horizontal knockback toward the center of the hitbox
			if get_parent().direction() == -1:
				xangle = -(((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI + 180.0
			else:
				xangle = (((body_position.direction_to(self.global_transform.origin)).angle_to(get_parent().global_transform.basis.x)) * 180.0) / PI
			# FIX: this used to be "-xangle * 180"; that is likely a typo. Should be "-xangle + 180".
			body_vel.x = getHorizontalVelocity(knockbackVal, -xangle + 180.0)
			body_vel.y = getVerticalVelocity(knockbackVal, -float(angle))
			hdecay = getHorizontalDecay(float(angle))
			vdecay = getVerticalDecay(float(angle))
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

		5: # Horizontal knockback reversed (flip 180 relative to 'angle')
			body_vel.x = getHorizontalVelocity(knockbackVal, float(angle) + 180.0)
			body_vel.y = getVerticalVelocity(knockbackVal, -float(angle))
			hdecay = getHorizontalDecay(float(angle) + 180.0)
			vdecay = getVerticalDecay(float(angle))
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

		6: # Horizontal knockback away from the enemy player (uses bearing xangle)
			body_vel.x = getHorizontalVelocity(knockbackVal, xangle)
			body_vel.y = getVerticalVelocity(knockbackVal, -float(angle))
			hdecay = getHorizontalDecay(xangle)
			vdecay = getVerticalDecay(float(angle))
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

		7: # Horizontal knockback toward the enemy player
			body_vel.x = getHorizontalVelocity(knockbackVal, -xangle + 180.0)
			body_vel.y = getVerticalVelocity(knockbackVal, -float(angle))
			hdecay = getHorizontalDecay(float(angle))
			vdecay = getVerticalDecay(float(angle))
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

		8: # Vertical UP (pure vertical launch)
			var up_angle := 90.0
			body_vel.x = 0.0
			body_vel.y = getVerticalVelocity(knockbackVal, up_angle)
			hdecay = 0.0
			vdecay = getVerticalDecay(up_angle)
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

		9: # Downward Spike (pure/down-forward, facing-aware)
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

		10: # Pure forward (0° if facing right, 180° if facing left)
			var fwd_deg := 0.0
			if get_parent().direction() == -1:
				fwd_deg = 180.0
			else:
				fwd_deg = 0.0
			body_vel.x = getHorizontalVelocity(knockbackVal, fwd_deg)
			body_vel.y = getVerticalVelocity(knockbackVal, fwd_deg)
			hdecay = getHorizontalDecay(fwd_deg)
			vdecay = getVerticalDecay(fwd_deg)
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

		11: # Pure down (−90° straight down)
			var down_deg := -90.0
			body_vel.x = getHorizontalVelocity(knockbackVal, down_deg)  # ~0
			body_vel.y = getVerticalVelocity(knockbackVal, down_deg)    # negative
			hdecay = getHorizontalDecay(abs(down_deg))
			vdecay = getVerticalDecay(abs(down_deg))
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

		12: # Autolink toward attacker with slight upward bias (+20°), clamped
			# Vector from target to attacker (use hitbox's parent as attacker center)
			var attacker_pos = get_parent().global_transform.origin
			var to_attacker = attacker_pos - body_position
			# Derive base angle in degrees in X/Y plane
			var base_deg := rad2deg(atan2(to_attacker.y, to_attacker.x))
			# Add a gentle upward bias
			var biased_deg := base_deg + 20.0
			# Clamp so it doesn't become a pure vertical launcher
			if biased_deg > 80.0:
				biased_deg = 80.0
			if biased_deg < -80.0:
				biased_deg = -80.0
			body_vel.x = getHorizontalVelocity(knockbackVal, biased_deg)
			body_vel.y = getVerticalVelocity(knockbackVal, biased_deg)
			hdecay = getHorizontalDecay(abs(biased_deg))
			vdecay = getVerticalDecay(abs(biased_deg))
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]

		_:
			# Fallback: behave like "Same Knockback"
			body_vel.x = getHorizontalVelocity(knockbackVal, -float(angle))
			body_vel.y = getVerticalVelocity(knockbackVal, float(angle))
			hdecay = getHorizontalDecay(-float(angle))
			vdecay = getVerticalDecay(-float(angle))
			return [body_vel.x, body_vel.y, body_vel.z, hdecay, vdecay]
