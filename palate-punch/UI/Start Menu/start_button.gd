extends Button


func _on_pressed() -> void:
	Global.game_controller.change_gui_to_3d("res://Levels/Test Level/TestLevel_01.tscn", true, false)
	Global.game_controller.spawn_player()
	InputHandler.game_mode = true
