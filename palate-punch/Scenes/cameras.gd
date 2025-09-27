extends Node3D

@onready var pcam = %PhantomCamera3D
@onready var host = %PhantomCameraHost
@onready var anchor = %CamAnchor


func _ready() -> void:
	SignalManager.pcam_find_player.connect(_on_find_player_pcam)
	
func _on_find_player_pcam(target_player: Node) -> void:
	pcam.set_look_at_target(target_player)
