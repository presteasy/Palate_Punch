extends Node
class_name FollowPlayer

@export var follow_speed: float = 5.0

var parent: CharacterBody3D
var target: Node3D = null

func _ready() -> void:
	parent = get_parent()
	find_player()

func _physics_process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		find_player()
		return
	
	follow_target()

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		for player in players:
			if player != parent:
				target = player
				return

func follow_target():
	var direction = (target.global_position - parent.global_position).normalized()
	
	parent.velocity.x = direction.x * follow_speed
	# // For Flying Characters:
	#parent.velocity.y = direction.y * follow_speed 
	
	#if parent.has_method("turn"):
		#parent.turn(direction.x < 0)
	
	
	
