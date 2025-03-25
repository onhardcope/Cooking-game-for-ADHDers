extends Node2D

@onready var inventory_list: ItemList = %"InventoryList"

@onready var highlight_area_rect: Sprite2D = %"HighlightAreaRect"

@onready var sugar_bottle_sprite: AnimatedSprite2D = %"SugarBottle"
@onready var milk_bottle_sprite: AnimatedSprite2D = %"MilkBottle"
@onready var coffee_powder_bottle_sprite: AnimatedSprite2D = %"CoffeePowderBottle"
@onready var coffee_mug_sprite: AnimatedSprite2D = %"CoffeeMug"
@onready var boiling_pot_sprite: AnimatedSprite2D = %"BoilingPot"
@onready var tablespoon_sprite: AnimatedSprite2D = %"Tablespoon"

@onready var working_area: Area2D = %"WorkingArea"
@onready var inventory_list_area: Area2D = %"InventoryListArea"

@onready var item_dict: Dictionary = {
	"Sugar" : sugar_bottle_sprite,
	"Milk bottle" : milk_bottle_sprite,
	"Coffee" : coffee_powder_bottle_sprite,
	"Coffee mug" : coffee_mug_sprite,
	"Boiling pot" : boiling_pot_sprite,
	"Tablespoon" : tablespoon_sprite
}

@onready var area_dict: Dictionary = {
	
}

@onready var inventory_item_image_dict: Dictionary = {
	"Sugar" : Image.load_from_file("res://Assets/Countertop/Inventory list textures/sugar_bottle.png"),
	"Milk bottle" : Image.load_from_file("res://Assets/Countertop/Inventory list textures/milk_bottle.png"),
	"Coffee" : Image.load_from_file("res://Assets/Countertop/Inventory list textures/coffee_bottle.png"),
	"Coffee mug" : Image.load_from_file("res://Assets/Kitchen/Utensils and Others/coffee_mug.png"),
	"Boiling pot" : Image.load_from_file("res://Assets/Kitchen/Utensils and Others/boiling_pot.png"),
	"Tablespoon" : Image.load_from_file("res://Assets/Kitchen/Utensils and Others/tablespoon.png")
}

var selected_item_name: String = ""
var selected_item_idx: int = -1
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

		selected_item_idx = index
		
		inventory_list.remove_item(index)
		
		selected_item_sprite.global_position = get_global_mouse_position()
		selected_item_sprite.visible = true



func _on_item_released() -> void:
	selected_item_name = ""
	var entered_area_name: String = ""
