extends Node2D

#variables for each component sprite
#component means cupboards and fridge
@onready var fridge_sprite: AnimatedSprite2D = %"Fridge"
@onready var top_left_sprite: AnimatedSprite2D = %"TopLeft"
@onready var top_right_sprite: AnimatedSprite2D = %"TopRight"
@onready var top_middle_sprite: AnimatedSprite2D = %"TopMiddle"
@onready var bottom_left_sprite: AnimatedSprite2D = %"BottomLeft"
@onready var bottom_right_sprite: AnimatedSprite2D = %"BottomRight"
@onready var bottom_middle_3_sprite: AnimatedSprite2D = %"BottomMiddle3"
@onready var bottom_middle_2_sprite: AnimatedSprite2D = %"BottomMiddle2"
@onready var bottom_middle_1_sprite: AnimatedSprite2D = %"BottomMiddle1"

#array of all component sprites
#used for easily accessing sprite using array index
@onready var all_sprites: Array = [fridge_sprite, 
								top_left_sprite, top_right_sprite, top_middle_sprite,
								bottom_left_sprite, bottom_right_sprite,
								bottom_middle_3_sprite, bottom_middle_2_sprite, bottom_middle_1_sprite]

#variable for selection_list
@onready var selection_list: ItemList = %"SelectionList"

#variable for recipe book sprite
@onready var recipe_book_sprite: Sprite2D = %"RecipeBookSprite"

#variables for proceed and error labels
#these are for the message to be shown after checking if selected items are correct or not
@onready var error_label: Label = %"ErrorLabel"
@onready var proceed_label: Label = %"ProceedLabel"

#array of names of correct ingredients selection
#we check if our selected ingredients are correct using this array
var valid_selection_list: Array[String] = ["Coffee", "Milk bottle", "Sugar", "Coffee mug", "Boiling pot", "Tablespoon"]

#index (in all_sprites array) of the component that is open currently
#only one component can be open at a time. thats why we can use this technique.
#-1 if all components are closed
var open_component_index: int = -1

#opening and closing components when clicked
#showing and hiding component lists
func _on_component_input_event(viewport: Node, event: InputEvent, shape_idx: int, component_sprite_index: int) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		var component_sprite: AnimatedSprite2D = all_sprites[component_sprite_index]
		
		var component_list: ItemList = component_sprite.get_child(1)
		
		if (component_sprite_index == open_component_index):
			component_sprite.set_frame_and_progress(0, 0)
			component_list.visible = false
			open_component_index = -1
			
		else:
			if (open_component_index >= 0):
				var open_component_sprite: AnimatedSprite2D = all_sprites[open_component_index]
				var open_component_list: ItemList = open_component_sprite.get_child(1)
				open_component_sprite.set_frame_and_progress(0, 0)
				open_component_list.visible = false
				open_component_sprite.set_instance_shader_parameter("enabled", false)
				
			component_sprite.set_frame_and_progress(1, 1)
			component_list.visible = true
			open_component_index = component_sprite_index
			
			component_sprite.set_instance_shader_parameter("enabled", true)
			

func _on_component_area_mouse_entered(component_sprite_index: int) -> void:
	var component_sprite: AnimatedSprite2D = all_sprites[component_sprite_index]
	component_sprite.set_instance_shader_parameter("enabled", true)
	
func _on_component_area_mouse_exited(component_sprite_index: int) -> void:
	var component_sprite: AnimatedSprite2D = all_sprites[component_sprite_index]
	component_sprite.set_instance_shader_parameter("enabled", false)
	

#showing and hiding selection list
#done when first top right button is toggled
func _on_show_selection_list_button_toggled(toggled_on: bool) -> void:
	selection_list.visible = toggled_on

#showing and hiding recipe book
#done when second top right button is toggled
func _on_show_recipe_button_toggled(toggled_on: bool) -> void:
	recipe_book_sprite.visible = toggled_on
	for sprite in all_sprites:
		var sprite_area: Area2D = sprite.get_child(0)
		sprite_area.input_pickable = not toggled_on

#transfer item: FROM open component TO selection list
func _on_component_list_item_selected(index: int) -> void:
	var open_component_list: ItemList = all_sprites[open_component_index].get_child(1)
	var ingredient_name: String = open_component_list.get_item_text(index)
	var ingredient_icon: Texture2D = open_component_list.get_item_icon(index)
	open_component_list.remove_item(index)
	selection_list.add_item(ingredient_name, ingredient_icon)

#transfer item: FROM selection list TO open component ONLY IF a component is open
func _on_selection_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if (open_component_index >= 0):
		var open_component_list: ItemList = all_sprites[open_component_index].get_child(1)
		var ingredient_name: String = selection_list.get_item_text(index)
		var ingredient_icon: Texture2D = selection_list.get_item_icon(index)
		selection_list.remove_item(index)
		open_component_list.add_item(ingredient_name, ingredient_icon)

#checking if selection is correct
#two error conditions: unnecessary item found, necessary item not found
#provide hints for these two errors
func _on_check_selection_button_pressed() -> void:
	var unnecessary_item_found: bool = false
	var items_to_remove: Array[String]
	
	var necessary_item_not_found: bool = false
	var items_to_add: Array[String]
	
	var error_text: String = "TRY AGAIN!"
	
	var selected_item_names: Array[String]
	var temp_valid_selection_list: Array[String] = valid_selection_list.duplicate()
	
	var no_of_items: int = selection_list.item_count
	
	for index: int in range(no_of_items):
		var item_name: String = selection_list.get_item_text(index)
		selected_item_names.append(item_name)
	
	for item_name: String in selected_item_names:
		if item_name not in temp_valid_selection_list:
			unnecessary_item_found = true
			items_to_remove.append(item_name)
		else:
			var valid_item_index: int = temp_valid_selection_list.find(item_name)
			temp_valid_selection_list.remove_at(valid_item_index)
	
	if not temp_valid_selection_list.is_empty():
		necessary_item_not_found = true
		items_to_add = temp_valid_selection_list.duplicate()
	elif unnecessary_item_found:
		pass
	else:
		proceed_label.visible = true
		
		await get_tree().create_timer(3).timeout 
		
		get_tree().change_scene_to_file("res://CookingZoomedIn/cooking_zoomed_in.tscn")
		return
	
	var wait_time: int = 0
	if necessary_item_not_found:
		error_text += "\nHint: Some necessary item(s) not found. Add them first!"
		wait_time += 3
	if unnecessary_item_found:
		error_text += "\nHint: Some unnecessary item(s) found. Remove them first!"
		wait_time += 3
	
	error_label.text = error_text
	error_label.visible = true
	
	await get_tree().create_timer(wait_time).timeout 
	
	error_label.visible = false
	
