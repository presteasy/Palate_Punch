extends CharacterBody3D

@export var character_type: String = "enemy"
@export var weight: int
@export var percentage: float

@onready var GroundL = %GroundL
@onready var GroundR = %GroundR


@export_group("Aerial Movement")
@export var max_air_speed = 6
@export var fall_speed = 0.7
@export var falling_speed = 18
@export var max_fall_speed = 28
@export var traction = 120
var jump_squat = 3

var hdecay
var vdecay
var knockback
var hitstun
var connected: bool

func _ready() -> void:
	SignalManager.hit_landed.connect(_on_hit_landed)
	
func _on_hit_landed() -> void:
	print("hit landed")
