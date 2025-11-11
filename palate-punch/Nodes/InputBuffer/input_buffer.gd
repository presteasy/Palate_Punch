extends Node
class_name InputBuffer

@onready var id = get_parent().get_parent().id
var _buffer: Dictionary = {}
var _consumed_at_frame: Dictionary = {}
var current_frame: int = 0
var _last_tick_frame: int = -1
var _freeze_ticking: bool = false
var _held_states: Dictionary = {}
var grace_period_frames: int = 0

var watched_actions: PackedStringArray = []
var active: bool = false

@export var default_window_frames: int = 3


func arm(actions: PackedStringArray):
	watched_actions = actions
	active = true


func _process(_delta):
	if not active:
		return
	#for a in watched_actions: #possible remove
		#if not InputMap.has_action(a) : continue

func set_frozen(frozen: bool) -> void: #still setting HitSTOP/HitFreeze mechanics
	_freeze_ticking = frozen
	
func tick(frame_index: int) -> void:
	if InputHandler.is_ui_mode():
		return
	
	if frame_index == _last_tick_frame:
		return
	_last_tick_frame = frame_index

	current_frame = frame_index
	_record_just_pressed()
	_prune_expired()

func set_grace_period(frames: int) -> void:
	grace_period_frames = frames
	
func _record_just_pressed() -> void:
	if grace_period_frames > 0:
		grace_period_frames -= 1
		print("Grace period active, ignoring inputs")
		return
		
	if InputHandler.current_input_mode == InputHandler.InputMode.UI:
		return
		
	for a in watched_actions:
		if not InputMap.has_action(a):
			continue
			
		var is_pressed = Input.is_action_pressed(a)
		var was_held = _held_states.get(a, false)
		
		_held_states[a] = is_pressed
		
		if is_pressed:
			var new_expire := current_frame + default_window_frames
			var old_expire: int = _buffer.get(a, -1)
			if new_expire > old_expire:
				_buffer[a] = new_expire
				if not was_held:
					print("Buffered: ", a, " until frame", _buffer[a])
	
func _prune_expired() -> void:
	var to_remove := []
	for a in _buffer.keys():
		if int(_buffer[a]) <= current_frame:
			to_remove.append(a)
	for a in to_remove:
		_buffer.erase(a)
		_consumed_at_frame.erase(a)
		
func buffer_action(action: StringName, window_frames: int = -1) -> void:
	if window_frames <= 0:
		window_frames = default_window_frames
	var new_expire := current_frame + window_frames
	var old_expire : int = _buffer.get(action, -1)
	if new_expire > old_expire:
		_buffer[action] = new_expire
		print("Buffered (manual): ", action, " until frame ", new_expire)

func is_held(action: StringName) -> bool:
	return _held_states.get(action, false)

func is_buffered(action: StringName) -> bool:
	return _buffer.has(action)
	
func consume(action: StringName) -> bool:
	if _consumed_at_frame.get(action, -1) == current_frame:
		return false
		
	if not _buffer.has(action):
		return false

	_consumed_at_frame[action] = current_frame
	_buffer.erase(action)
	print("Consumed: ", action, " at frame", current_frame)
	return true

func clear_action(action: StringName) -> void:
	_buffer.erase(action)
	_consumed_at_frame.erase(action)
	_held_states.erase(action)
	print("Cleared action: ", action)
	
func clear_actions(actions: Array) -> void:
	for action in actions:
		clear_action(action)	
	
func clear_all() -> void:
	print("📢 clear_all() called! Clearing buffers:")
	print("   Buffered actions: ", _buffer.keys())
	print("   Held states: ", _held_states.keys())
	_buffer.clear()
	_consumed_at_frame.clear()
	_held_states.clear()
	print("   ✅ All buffers cleared!")
