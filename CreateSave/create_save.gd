extends Node2D

func _on_level_select_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://LEVELS.tscn")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu/main_menu.tscn") 

func _on_play_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Kitchen/kitchen.tscn")
