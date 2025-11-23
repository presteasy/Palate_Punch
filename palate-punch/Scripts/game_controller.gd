class_name GameController
extends Node


@export var world_3d : Node3D
@export var gui : CanvasLayer
@export var player_parent : Node3D

var current_3d_scene : Node
var current_gui_scene
var is_in_hitstop: bool = false

var hit: bool = false


func _ready() -> void:
	Global.game_controller = self
	Global.world3d = get_node("%World3D")
	current_gui_scene = %StartMenu

#-----SCENE CHANGE------
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
			for s in get_tree().get_nodes_in_group("level"):
				s.queue_free()
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
	await get_tree().create_timer(0.5).timeout
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


#-----RESTART WORLD-----
func restart_active_world():
	if current_3d_scene == null:
		return
	var path := current_3d_scene.scene_file_path
	if path == "":
		push_error("Active Scene has no scene_file_path; cannot restart.")
		return
	
	var old := current_3d_scene
	var fresh: Node = load(path).instantiate()
	
	if current_3d_scene is Node3D and fresh is Node3D:
		fresh.transform = (current_3d_scene as Node3D).transform
		
	Global.world3d.add_child(fresh)
	current_3d_scene = fresh
	
	old.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	
	InputHandler.set_input_mode(InputHandler.InputMode.GAMEPLAY)
	
	return fresh
	
#-----PLAYER STUFF-----	
func reset_player() -> void:
	#var target_player := get_tree().get_first_node_in_group("player")
	#target_player.queue_free()
	#target_player.remove_from_group("player")
	for p in get_tree().get_nodes_in_group("player"):
		p.queue_free()

func _find_player_spawn() -> Marker3D:
	var nodes := get_tree().get_nodes_in_group("player_spawn")
	if nodes.size() > 0:
		return nodes[0] as Marker3D
	return null
	
func _find_player() -> void:
	var target_player := get_tree().get_first_node_in_group("player")
	SignalManager.emit_signal("pcam_find_player", target_player)
	print("find player signal emitted")

func spawn_player() -> void:
	print("🔴 spawn_player() CALLED!")
	print_stack()
	var spawn := _find_player_spawn()
	if spawn == null:
		push_warning("No Marker3D in group 'player_spawn' found.")
		return
		
	var scene = preload("res://Actors/Player Servan/Servan.tscn")
	var new_player = scene.instantiate() as Player
	
	player_parent.add_child(new_player)
	new_player.global_transform.origin = spawn.global_transform.origin
	new_player.add_to_group("player")
	SignalManager.emit_signal("player_spawned", new_player)

func restart_level_and_respawn() -> void:
	InputHandler.game_paused = false
	reset_player()
	restart_active_world()
	spawn_player()
	


#-----HITSTOP-----
func freeze_hitstop(frames: int):
	#Engine.time_scale = 0.001
	#get_tree().paused = true
	#await get_tree().create_timer(frames / 60.0, PROCESS_MODE_ALWAYS).timeout
	#Engine.time_scale = 1
	#get_tree().paused = false
	
	var duration = frames/ 60.0
	Engine.time_scale = 0.0
	var timer = get_tree().create_timer(duration, true, false, true)
	await timer.timeout
	Engine.time_scale = 1.0
