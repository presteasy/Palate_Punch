extends Resource
class_name Attacks

@export var name: StringName
@export var owner_type: String
@export var radius: float
@export var height: float
@export var depth: float
@export var damage: float
@export var angle: int
@export var base_kb: float
@export var kb_scaling: float
@export var duration: float
@export var type: String
@export var points: Vector3
@export var angle_flipper: int
@export var hitlag: float

@export_category("Frame Info")
@export var frame_start: int
@export var frame_end: int
#@export var recovery_on_hit: int
#@export var recovery_on_block: int
#@export var recovery_on_whiff: int
#@export var landing_lag_on_hit: int
#@export var landing_lag_on_block: int
#@export var landing_lag_on_whiff: int
#@export var hitstop_attacker: int
#@export var hitstop_victim: int
