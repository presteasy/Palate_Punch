extends Node
class_name StateMachine

var state = null : set = set_state
var previous_state = null
var states = {}

@onready var parent = get_parent()

func _physics_process(delta: float) -> void:
	#print("🟢 _physics_process on node: ", get_path(), " | Parent: ", get_parent().name)
	if state != null:
		
		#var state_name = get_state_name()
		#print("Current State: ", state_name)
		
		state_logic(delta)
		var transition = get_transition(delta)
		if transition != null:
			set_state(transition)
func state_logic(delta):
	pass
	
func get_transition(delta):
	return null
	
func enter_state(new_state, old_state):
	pass

func exit_state(old_state, new_state):
	pass
	
func set_state(new_state):
	previous_state = state
	state = new_state
	
	if previous_state != null:
		exit_state(previous_state, new_state)
	if new_state != null:
		enter_state(new_state, previous_state)

func add_state(state_name) -> void:
	states[state_name] = states.size()
	
func get_state_name() -> String:
	for state_name in states:
		if states[state_name] == state:
			return state_name
	return "UNKNOWN"
