extends Control

@onready var start_button = %StartButton
@onready var quit_button = %QuitButton

func _ready() -> void:
	InputHandler.is_ui_mode()
	start_button.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump_1"):
		if start_button.has_focus():
			_on_start_button_pressed()
		if quit_button.has_focus():
			_on_quit_button_pressed()

func _on_start_button_pressed() -> void:
	Global.game_controller.change_gui_to_3d("res://Levels/Test Level/TestLevel_01.tscn", true, false)
	Global.game_controller.spawn_player()
	InputHandler.game_mode = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()
