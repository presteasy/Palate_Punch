extends Control

@onready var start_button = %StartButton
@onready var quit_button = %QuitButton

func _ready() -> void:
	InputHandler.is_ui_mode()
	start_button.grab_focus()

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#if start_button.has_focus():
			#_on_start_button_pressed()
		#if quit_button.has_focus():
			#_on_quit_button_pressed()

func _on_start_button_pressed() -> void:
	Global.game_controller.change_gui_to_3d("res://Levels/Test Level/TestLevel_01.tscn", true, false)
	if get_tree().get_nodes_in_group("player").size() == 0:
		Global.game_controller.spawn_player()
		
	var player = get_tree().get_first_node_in_group("player")
	
	while Input.is_action_pressed("jump_%s" % Global.player.id) or Input.is_action_pressed("ui_accept"):
		await get_tree().process_frame
	
	await get_tree().create_timer(0.1).timeout
	
	if player:
		var input_buffer = player.get_node_or_null("%InputBuffer")
		if input_buffer:
			input_buffer.clear_all()
	
	
	InputHandler.game_mode = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()
