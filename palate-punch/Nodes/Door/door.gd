class_name Door
extends Area3D

@export_group("Scene Change")
@export_file("*.tscn") var target_scene : String
@export var delete_previous : bool = true:
	set(val):
		delete_previous = val
		if delete_previous:
			keep_running = false
@export var keep_running: bool = false:
	set(val):
		keep_running = val if not delete_previous else false

@export_group("Triggering")
@export var require_interact : bool = false

var _player_inside : Node3D = null



func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = body
	if require_interact == false:
		_travel()

func _on_body_exited(body: Node3D) -> void:
	if body == _player_inside:
		_player_inside = null

func _unhandled_input(event: InputEvent) -> void:
	if require_interact and _player_inside and event.is_action_pressed("interact_%s" % Global.player.id):
		_travel()
		
func _travel() -> void:
	if target_scene.is_empty():
		push_warning("Door has no target_scene set.")
		return
	Global.game_controller.change_3d_scene(target_scene, delete_previous, keep_running)
