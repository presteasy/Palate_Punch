extends Control
class_name PauseMenu

@onready var resume_button = %ResumeButton
@onready var restart_button = %RestartButton
@onready var quit_button = %QuitButton


func _ready() -> void:
	hide()
	InputHandler.connect("toggle_game_paused", _on_toggle_game_paused)

	
func _on_toggle_game_paused(is_paused : bool):
	if(is_paused):
		print("pause signal connected!")
		show()
		InputHandler.pause_open = true
		InputHandler.set_input_mode(InputHandler.InputMode.UI)
		resume_button.grab_focus()
	else:
		hide()
		InputHandler.pause_open = false
		InputHandler.game_mode = true


#
func _input(event : InputEvent):
	if InputHandler.is_ui_mode() && InputHandler.pause_open == true:
		if event.is_action_pressed("escape_%s" % Global.player.id) or event.is_action_pressed("special_%s" % Global.player.id):
			InputHandler.game_paused = !InputHandler.game_paused
		if event.is_action_pressed("jump_%s" % Global.player.id):
			if resume_button.has_focus():
				_on_resume_button_pressed()
			if restart_button.has_focus():
				_on_restart_button_pressed()
			if quit_button.has_focus():
				_on_quit_button_pressed()
			
	if InputHandler.is_gameplay_mode():
		if event.is_action_pressed("escape_%s" % Global.player.id):
			toggle_pause_menu()

func toggle_pause_menu():
	InputHandler.game_paused = true
	InputHandler.game_mode = false

	
func _on_resume_button_pressed() -> void:
	hide()
	InputHandler.game_paused = false
	
	var player_id = Global.player.id
	while Input.is_action_pressed("jump_%s" % player_id) or Input.is_action_pressed("ui_accept"):
		await get_tree().process_frame
	
	await get_tree().create_timer(1).timeout
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var input_buffer = player.get_node_or_null("%InputBuffer")
		if input_buffer:
			input_buffer.clear_all()
	

	
	InputHandler.set_input_mode(InputHandler.InputMode.GAMEPLAY)
	
	


func _on_restart_button_pressed() -> void:
	Global.game_controller.restart_level_and_respawn()
	InputHandler.set_input_mode(InputHandler.InputMode.GAMEPLAY)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
