# res://combat/AttackRunner.gd
extends Node
class_name AttackRunner

const MoveSpec = preload("res://Resources/Moves/move_spec.gd")

# Inject dependencies via NodePaths (set these in the Inspector)
@export_node_path("Node") var hitbox_manager_path: NodePath
@export_node_path("Node") var framedata_path: NodePath
@export_node_path("Node") var user_path: NodePath   # optional: actor root for armor/invuln flags, etc.

@onready var hb_manager: Node = null
@onready var framedata: Node = null
@onready var user: Node = null

# Assign one or more MoveSpecs in the Inspector (per-actor)
@export var moves: Array[MoveSpec] = []

# Runtime state
var current_spec: MoveSpec = null
var running: bool = false

func _ready() -> void:
	
	if hitbox_manager_path != NodePath(""):
		hb_manager = get_node(hitbox_manager_path)
	else:
		hb_manager = null

	if framedata_path != NodePath(""):
		framedata = get_node(framedata_path)
	else:
		framedata = null

	if user_path != NodePath(""):
		user = get_node(user_path)
	else:
		# Fallback to parent if not provided
		user = get_parent()

func start_move(spec: MoveSpec) -> void:
	if spec == null:
		return
	if framedata == null:
		return
	current_spec = spec
	running = true
	# framedata.start_timeline(anim_name)
	if framedata.has_method("start_timeline"):
		framedata.start_timeline(spec.anim_name)

func stop_move() -> void:
	# Safety: turn off all boxes and unfreeze animation
	if hb_manager != null and hb_manager.has_method("hb_off_all"):
		hb_manager.hb_off_all()
	if framedata != null and framedata.has_method("stop_timeline"):
		framedata.stop_timeline()
	current_spec = null
	running = false

# Step one frame; returns true exactly when the move ends this frame
func step() -> bool:
	if not running:
		return false
	if current_spec == null:
		return false
	if framedata == null:
		return false

	# Read current frame from FrameData (expects 'move_frame' int field)
	var f := 0
	if "frame" in framedata:
		f = framedata.frame
	else:
		# If move_frame doesn't exist, end to avoid desyncs
		stop_move()
		return true

	# Toggle hitboxes at boundaries from the spec
	var count := current_spec.hitboxes.size()
	var i := 0
	while i < count:
		var box = current_spec.hitboxes[i]
		if box != null:
			if f == box.active_start:
				hb_manager.call_deferred("hb_on", box.name)
			if f == box.active_end:
				hb_manager.call_deferred("hb_off", box.name)
		i += 1

	# (Optional) armor/invuln hooks could go here if your MoveSpec has those fields
	# Example:
	# if current_spec.armor != null and user != null:
	#     var in_armor := f >= current_spec.armor.start and f < current_spec.armor.end
	#     if user.has_variable("super_armor_threshold"):
	#         if in_armor:
	#             user.super_armor_threshold = current_spec.armor.threshold
	#         else:
	#             if user.super_armor_threshold != 0:
	#                 user.super_armor_threshold = 0

	# End condition
	if f >= current_spec.recovery_end:
		stop_move()
		return true

	return false

# Convenience lookup: returns a MoveSpec by move_name (or null if not found)
func get_spec(name: StringName) -> MoveSpec:
	var count := moves.size()
	var i := 0
	while i < count:
		var m: MoveSpec = moves[i]
		if m != null:
			if m.move_name == name:
				return m
		i += 1
	return null
