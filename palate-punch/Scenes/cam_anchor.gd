extends Node3D

@export var fixed_z : float = 0.0
@export var min_y : float = 0.0
@export var follow_speed : float = 8.0

@export var dz_up : float = 2.5
@export var dz_down : float = 1.5
@export var baseline_return : float = 1.5

var _target : Node3D
var _baseline_y : float

func _ready() -> void:
	SignalManager.player_spawned.connect(_on_player_spawned)
	
	
func _physics_process(delta: float) -> void:
	if _target == null:
		return
	var tpos := _target.global_position
	var lower := _baseline_y - dz_down
	var upper := _baseline_y + dz_up
	if tpos.y > upper:
		_baseline_y = tpos.y - dz_up
	elif tpos.y < lower:
		_baseline_y = tpos.y + dz_down
	else:
		_baseline_y = max(min_y, _baseline_y- baseline_return * delta)
	
	var desired := Vector3(tpos.x, max(min_y, _baseline_y), fixed_z)
	var a := 1.0 - pow(0.001, delta * follow_speed)
	global_position = global_position.lerp(desired, a)

func _on_player_spawned(new_player: Node) -> void:
	if new_player:
		_set_target(new_player)
		
func _set_target(n: Node) -> void:
	if not (n is Node3D):
		return
	_target = n
	_baseline_y = max(min_y, _target.global_position.y)
	print("CamAnchor target set to:", _target.name)
