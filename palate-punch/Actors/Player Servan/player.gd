class_name Player
extends CharacterBody3D

@export var inv : Inventory
@export var statemachine : StateMachine

@onready var GroundL = get_node('Raycasts/GroundL')
@onready var GroundR = get_node('Raycasts/GroundR')
@onready var anim = %AnimationPlayer
@onready var state_label = %StateLabel
@onready var sprite = %Sprite
@onready var graphics: Node3D = %Graphics
@onready var sprite_pivot: Node3D = %SpritePivot
@onready var framedata = %FrameData
@onready var hurtbox = %HurtBox
@onready var crouch_hurtbox = %CrouchHurtBox
@onready var hitbox_man = %HitboxManager

@export var speed = 14
@export var fall_acceleration = 75
var target_velocity = Vector3.ZERO

#Global Variables
@export var id : int
@export var character_type: String = "player"
var current_direction: int = 1
var self_state



#KnockBack
var hdecay
var vdecay
var knockback
var hitstun
var connected: bool

#Grounded Variables
@export_group("Grounded Movement")
@export var run_speed = 10
@export var walk_speed = 4
@export var crawl_speed = 4
@export var dash_speed = 16
@export var dash_duration = 10
@export var roll_distance = 10
@export var roll_speed = 20
var run_threshold = 0.5
var movement_damper = 1.0
var can_run = true
var run_cooldown = 0.2
var is_crouching: bool = false


#Aerial Variables
@export_group("Aerial Movement")
@export var jump_force = 10
@export var max_jump_force = 16
@export var double_jump_force = 14
@export var max_air_speed = 6
@export var air_accel = 5
@export var fall_speed = 0.7
@export var falling_speed = 18
@export var max_fall_speed = 28
@export var traction = 120
@export var air_dodge_speed = 500
@export var special_jump_force = 700
@export var max_jumps = 1
var jump_squat = 3
var air_jump = 0
var fastfall = false
var dash_jump_limit = 10

#Hitbox

#Temporary Variables
var hit_pause = 0
var hit_pause_dur = 0
var temp_pos = Vector3.ZERO
var temp_vel = Vector3.ZERO

func _enter_tree() -> void:
	add_to_group("player")


func _ready() -> void:
	Global.player = self

	
	
func _physics_process(delta):
	self_state = state_label.text
	%Frames.text = str(framedata.frame)
	


func turn(direction: bool) -> void:
	if direction:
		current_direction = -1
		#LedgeGrabF.rotation_degrees.z = -90
		#LedgeGrabB.rotation_degrees.z = 90
	else:
		current_direction = 1
		#LedgeGrabF.rotation_degrees.z = 90
		#LedgeGrabB.rotation_degrees.z = -90
	graphics.rotation.y = PI if current_direction == -1 else 0.0
	if sprite_pivot.has_method("set_facing_dir"):
		sprite_pivot.set_facing_dir(current_direction)
	#sprite.set_flip_h(direction)
	hitbox_man.apply_dir_of_parent()
		
		

func get_facing_dir() -> int:
	return current_direction
	
func _set_hurtbox_active(shape: CollisionShape3D, active: bool) -> void:
	if shape == null:
		return
	shape.set_deferred("disabled", not active)

func use_stand_hurtbox() -> void:
	call_deferred("_swap_hurtbox", hurtbox)
	
func use_crouch_hurtbox() -> void:
	call_deferred("_swap_hurtbox", crouch_hurtbox)

func _swap_hurtbox(target: CollisionShape3D) -> void:
	_set_hurtbox_active(hurtbox, false)
	_set_hurtbox_active(crouch_hurtbox, false)
	_set_hurtbox_active(target, true)

func switch_to_crouch_hurtbox(is_crouching: bool):
	hurtbox.disabled = is_crouching
	crouch_hurtbox.disabled = !is_crouching


func reset_jumps() -> void:
	air_jump = max_jumps

func play_animation(animation_name):
	anim.play(animation_name)

func collect(item):
	inv.insert(item)
