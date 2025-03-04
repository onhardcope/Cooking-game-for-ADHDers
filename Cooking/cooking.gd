extends Node2D

@onready var recipe_book_sprite: Sprite2D = %"RecipeBookSprite"


func _on_show_recipe_button_toggled(toggled_on: bool) -> void:
	if (toggled_on):
		recipe_book_sprite.visible = true
	else:
		recipe_book_sprite.visible = false


func _on_countertop_mouse_detect_area_entered() -> void:
	var eye_image: Image = Image.load_from_file("res://Assets/Cooking/zoom_in_to_countertop_new.png")
	Input.set_custom_mouse_cursor(eye_image, Input.CURSOR_ARROW, Vector2(37.5, 37.5))

func _on_countertop_mouse_detect_area_exited() -> void:
	Input.set_custom_mouse_cursor(null)
	


func _on_stove_mouse_detect_area_entered() -> void:
	var fire_image: Image = Image.load_from_file("res://Assets/Cooking/zoom_in_to_stove_cursor_new.png")
	Input.set_custom_mouse_cursor(fire_image, Input.CURSOR_ARROW, Vector2(37.5, 45))

func _on_stove_mouse_detect_area_exited() -> void:
	Input.set_custom_mouse_cursor(null)



func _on_sink_mouse_detect_area_entered() -> void:
	var water_drop_image: Image = Image.load_from_file("res://Assets/Cooking/zoom_in_to_sink_cursor_new.png")
	Input.set_custom_mouse_cursor(water_drop_image, Input.CURSOR_ARROW, Vector2(37.5, 45))
	
func _on_sink_mouse_detect_area_exited() -> void:
	Input.set_custom_mouse_cursor(null)
