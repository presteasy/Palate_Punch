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
		if event.is_action_pressed("jump_1"):
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
	await get_tree().create_timer(0.5).timeout
	InputHandler.set_input_mode(InputHandler.InputMode.GAMEPLAY)
	
	


func _on_restart_button_pressed() -> void:
	Global.game_controller.restart_level_and_respawn()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
