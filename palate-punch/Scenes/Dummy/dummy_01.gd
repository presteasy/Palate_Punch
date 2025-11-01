extends CharacterBody3D

#@export var id : int
@export var character_type: String = "enemy"
@export var weight: int
@export var percentage: float
var selfState

@onready var GroundL = %GroundL
@onready var GroundR = %GroundR
@onready var state_label = %StateLabel
@onready var percent_label = %Percent
@onready var framedata = %FrameData
@onready var statemachine = %StateMachine
@onready var anim = %AnimationPlayer



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
var hit_pause = 0
var hit_pause_dur = 0
var temp_pos = Vector3.ZERO
var temp_vel = Vector3.ZERO

func _ready() -> void:
	SignalManager.hit_landed.connect(_on_hit_landed)
	
func _physics_process(delta):
	selfState = state_label.text
	%Frames.text = str(framedata.frame)
	percent_label.text = str(percentage)
	

func _on_hit_landed() -> void:
	print("hit landed")
	
func play_animation(animation_name):
	anim.play(animation_name)
	

func _hit_pause(delta):
	if hit_pause < hit_pause_dur:
		self.position = temp_pos
		hit_pause += floor((1 * delta) * 60)
	else:
		if temp_vel != Vector3.ZERO:
			self.velocity.x = temp_vel.x
			self.velocity.y = temp_vel.y
			temp_vel = Vector3.ZERO
		hit_pause_dur = 0
		hit_pause = 0
