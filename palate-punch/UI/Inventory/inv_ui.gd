extends Control

@onready var parent = get_parent()

@onready var inv: Inventory = preload("res://Resources/Items/Player Inventory/playerinventory.tres")
@onready var slots: Array = %GridContainer.get_children()

func _ready() -> void:
	inv.update.connect(update_slots)
	update_slots()
	close()
	
func update_slots() -> void:
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])	
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory_%s" % parent.id):
		if !InputHandler.player_inv_open:
			open()
		else:
			close()
			
	if InputHandler.is_ui_mode() && InputHandler.player_inv_open == true:
		if Input.is_action_just_pressed("inventory_%s" % parent.id):
			print("inv closed")
			close()

		
func open() -> void:
	InputHandler.player_inv_open = true
	InputHandler.inv_paused = true
	InputHandler.game_mode = false
	visible = true
	
func close() -> void:
	InputHandler.player_inv_open = false
	InputHandler.inv_paused = false
	InputHandler.game_mode = true
	visible = false
