extends Resource
class_name MoveSpec

@export var move_name: StringName
@export var anim_name: StringName

@export var windup_start: int = 0
@export var windup_end: int = 0
@export var active_end: int = 0
@export var recovery_end: int = 0

@export var hitboxes: Array[HitboxWindow] = []

@export_enum("none", "windup", "recovery") var can_move_during: String = "none"
@export var can_turn_on_startup: bool = true
