extends Node

var player : Player

enum InputMode {
	GAMEPLAY,
	UI
}

signal input_mode_changed(mode: InputMode)
signal toggle_game_paused(is_paused : bool)
#signal toggle_player_inv(is_inv : bool)

var current_input_mode: InputMode = InputMode.UI
var pause_open: bool = false
var game_mode: bool = false
#var ui_mode: bool = false
var player_inv_open: bool = false


var game_paused : bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused", game_paused)
		print("pause signal emitted")

var inv_paused : bool = false:
	get:
		return inv_paused
	set(inv_value):
		inv_paused = inv_value
		get_tree().paused = inv_paused
		#emit_signal("toggle_player_inv", inv_paused)
		#print("inventory signal emitted")
		


func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
func _process(delta: float) -> void:
	if game_mode == true:
		set_input_mode(InputMode.GAMEPLAY)
	else:
		set_input_mode(InputMode.UI)
	#print(current_input_mode)

	
func set_input_mode(mode: InputMode):
	current_input_mode = mode
	emit_signal("input_mode_changed", mode)
	
func is_gameplay_mode() -> bool:
	return current_input_mode == InputMode.GAMEPLAY
	
func is_ui_mode() -> bool:
	return current_input_mode == InputMode.UI
			
