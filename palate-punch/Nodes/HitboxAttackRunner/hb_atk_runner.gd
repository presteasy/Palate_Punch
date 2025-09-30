extends Node3D
class_name HitboxATKRunner

@export var framedata = Node
@onready var atk_list = %ATKList


@onready var punch = atk_list.atk_resources[atk_list.player_atks.PUNCH_01]

func PUNCH_01():
	if framedata.frame == punch.frame_start:
		Global.player.create_hitbox(punch.owner_type, punch.radius, punch.height, punch.depth, punch.damage, punch.angle, punch.base_kb, punch.kb_scaling, punch.duration, punch.type, punch.points, punch.angle_flipper, punch.hitlag)
	if framedata.frame >= punch.frame_end:
		return true
		
