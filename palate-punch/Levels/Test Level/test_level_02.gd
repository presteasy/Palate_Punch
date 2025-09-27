extends Node3D

#@onready var pcam = %PhantomCamera3D
#@onready var host = %PhantomCameraHost
#@onready var player : CharacterBody3D
#@onready var camera = %Camera3D
#
#@export var host_layer_index: int = 1
#
#
#const PLAYER_GROUP = "player"
#
#func _ready() -> void:
	#pass
	#SignalManager.player_spawned.connect(_on_player_spawned)
	#SignalManager.pcam_find_player.connect(_on_find_player_pcam)
	
#func _on_player_spawned(player: Node) -> void:
	#pcam.set_follow_target(player)
	#print("spawn signal activated")
#
#func _on_find_player_pcam(target_player: Node) -> void:
	#pcam.set_follow_target(target_player)
	#select_this_pcam()
	#print("find player signal activated")
#
#func select_this_pcam() -> void:
	#if host == null or pcam == null:
		#push_warning("Host or Pcam missing")
		#return
#
	#host._pcam_removed_from_scene(pcam)
