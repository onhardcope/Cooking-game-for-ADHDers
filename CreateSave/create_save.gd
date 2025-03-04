extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


 # Replace with function body.


func _on_level_select_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://LEVELS.tscn")
	 # Replace with function body.


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu/main_menu.tscn") # Replace with function body.


func _on_play_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Kitchen/kitchen.tscn")
