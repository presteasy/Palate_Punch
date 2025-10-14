extends Node3D
class_name HitboxATKRunner

@export var framedata = Node
@onready var atk_list = %ATKList



func PUNCH_01():
	var punch = atk_list.atk_resources[atk_list.player_atks.PUNCH_01]
	if framedata.frame == punch.frame_start:
		Global.player.create_hitbox(punch.owner_type, punch.radius, punch.height, punch.depth, punch.damage, punch.angle, punch.base_kb, punch.kb_scaling, punch.duration, punch.type, punch.points, punch.angle_flipper, punch.hitlag)
	if framedata.frame >= punch.frame_end:
		return true

func NAIR():
	var nair_01 = atk_list.atk_resources[atk_list.player_atks.NAIR_01]
	var nair_02 = atk_list.atk_resources[atk_list.player_atks.NAIR_02]
	if framedata.frame == 3:
		Global.player.create_hitbox(nair_01.owner_type, nair_01.radius, nair_01.height, nair_01.depth, nair_01.damage, nair_01.angle, nair_01.base_kb, nair_01.kb_scaling, nair_01.duration, nair_01.type, nair_01.points, nair_01.angle_flipper, nair_01.hitlag)
	if framedata.frame == 18:
		Global.player.create_hitbox(nair_02.owner_type, nair_02.radius, nair_02.height, nair_02.depth, nair_02.damage, nair_02.angle, nair_02.base_kb, nair_02.kb_scaling, nair_02.duration, nair_02.type, nair_02.points, nair_02.angle_flipper, nair_02.hitlag)
	if framedata.frame == 30:
		return true
		
func BAIR():
	var bair = atk_list.atk_resources[atk_list.player_atks.BAIR]
	if framedata.frame == bair.frame_start:
		Global.player.create_hitbox(bair.owner_type, bair.radius, bair.height, bair.depth, bair.damage, bair.angle, bair.base_kb, bair.kb_scaling, bair.duration, bair.type, bair.points, bair.angle_flipper, bair.hitlag)
	if framedata.frame == bair.frame_end:
		return true

func DAIR():
	var dair = atk_list.atk_resources[atk_list.player_atks.DAIR]
	if framedata.frame == dair.frame_start:
		Global.player.create_hitbox(dair.owner_type, dair.radius, dair.height, dair.depth, dair.damage, dair.angle, dair.base_kb, dair.kb_scaling, dair.duration, dair.type, dair.points, dair.angle_flipper, dair.hitlag)
	if framedata.frame == dair.frame_end:
		return true
		
func FAIR():
	var fair = atk_list.atk_resources[atk_list.player_atks.FAIR]
	if framedata.frame == fair.frame_start:
		Global.player.create_hitbox(fair.owner_type, fair.radius, fair.height, fair.depth, fair.damage, fair.angle, fair.base_kb, fair.kb_scaling, fair.duration, fair.type, fair.points, fair.angle_flipper, fair.hitlag)
	if framedata.frame == fair.frame_end:
		return true
		
func UAIR():
	var uair_01 = atk_list.atk_resources[atk_list.player_atks.UAIR_01]
	var uair_02 = atk_list.atk_resources[atk_list.player_atks.UAIR_02]
	if framedata.frame == uair_01.frame_start:
		Global.player.create_hitbox(uair_01.owner_type, uair_01.radius, uair_01.height, uair_01.depth, uair_01.damage, uair_01.angle, uair_01.base_kb, uair_01.kb_scaling, uair_01.duration, uair_01.type, uair_01.points, uair_01.angle_flipper, uair_01.hitlag)
	if framedata.frame == uair_02.frame_start:
		Global.player.create_hitbox(uair_02.owner_type, uair_02.radius, uair_02.height, uair_02.depth, uair_02.damage, uair_02.angle, uair_02.base_kb, uair_02.kb_scaling, uair_02.duration, uair_02.type, uair_02.points, uair_02.angle_flipper, uair_02.hitlag)
	if framedata.frame == uair_02.frame_end:
		return true
		
		
		
