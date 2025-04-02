extends Node2D

@onready var recipe_book_sprite: Sprite2D = %"RecipeBookSprite"

@onready var stove_top_sprite: AnimatedSprite2D = %"StoveTop"
@onready var countertop_sprite: AnimatedSprite2D = %"Countertop"
@onready var sink_sprite: AnimatedSprite2D = %"Sink"

@onready var all_sprites: Array[AnimatedSprite2D] = [stove_top_sprite, countertop_sprite, sink_sprite]

var eye_image: Image = Image.load_from_file("res://Assets/Cooking/zoom_in_to_countertop_new.png")
var fire_image: Image = Image.load_from_file("res://Assets/Cooking/zoom_in_to_stove_cursor_new.png")
var water_image: Image = Image.load_from_file("res://Assets/Cooking/zoom_in_to_sink_cursor_new.png")

var all_cursor_images: Array[Image] = [fire_image, eye_image, water_image]

func _on_show_recipe_button_toggled(toggled_on: bool) -> void:
	var stove_top_area: Area2D = stove_top_sprite.get_child(0)
	var countertop_area: Area2D = countertop_sprite.get_child(0)
	var sink_area: Area2D = sink_sprite.get_child(0)
	
	recipe_book_sprite.visible = toggled_on
	countertop_area.input_pickable = not toggled_on
	stove_top_area.input_pickable = not toggled_on
	sink_area.input_pickable = not toggled_on

func _on_component_area_mouse_entered(component_sprite_idx: int) -> void:
	var component_sprite: AnimatedSprite2D = all_sprites[component_sprite_idx]
	var cursor_image: Image = all_cursor_images[component_sprite_idx]
	
	component_sprite.set_instance_shader_parameter("enabled", true)
	
	Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, Vector2(37.5, 37.5))

func _on_component_area_mouse_exited(component_sprite_idx: int) -> void:
	var component_sprite: AnimatedSprite2D = all_sprites[component_sprite_idx]
	
	component_sprite.set_instance_shader_parameter("enabled", false)
	
	Input.set_custom_mouse_cursor(null)

func _on_countertop_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		get_tree().change_scene_to_file("res://Countertop/cooking_zoomed_in.tscn")
		
		Input.set_custom_mouse_cursor(null)
