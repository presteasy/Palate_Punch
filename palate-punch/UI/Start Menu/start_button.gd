extends Button

@onready var start_button = %StartButton

func _ready() -> void:
	start_button.has_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if start_button.has_focus():
			_on_pressed()

func _on_pressed() -> void:
	Global.game_controller.change_gui_to_3d("res://Levels/Test Level/TestLevel_01.tscn", true, false)
	Global.game_controller.spawn_player()
	await get_tree().create_timer(1.0).timeout
	InputHandler.game_mode = true
