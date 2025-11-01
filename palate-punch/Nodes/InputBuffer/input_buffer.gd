extends Node
class_name InputBuffer

@onready var id = get_parent().get_parent().id
var _buffer := {}
var current_frame: int = 0
var _freeze_ticking: bool = false

@export var watched_actions = [
	"attack_%s" % id,
	"special_%s" % id,
	"jump_%s" % id,
	"block_%s" % id,
	"left_%s" % id,
	"right_%s" % id,
	"down_%s" % id
]

@export var default_window_frames: int = 6

func set_frozen(frozen: bool) -> void: #still setting HitSTOP/HitFreeze mechanics
	_freeze_ticking = frozen
	
func tick(frame_index: int) -> void:
	current_frame = frame_index
	_record_just_pressed()
	_prune_expired()
	
func _record_just_pressed() -> void:
	for a in watched_actions:
		if Input.is_action_pressed(a):
			_buffer[a] = current_frame + default_window_frames
	
func _prune_expired() -> void:
	var to_remove := []
	for a in _buffer.keys():
		var expire = int(_buffer[a])
		if expire <= current_frame:
			to_remove.append(a)
	for a in to_remove:
		_buffer.erase(a)
		
func buffer_action(action: StringName, window_frames: int = -1) -> void:
	if window_frames <= 0:
		window_frames = default_window_frames
	_buffer[action] = current_frame + window_frames
	
func is_buffered(action: StringName) -> bool:
	return _buffer.has(action)
	
func consume(action: StringName) -> bool:
	if _buffer.has(action):
		_buffer.erase(action)
		return true
	return false

func clear_all() -> void:
	_buffer.clear()
	
