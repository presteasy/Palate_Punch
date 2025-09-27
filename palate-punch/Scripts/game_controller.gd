class_name GameController
extends Node


@export var world_3d : Node3D
@export var gui : CanvasLayer
@export var player_parent : Node3D

@onready var player : Player
var current_3d_scene : Node
var current_gui_scene


func _ready() -> void:
	Global.game_controller = self
	Global.world3d = get_node("%World3D")
	current_gui_scene = %StartMenu


func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new


func change_3d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_3d_scene != null:
		if delete:
			current_3d_scene.queue_free()
		elif keep_running:
			current_3d_scene.visible = false
		else:
			world_3d.remove_child(current_3d_scene)
	var new = load(new_scene).instantiate()
	world_3d.add_child(new)
	current_3d_scene = new
	_find_player()
	
func change_gui_to_3d(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)
	var new = load(new_scene).instantiate()
	world_3d.add_child(new)
	current_3d_scene = new
	InputHandler.set_input_mode(InputHandler.InputMode.GAMEPLAY)

func change_3d_to_gui(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_3d_scene != null:
		if delete:
			current_3d_scene.queue_free()
		elif keep_running:
			current_3d_scene.visible = false
		else:
			world_3d.remove_child(current_3d_scene)
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new
	InputHandler.set_input_mode(InputHandler.InputMode.UI)

func restart_active_world() -> void:
	if current_3d_scene == null:
		return
	var path := current_3d_scene.scene_file_path
	if path == "":
		push_error("Active Scene has no scene_file_path; cannot restart.")
		return
	var fresh: Node = load(path).instantiate()
	if current_3d_scene is Node3D and fresh is Node3D:
		fresh.transform = (current_3d_scene as Node3D).transform
	Global.world3d.add_child(fresh)
	current_3d_scene.queue_free()
	current_3d_scene = fresh
	InputHandler.set_input_mode(InputHandler.InputMode.GAMEPLAY)
	
func reset_player() -> void:
	Global.player.queue_free()
	spawn_player()

func _find_player_spawn() -> Marker3D:
	var nodes := get_tree().get_nodes_in_group("player_spawn")
	if nodes.size() > 0:
		return nodes[0] as Marker3D
	return null
	
func _find_player() -> void:
	var target_player = get_tree().get_first_node_in_group("player")
	SignalManager.emit_signal("pcam_find_player", target_player)
	print("find player signal emitted")

func spawn_player() -> void:
	var spawn := _find_player_spawn()
	if spawn == null:
		push_warning("No Marker3D in group 'player_spawn' found.")
		return
		
	var scene = preload("res://Actors/Player Servan/Servan.tscn")
	var new_player = scene.instantiate() as CharacterBody3D
	player_parent.add_child(new_player)
	new_player.global_transform.origin = spawn.global_transform.origin
	new_player.add_to_group("player")
	SignalManager.emit_signal("player_spawned", new_player)
