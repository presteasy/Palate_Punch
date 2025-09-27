extends Node3D


#func _ready() -> void:
	#SignalManager.player_spawned.connect(_on_player_spawned)
	#find_player_pcam()

#func _on_player_spawned(player: Node) -> void:
	#pcam.set_follow_target(player)
	#print("spawn signal activated")
		
		
#
#
#func _exit_tree() -> void:
	#if pcam.has_method("set_follow_target"):
		#pcam.set_follow_target(null)
#
#
#func _on_find_player_pcam(target_player: Node) -> void:
	#pcam.set_follow_target(target_player)
	#print("find player signal activated")
#
#func find_player_pcam() -> void:
	#var t = get_tree().get_first_node_in_group("player")
	#if t:
		#await t.ready
		#_assign_target(t)
	#else:
		#if not get_tree().node_added.is_connected(_on_node_added):
			#get_tree().node_added.connect(_on_node_added)
		#print("waiting for node in group:", "player")
			#
#func _on_node_added(n: Node) -> void:
	#if n.is_in_group("player"):
		#get_tree().node_added.disconnect(_on_node_added)
		#_assign_target(n)
		#
#func _assign_target(target: Node) -> void:
	#await get_tree().process_frame
	#pcam.set_follow_target(target)
