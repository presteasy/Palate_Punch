extends Node3D
class_name VisualOffset

@export var visual_offset: Vector3 = Vector3.ZERO : set = _set_visual_offset
var facing_dir: int = 1

func set_facing_dir(dir: int) -> void:
	if dir < 0:
		facing_dir = -1
	else:
		facing_dir = 1
	_apply()
	
func _set_visual_offset(v: Vector3) -> void:
	visual_offset = v
	_apply()
	
func _apply() -> void:
	position = Vector3(visual_offset.x * facing_dir, visual_offset.y, visual_offset.z)
