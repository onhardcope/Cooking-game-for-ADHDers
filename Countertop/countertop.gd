extends Node2D

signal interaction_error(error_string: String)

@onready var inventory_list: ItemList = %"InventoryList"

@onready var highlight_area_rect: Sprite2D = %"HighlightAreaRect"

@onready var sugar_bottle_sprite: AnimatedSprite2D = %"SugarBottle"
@onready var milk_bottle_sprite: AnimatedSprite2D = %"MilkBottle"
@onready var coffee_powder_bottle_sprite: AnimatedSprite2D = %"CoffeePowderBottle"
@onready var coffee_mug_sprite: AnimatedSprite2D = %"CoffeeMug"
@onready var boiling_pot_sprite: AnimatedSprite2D = %"BoilingPot"
@onready var tablespoon_sprite: AnimatedSprite2D = %"Tablespoon"

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
	"Milk bottle" : [[0, "Coffee mug", 2, 1],],
	"Coffee" : [],
	"Coffee mug" : [],
	"Boiling pot" : [],
	"Tablespoon" : [[0, "Sugar", 0, 1, 0], [0, "Coffee", 0, 2, 0], [1, "Coffee mug", 0, 0, 1], [1, "Coffee mug", 2, 0, 2], [2, "Coffee mug", 1, 0, 3], [2, "Coffee mug", 0, 0, 3]]
}

@onready var placed_item_interaction_dict: Dictionary = {
	"Sugar" : [],
	"Milk bottle" : [],
	"Coffee" : [],
	"Coffee mug" : [[0, "Tablespoon", 1, 1], [0, "Tablespoon", 2, 2], [0, "Milk bottle", 0, 3]],
	"Boiling pot" : [],
	"Tablespoon" : []
}

var selected_item_name: String = ""
var selected_item_index: int = -1
var selected_item_revert_position: Vector2 = Vector2.ZERO
var item_selected_from_inventory: bool = false


func _on_show_inventory_list_button_toggled(toggled_on: bool) -> void:
	if (toggled_on):
		inventory_list.visible = true
	else:
		inventory_list.visible = false


func _on_inventory_list_item_selected(index: int) -> void:
	if (not selected_item_name):
		item_selected_from_inventory = true
		inventory_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
		selected_item_name = inventory_list.get_item_text(index)
		
		var selected_item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
		var cursor_image: Texture2D = selected_item_sprite.sprite_frames.get_frame_texture("default", 0)
		
		selected_item_index = index
		
		inventory_list.remove_item(index)
		
		Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, Vector2(cursor_image.get_width()/2, cursor_image.get_height()/2))


func _on_working_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT):
		if (selected_item_name):
			inventory_list.mouse_filter = Control.MOUSE_FILTER_STOP
			
			var selected_item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
			selected_item_sprite.visible = true
			
			selected_item_sprite.global_position = get_global_mouse_position()
			Input.set_custom_mouse_cursor(null)
			
			selected_item_name = ""
			selected_item_index = -1
			
			highlight_area_rect.set_instance_shader_parameter("enabled", false)
			
			item_selected_from_inventory = false

func get_selected_item_frame_after_interaction(placed_item_name: String) -> Array:
	var selected_item_interaction_list: Array = selected_item_interaction_dict[selected_item_name]
	
	var selected_item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
	var placed_item_sprite: AnimatedSprite2D = item_dict[placed_item_name]
	
	var selected_item_current_frame: int = selected_item_sprite.frame
	var selected_item_new_frame: int = selected_item_current_frame
	
	var placed_item_current_frame: int = placed_item_sprite.frame
	var placed_item_new_frame: int = placed_item_current_frame
	
	for specific_interaction_list: Array in selected_item_interaction_list:
		if ((selected_item_current_frame == specific_interaction_list[0]) and (placed_item_name == specific_interaction_list[1]) and (placed_item_current_frame == specific_interaction_list[2])):
			selected_item_new_frame = specific_interaction_list[3]
			placed_item_new_frame = specific_interaction_list[4]
			
			break
	
	return [selected_item_new_frame, placed_item_new_frame]
'
func get_placed_item_name_after_interaction(placed_item_name: String) -> int:
	var selected_item_interaction_list: Array[String] = selected_item_interaction_dict[selected_item_name]
	var placed_item_interaction_list: Array[String] = placed_item_interaction_dict[placed_item_name]
	var selected_item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
	var selected_item_current_frame_index: int = selected_item_sprite.frame
	'

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
			
			var selected_item_new_frame: int = get_selected_item_frame_after_interaction(placed_item_name)[0]
			var placed_item_new_frame: int = get_selected_item_frame_after_interaction(placed_item_name)[1]
			
			var cursor_image: Texture2D = selected_item_sprite.sprite_frames.get_frame_texture("default", selected_item_new_frame)
			var relative_cursor_position: Vector2 = Vector2(cursor_image.get_width()/2, cursor_image.get_height()/2)
			Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, relative_cursor_position)
			
			selected_item_sprite.set_frame_and_progress(selected_item_new_frame, selected_item_new_frame)
			
			placed_item_sprite.set_frame_and_progress(placed_item_new_frame, placed_item_new_frame)
			#var placed_item_new_frame: int = get_placed_item_frame_after_interaction(placed_item_name)
			
			

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
