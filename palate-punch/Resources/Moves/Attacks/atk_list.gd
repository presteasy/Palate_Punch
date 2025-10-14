extends Node
class_name ATKList

enum player_atks { 
	PUNCH_01, NAIR_01, NAIR_02, FAIR, BAIR, UAIR_01, UAIR_02, DAIR, F_SMASH, U_SMASH, D_SMASH
	
	
	}

var atk_resources := {
	player_atks.PUNCH_01: preload("res://Resources/Moves/Attacks/PUNCH_01/PUNCH_01.tres"),
	player_atks.NAIR_01: preload("res://Resources/Moves/Attacks/NAIR/NAIR.tres"),
	player_atks.NAIR_02: preload("res://Resources/Moves/Attacks/NAIR/NAIR02.tres"),
	player_atks.BAIR: preload("res://Resources/Moves/Attacks/BAIR/BAIR.tres"),
	player_atks.DAIR: preload("res://Resources/Moves/Attacks/DAIR/DAIR.tres"),
	player_atks.UAIR_01: preload("res://Resources/Moves/Attacks/UAIR/UAIR_01.tres"),
	player_atks.UAIR_02: preload("res://Resources/Moves/Attacks/UAIR/UAIR_02.tres"),
	player_atks.FAIR: preload("res://Resources/Moves/Attacks/FAIR/FAIR.tres")
	
}
