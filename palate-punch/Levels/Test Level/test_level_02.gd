extends Node3D

@onready var pcam = %PhantomCamera3D
@onready var phost = %PhantomCameraHost
@onready var player : CharacterBody3D


func _ready() -> void:
	pcam.set_follow_target(player)
	
