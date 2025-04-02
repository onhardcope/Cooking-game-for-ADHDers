extends Node2D

'
these are signal-connected functions
signal connection is signified by the green symbol on the left side of the function
click on the symbol to know which node is sending the signal that triggers the function
'

#get_tree() returns the scene tree
#scene tree is just the flow of the game during runtime
#we can change which scene is currently being executed by using change_scene_to_file()
func _on_new_pressed() -> void:
	get_tree().change_scene_to_file("res://CreateSave/create_save.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
