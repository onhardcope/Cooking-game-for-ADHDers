extends Node2D

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_new_pressed() -> void:
	get_tree().change_scene_to_file("res://CreateSave/create_save.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
