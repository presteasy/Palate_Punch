extends Node3D

@onready var pcam = %PhantomCamera3D
@onready var phost = %PhantomCameraHost


func _ready() -> void:
	SignalManager.player_spawned.connect(_on_player_spawned)
	
func _on_player_spawned(player: Node) -> void:
	pcam.set_follow_target(player)
	print("spawn signal activated")
		
	
