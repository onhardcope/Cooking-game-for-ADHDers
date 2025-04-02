extends Node2D

signal interaction_error(error_string: String)

@onready var inventory_list: ItemList = %"InventoryList"
@onready var recipe_list: Sprite2D = %"RecipeBookSprite"

@onready var highlight_area_rect: Sprite2D = %"HighlightAreaRect"

@onready var sugar_bottle_sprite: AnimatedSprite2D = %"SugarBottle"
@onready var milk_bottle_sprite: AnimatedSprite2D = %"MilkBottle"
@onready var coffee_powder_bottle_sprite: AnimatedSprite2D = %"CoffeePowderBottle"
@onready var coffee_mug_sprite: AnimatedSprite2D = %"CoffeeMug"
@onready var boiling_pot_sprite: AnimatedSprite2D = %"BoilingPot"
@onready var tablespoon_sprite: AnimatedSprite2D = %"Tablespoon"

@onready var interaction_hint_label: Label = %"InteractionHintLabel"

@onready var item_dict: Dictionary = {
	"Sugar" : sugar_bottle_sprite,
	"Milk bottle" : milk_bottle_sprite,
	"Coffee" : coffee_powder_bottle_sprite,
	"Coffee mug" : coffee_mug_sprite,
	"Boiling pot" : boiling_pot_sprite,
	"Tablespoon" : tablespoon_sprite
}

@onready var inventory_item_image_dict: Dictionary = {
	"Sugar" : Image.load_from_file("res://Assets/Countertop/Inventory list textures/sugar_bottle.png"),
	"Milk bottle" : Image.load_from_file("res://Assets/Countertop/Inventory list textures/milk_bottle.png"),
	"Coffee" : Image.load_from_file("res://Assets/Countertop/Inventory list textures/coffee_bottle.png"),
	"Coffee mug" : Image.load_from_file("res://Assets/Kitchen/Utensils and Others/coffee_mug.png"),
	"Boiling pot" : Image.load_from_file("res://Assets/Kitchen/Utensils and Others/boiling_pot.png"),
	"Tablespoon" : Image.load_from_file("res://Assets/Kitchen/Utensils and Others/tablespoon.png")
}

@onready var selected_item_interaction_dict: Dictionary = {
	"Sugar" : [],
	"Milk bottle" : [["Boiling pot", 0, 0, 1, 1, 0], ["Boiling pot", 1, 1, 1, 1, -6]],
	"Coffee" : [],
	"Coffee mug" : [],
	"Boiling pot" : [["Coffee mug", 1, 3, 0, 4, 0]],
	"Tablespoon" : [["Sugar", 0, 0, 1, 0, 0], ["Sugar", 1, 0, 0, 0, 0], ["Sugar", 2, 0, 2, 0, -1],
					["Coffee", 0, 0, 2, 0, 0], ["Coffee", 2, 0, 0, 0, 0], ["Coffee", 1, 0, 1, 0, -2],
					["Coffee mug", 1, 0, 0, 1, 0], ["Coffee mug", 2, 0, 0, 2, 0], ["Coffee mug", 1, 1, 1, 1, -3], ["Coffee mug", 2, 2, 2, 2, -4], 
					["Coffee mug", 1, 2, 0, 3, 0], ["Coffee mug", 2, 1, 0, 3, 0], ["Coffee mug", 1, 3, 1, 3, -5], ["Coffee mug", 2, 3, 2, 3, -5]]
}

var countertop_visible_nodes: Array = []
var stove_visible_nodes: Array = []


var selected_item_name: String = ""
var selected_item_index: int = -1
var selected_item_revert_position: Vector2 = Vector2.ZERO
var item_selected_from_inventory: bool = false


func _on_show_inventory_list_button_toggled(toggled_on: bool) -> void:
	inventory_list.visible = toggled_on
		


func _on_inventory_list_item_selected(index: int) -> void:
	if (not selected_item_name):
		item_selected_from_inventory = true
		inventory_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
		selected_item_name = inventory_list.get_item_text(index)
		
		var selected_item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
		var selected_item_current_frame: int = selected_item_sprite.frame
		var cursor_image: Texture2D = selected_item_sprite.sprite_frames.get_frame_texture("default", selected_item_current_frame)
		
		selected_item_index = index
		
		inventory_list.remove_item(index)
		
		Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, Vector2(cursor_image.get_width()/2, cursor_image.get_height()/2))


func _on_working_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT):
		if (selected_item_name):
			inventory_list.mouse_filter = Control.MOUSE_FILTER_STOP
			var selected_item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
			selected_item_sprite.global_position = get_global_mouse_position()
			selected_item_sprite.visible = true
			selected_item_sprite.add_to_group("countertop")
			Input.set_custom_mouse_cursor(null)
			selected_item_name = ""
			selected_item_index = -1
			highlight_area_rect.set_instance_shader_parameter("enabled", false)
			item_selected_from_inventory = false


func get_interaction_result(placed_item_name: String) -> Array:
	var selected_item_interaction_list: Array = selected_item_interaction_dict[selected_item_name]
	
	var selected_item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
	var placed_item_sprite: AnimatedSprite2D = item_dict[placed_item_name]
	
	var selected_item_current_frame: int = selected_item_sprite.frame
	var selected_item_new_frame: int = selected_item_current_frame
	
	var placed_item_current_frame: int = placed_item_sprite.frame
	var placed_item_new_frame: int = placed_item_current_frame
	
	var error_code: int = 0
	var interacts: bool = false
	
	for specific_interaction_list: Array in selected_item_interaction_list:
		if ((placed_item_name == specific_interaction_list[0]) and (selected_item_current_frame == specific_interaction_list[1]) and (placed_item_current_frame == specific_interaction_list[2])):
			selected_item_new_frame = specific_interaction_list[3]
			placed_item_new_frame = specific_interaction_list[4]
			error_code = specific_interaction_list[5]
			interacts = true
			break
	
	return [selected_item_new_frame, placed_item_new_frame, error_code, interacts]

func show_interaction_error_hint(error_code) -> void:
	var hint_text: String = "HINT:\n"
	match(error_code):
		-1:
			hint_text += "Tablespoon already filled with coffee powder."
		-2:
			hint_text += "Tablespoon already filled with sugar."
		-3:
			hint_text += "Coffee mug already contains needed sugar."
		-4:
			hint_text += "Coffee mug already contains needed coffee powder."
		-5:
			hint_text += "Coffee mug already contains needed sugar and coffee powder"
		-6:
			hint_text += "Boiling pot already contains needed milk"
	interaction_hint_label.text = hint_text
	interaction_hint_label.fade_out()
	

func _on_placed_item_area_input_event(viewport: Node, event: InputEvent, shape_idx: int, placed_item_name: String) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
		if (not selected_item_name):
			var selected_item_sprite: AnimatedSprite2D = item_dict[placed_item_name]
			var selected_item_current_frame: int = selected_item_sprite.frame
			var cursor_image: Texture2D = selected_item_sprite.sprite_frames.get_frame_texture("default", selected_item_current_frame)
			var relative_cursor_position: Vector2 = Vector2(cursor_image.get_width()/2, cursor_image.get_height()/2)
			Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, relative_cursor_position)
			selected_item_sprite.visible = false
			
			selected_item_name = placed_item_name
			selected_item_revert_position = selected_item_sprite.global_position
			
			highlight_area_rect.set_instance_shader_parameter("enabled", true)
			
	elif (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT):
		if (selected_item_name):
			var placed_item_sprite: AnimatedSprite2D = item_dict[placed_item_name]
			var selected_item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
			
			var interaction_result_list: Array = get_interaction_result(placed_item_name)
			
			var selected_item_new_frame: int = interaction_result_list[0]
			var placed_item_new_frame: int = interaction_result_list[1]
			var error_code: int = interaction_result_list[2]
			
			if (error_code == 0):
				var cursor_image: Texture2D = selected_item_sprite.sprite_frames.get_frame_texture("default", selected_item_new_frame)
				var relative_cursor_position: Vector2 = Vector2(cursor_image.get_width()/2, cursor_image.get_height()/2)
				Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, relative_cursor_position)
				
				selected_item_sprite.set_frame_and_progress(selected_item_new_frame, selected_item_new_frame)
				
				placed_item_sprite.set_frame_and_progress(placed_item_new_frame, placed_item_new_frame)
			else:
				show_interaction_error_hint(error_code)
			
			
func _on_placed_item_area_mouse_entered(placed_item_name: String) -> void:
	if (selected_item_name):
		var placed_item_sprite: AnimatedSprite2D = item_dict[placed_item_name]
		var interacts_flag: int = get_interaction_result(placed_item_name)[3]
		if (interacts_flag):
			placed_item_sprite.set_instance_shader_parameter("enabled", true)
			
func _on_placed_item_area_mouse_exited(placed_item_name: String) -> void:
	var placed_item_sprite: AnimatedSprite2D = item_dict[placed_item_name]
	placed_item_sprite.set_instance_shader_parameter("enabled", false)

func _on_background_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT):
		if (selected_item_name):
			var item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
			
			if (not item_selected_from_inventory):
				item_sprite.global_position = selected_item_revert_position
				item_sprite.visible = true
			else:
				var item_image: Image = inventory_item_image_dict[selected_item_name]
				var item_texture: ImageTexture = ImageTexture.create_from_image(item_image)
			
				inventory_list.add_item(selected_item_name, item_texture)
				
				item_selected_from_inventory = false
				
				inventory_list.mouse_filter = Control.MOUSE_FILTER_STOP

			Input.set_custom_mouse_cursor(null)
			
			selected_item_name = ""
			


func _on_inventory_list_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT):
		if (selected_item_name):
			var item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
			var item_image: Image = inventory_item_image_dict[selected_item_name]
			var item_texture: ImageTexture = ImageTexture.create_from_image(item_image)
			
			inventory_list.add_item(selected_item_name, item_texture)
			
			item_sprite.visible = false
			if item_sprite.is_in_group("countertop"):
				item_sprite.remove_from_group("countertop")
				
			Input.set_custom_mouse_cursor(null)
			selected_item_name = ""
			selected_item_index = -1
			
			if (item_selected_from_inventory):
				inventory_list.mouse_filter = Control.MOUSE_FILTER_STOP
			
			item_selected_from_inventory = false


func _on_working_area_mouse_entered() -> void:
	if (selected_item_name):
		highlight_area_rect.set_instance_shader_parameter("enabled", true)

func _on_working_area_mouse_exited() -> void:
	highlight_area_rect.set_instance_shader_parameter("enabled", false)


func _on_go_to_stove_button_pressed() -> void:
	var countertop_nodes_list: Array = get_tree().get_nodes_in_group("countertop")
	var stove_nodes_list : Array = get_tree().get_nodes_in_group("stove")
	for node in countertop_nodes_list:
		node.visible = false
	for node in stove_nodes_list:
		node.visible = true
	

func _on_go_to_countertop_button_pressed() -> void:
	var countertop_nodes_list: Array = get_tree().get_nodes_in_group("countertop")
	var stove_nodes_list : Array = get_tree().get_nodes_in_group("stove")
	for node in countertop_nodes_list:
		node.visible = true
	for node in stove_nodes_list:
		node.visible = false


func _on_show_recipe_button_toggled(toggled_on: bool) -> void:
	recipe_list.visible = toggled_on
	inventory_list.mouse_filter = Control.MOUSE_FILTER_IGNORE if toggled_on else Control.MOUSE_FILTER_STOP
