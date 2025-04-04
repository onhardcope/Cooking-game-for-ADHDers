extends Node2D

@onready var inventory_list: ItemList = %"InventoryList"
@onready var recipe_book: Sprite2D = %"RecipeBookSprite"

@onready var highlight_area_rect: Sprite2D = %"HighlightAreaRect"

@onready var sugar_bottle_sprite: AnimatedSprite2D = %"SugarBottle"
@onready var milk_bottle_sprite: AnimatedSprite2D = %"MilkBottle"
@onready var coffee_powder_bottle_sprite: AnimatedSprite2D = %"CoffeePowderBottle"
@onready var coffee_mug_sprite: AnimatedSprite2D = %"CoffeeMug"
@onready var boiling_pot_sprite: AnimatedSprite2D = %"BoilingPot"
@onready var tablespoon_sprite: AnimatedSprite2D = %"Tablespoon"

@onready var countertop_interaction_hint_label: Label = %"CountertopInteractionHintLabel"
@onready var stove_interaction_hint_label: Label = %"StoveInteractionHintLabel"
@onready var knob_interaction_hint_label: Label = %"KnobInteractionHintLabel"

@onready var item_dict: Dictionary = {
	"Sugar" : sugar_bottle_sprite,
	"Milk bottle" : milk_bottle_sprite,
	"Coffee" : coffee_powder_bottle_sprite,
	"Coffee mug" : coffee_mug_sprite,
	"Boiling pot" : boiling_pot_sprite,
	"Tablespoon" : tablespoon_sprite
}

var selected_item_interaction_dict: Dictionary = {
	"Sugar" : [],
	"Milk bottle" : [["Boiling pot", 0, 0, 1, 1, 0], ["Boiling pot", 1, 1, 1, 1, -6]],
	"Coffee" : [],
	"Coffee mug" : [],
	"Boiling pot" : [["Coffee mug", 2, 3, 0, 4, 0]],
	"Tablespoon" : [["Sugar", 0, 0, 1, 0, 0], ["Sugar", 1, 0, 0, 0, 0], ["Sugar", 2, 0, 2, 0, -1],
					["Coffee", 0, 0, 2, 0, 0], ["Coffee", 2, 0, 0, 0, 0], ["Coffee", 1, 0, 1, 0, -2],
					["Coffee mug", 1, 0, 0, 1, 0], ["Coffee mug", 2, 0, 0, 2, 0], ["Coffee mug", 1, 1, 1, 1, -3], ["Coffee mug", 2, 2, 2, 2, -4], 
					["Coffee mug", 1, 2, 0, 3, 0], ["Coffee mug", 2, 1, 0, 3, 0], ["Coffee mug", 1, 3, 1, 3, -5], ["Coffee mug", 2, 3, 2, 3, -5],
					["Coffee mug", 0, 4, 0, 5, 0]]
}

var selected_item_name: String = ""
var selected_item_index: int = -1
var selected_item_revert_position: Vector2 = Vector2.ZERO
var item_selected_from_inventory: bool = false

var countertop_visible_nodes: Array = []
var stove_visible_nodes: Array = []

@onready var all_heater_sprites: Array = [%"Heater1", %"Heater2", %"Heater3", %"Heater4"]
@onready var all_zoomed_knobs: Array = [%"Knob1Zoomed", %"Knob2Zoomed", %"Knob3Zoomed", %"Knob4Zoomed"]
@onready var rotating_sprite: Sprite2D = %"RotatingSprite"

var pot_positions: Array = [Vector2(559.0, 208.0), Vector2(499.0, 560.0), Vector2(1153.0, 208.0), Vector2(1211.0, 560.0)]
var item_placed_on_heater: Array = [false, false, false, false]

var knob_zoomed: AnimatedSprite2D
var dragging_on_knob: bool = false
var valid_heat_levels: Array = [3, 4]

@onready var heating_progress_bar: ProgressBar = $BoilingPot/HeatingProgressBar
@onready var heating_timer: Timer = $BoilingPot/HeatingProgressBar/HeatingTimer
@onready var milk_pouring_area: Area2D = $BoilingPot/PouringArea
var heating_completed: bool = false

#inventory list
func _on_inventory_list_item_selected(index: int) -> void:
	if (not selected_item_name):
		item_selected_from_inventory = true
		inventory_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
		selected_item_name = inventory_list.get_item_text(index)
		
		selected_item_index = index
		inventory_list.remove_item(index)
		
		var selected_item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
		var selected_item_current_frame: int = selected_item_sprite.frame
		var cursor_image: Texture2D = selected_item_sprite.sprite_frames.get_frame_texture("default", selected_item_current_frame)
		
		var relative_cursor_position: Vector2
		if (selected_item_name != "Boiling pot"):
			relative_cursor_position = Vector2(cursor_image.get_width()/2, cursor_image.get_height()/2)
		else:
			relative_cursor_position = Vector2(199.0, 293.5)
		Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, relative_cursor_position)

func _on_inventory_list_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT):
		if (selected_item_name):
			var item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
			var item_image: Image = item_sprite.sprite_frames.get_frame_texture("default", item_sprite.frame).get_image()
			item_image.resize(150, 150)
			var item_texture: ImageTexture = ImageTexture.create_from_image(item_image)
			
			inventory_list.add_item(selected_item_name, item_texture)
			
			item_sprite.visible = false
			if item_sprite.is_in_group("countertop"):
				item_sprite.remove_from_group("countertop")
			elif item_sprite.is_in_group("stove"):
				item_sprite.remove_from_group("stove")
			
			Input.set_custom_mouse_cursor(null)
			selected_item_name = ""
			selected_item_index = -1
			
			if (item_selected_from_inventory):
				inventory_list.mouse_filter = Control.MOUSE_FILTER_STOP
			
			item_selected_from_inventory = false

#working area
func _on_working_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT):
		if (selected_item_name):
			inventory_list.mouse_filter = Control.MOUSE_FILTER_STOP
			var selected_item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
			if (selected_item_name != "Boiling pot"):
				selected_item_sprite.global_position = get_global_mouse_position()
			else:
				selected_item_sprite.global_position = get_global_mouse_position() - Vector2(-45.5, 49.0)
			selected_item_sprite.visible = true
			selected_item_sprite.add_to_group("countertop")
			Input.set_custom_mouse_cursor(null)
			selected_item_name = ""
			selected_item_index = -1
			highlight_area_rect.set_instance_shader_parameter("enabled", false)
			item_selected_from_inventory = false

func _on_working_area_mouse_entered() -> void:
	if (selected_item_name):
		highlight_area_rect.set_instance_shader_parameter("enabled", true)

func _on_working_area_mouse_exited() -> void:
	highlight_area_rect.set_instance_shader_parameter("enabled", false)

func get_interaction_result(placed_item_name: String) -> Array:
	
	
	var selected_item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
	var placed_item_sprite: AnimatedSprite2D = item_dict[placed_item_name]
	
	var selected_item_current_frame: int = selected_item_sprite.frame
	var selected_item_new_frame: int = selected_item_current_frame
	
	var placed_item_current_frame: int = placed_item_sprite.frame
	var placed_item_new_frame: int = placed_item_current_frame
	
	var error_code: int = 0
	var interacts: bool = false
	var selected_item_interaction_list: Array = selected_item_interaction_dict[selected_item_name]
	for specific_interaction_list: Array in selected_item_interaction_list:
		if ((placed_item_name == specific_interaction_list[0]) 
		and (selected_item_current_frame == specific_interaction_list[1]) 
		and (placed_item_current_frame == specific_interaction_list[2])):
			selected_item_new_frame = specific_interaction_list[3]
			placed_item_new_frame = specific_interaction_list[4]
			error_code = specific_interaction_list[5]
			interacts = true
			break
	return [selected_item_new_frame, placed_item_new_frame, error_code, interacts]

func show_interaction_error_hint(error_code: int, interaction_type: String) -> void:
	var hint_text: String = "HINT:\n"
	if (interaction_type == "countertop_interaction"):
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
				
		countertop_interaction_hint_label.text = hint_text
		countertop_interaction_hint_label.fade_out()
		
	elif (interaction_type == "stove_interaction"):
		match(error_code):
			-1:
				hint_text += "Add 1/2 bottle milk to boiling pot first."
			-2:
				hint_text += "Milk already boiled. You may place it in your inventory now."
		stove_interaction_hint_label.text = hint_text
		stove_interaction_hint_label.fade_out()
		
	elif (interaction_type == "knob_interaction"):
		match(error_code):
			-1:
				hint_text += "Milk should be heated in medium heat (level 3 or 4)"
			-2:
				hint_text += "Milk already boiled. Please turn off the heating now (level 0)"
		knob_interaction_hint_label.text = hint_text
		knob_interaction_hint_label.fade_out()

#placed item
func _on_placed_item_area_input_event(viewport: Node, event: InputEvent, shape_idx: int, placed_item_name: String) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
		if (not selected_item_name and placed_item_name == "Coffee mug" and (coffee_mug_sprite.frame == 5)):
			$GameEndLabel.visible = true
				
			inventory_list.mouse_filter = Control.MOUSE_FILTER_STOP
			$ShowRecipeButton.mouse_filter = Control.MOUSE_FILTER_STOP
			$GoToCountertopButton.mouse_filter = Control.MOUSE_FILTER_STOP
			
			await get_tree().create_timer(5).timeout
			get_tree().change_scene_to_file("res://CreateSave/create_save.tscn")
		
		elif (not selected_item_name):
			var selected_item_sprite: AnimatedSprite2D = item_dict[placed_item_name]
			var selected_item_current_frame: int = selected_item_sprite.frame
			var cursor_image: Texture2D = selected_item_sprite.sprite_frames.get_frame_texture("default", selected_item_current_frame)
			
			selected_item_name = placed_item_name
			selected_item_revert_position = selected_item_sprite.global_position
			
			var relative_cursor_position: Vector2
			if (selected_item_name != "Boiling pot"):
				relative_cursor_position = Vector2(cursor_image.get_width()/2, cursor_image.get_height()/2)
			else:
				relative_cursor_position = Vector2(199.0, 293.5)
				if ($StoveBackground.visible and (boiling_pot_sprite.global_position in pot_positions)):
					var heater_index: int = pot_positions.find(boiling_pot_sprite.global_position)
					item_placed_on_heater[heater_index] = false
					
			Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, relative_cursor_position)
			selected_item_sprite.visible = false
			
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
				var relative_cursor_position: Vector2
				if (selected_item_name != "Boiling pot"):
					relative_cursor_position = Vector2(cursor_image.get_width()/2, cursor_image.get_height()/2)
				else:
					relative_cursor_position = Vector2(199.0, 293.5)
				Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, relative_cursor_position)
				
				selected_item_sprite.set_frame_and_progress(selected_item_new_frame, selected_item_new_frame)
				
				placed_item_sprite.set_frame_and_progress(placed_item_new_frame, placed_item_new_frame)
				
				placed_item_sprite.set_instance_shader_parameter("enabled", false)
				
			else:
				show_interaction_error_hint(error_code, "countertop_interaction")

func _on_placed_item_area_mouse_entered(placed_item_name: String) -> void:
	var placed_item_sprite: AnimatedSprite2D = item_dict[placed_item_name]
	if (selected_item_name):
		var interacts_flag: int = get_interaction_result(placed_item_name)[3]
		if (interacts_flag):
			placed_item_sprite.set_instance_shader_parameter("enabled", true)
			
	elif (placed_item_name == "Coffee mug" and (coffee_mug_sprite.frame == 5)):
			placed_item_sprite.set_instance_shader_parameter("enabled", true)
			

func _on_placed_item_area_mouse_exited(placed_item_name: String) -> void:
	var placed_item_sprite: AnimatedSprite2D = item_dict[placed_item_name]
	placed_item_sprite.set_instance_shader_parameter("enabled", false)

#background
func _on_background_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT):
		if (selected_item_name):
			var item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
			
			if (item_selected_from_inventory):
				var item_image: Image = item_sprite.sprite_frames.get_frame_texture("default", item_sprite.frame).get_image()
				item_image.resize(150, 150)
				var item_texture: ImageTexture = ImageTexture.create_from_image(item_image)
			
				inventory_list.add_item(selected_item_name, item_texture)
				
				item_selected_from_inventory = false
				
				inventory_list.mouse_filter = Control.MOUSE_FILTER_STOP

			else:
				item_sprite.global_position = selected_item_revert_position
				item_sprite.visible = true

			Input.set_custom_mouse_cursor(null)
			
			selected_item_name = ""
			
			
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
	recipe_book.visible = toggled_on
	inventory_list.mouse_filter = Control.MOUSE_FILTER_IGNORE if toggled_on else Control.MOUSE_FILTER_STOP

#heater
func _on_heater_area_input_event(viewport: Node, event: InputEvent, shape_idx: int, heater_index: int) -> void:
	if (event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT):
		if (selected_item_name == "Boiling pot"):
			inventory_list.mouse_filter = Control.MOUSE_FILTER_STOP
			boiling_pot_sprite.global_position = pot_positions[heater_index]
			boiling_pot_sprite.visible = true
			boiling_pot_sprite.add_to_group("stove")
			Input.set_custom_mouse_cursor(null)
			item_placed_on_heater[heater_index] = true
			selected_item_name = ""
			selected_item_index = -1
			item_selected_from_inventory = false
			
			var heater_sprite: Sprite2D = all_heater_sprites[heater_index]
			heater_sprite.set_instance_shader_parameter("enabled", false)
			
		elif selected_item_name:
			var item_sprite: AnimatedSprite2D = item_dict[selected_item_name]
			
			if (not item_selected_from_inventory):
				item_sprite.global_position = selected_item_revert_position
				item_sprite.visible = true
			else:
				var item_image: Image = item_sprite.sprite_frames.get_frame_texture("default", item_sprite.frame).get_image()
				item_image.resize(150, 150)
				var item_texture: ImageTexture = ImageTexture.create_from_image(item_image)
				
				inventory_list.add_item(selected_item_name, item_texture)
				item_selected_from_inventory = false
				inventory_list.mouse_filter = Control.MOUSE_FILTER_STOP
			
			Input.set_custom_mouse_cursor(null)
			
			selected_item_name = ""

func _on_heater_area_mouse_entered(heater_index: int) -> void:
	if (selected_item_name == "Boiling pot"):
		var heater_sprite: Sprite2D = all_heater_sprites[heater_index]
		heater_sprite.set_instance_shader_parameter("enabled", true)

func _on_heater_area_mouse_exited(heater_index: int) -> void:
	var heater_sprite: Sprite2D = all_heater_sprites[heater_index]
	heater_sprite.set_instance_shader_parameter("enabled", false)

#knob
func _on_knob_area_input_event(viewport: Node, event: InputEvent, shape_idx: int, knob_index: int) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
		if (item_placed_on_heater[knob_index]):
			if ((boiling_pot_sprite.animation == "default") and (boiling_pot_sprite.frame == 1)
				or (boiling_pot_sprite.animation == "milk_boil") and (boiling_pot_sprite.frame == 4)):
				knob_zoomed = all_zoomed_knobs[knob_index]
				knob_zoomed.visible = true
				
				var boiling_pot_area: Area2D = boiling_pot_sprite.get_child(0)
				boiling_pot_area.input_pickable = false
				
				for heater_sprite in all_heater_sprites:
					var knob_area: Area2D = heater_sprite.get_child(1).get_child(0)
					knob_area.input_pickable = false
				
				inventory_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
				$ShowRecipeButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
				$GoToCountertopButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			elif ((boiling_pot_sprite.animation == "default") and (boiling_pot_sprite.frame == 0)):
				show_interaction_error_hint(-1, "stove_interaction")
			
			elif ((boiling_pot_sprite.animation == "default") and (boiling_pot_sprite.frame == 2)):
				show_interaction_error_hint(-2, "stove_interaction")
				

func _on_knob_area_mouse_entered(knob_index: int) -> void:
	var heater_sprite: Sprite2D = all_heater_sprites[knob_index]
	var knob_sprite: AnimatedSprite2D = heater_sprite.get_child(1)
	heater_sprite.set_instance_shader_parameter("enabled", true)
	knob_sprite.set_instance_shader_parameter("enabled", true)

func _on_knob_area_mouse_exited(knob_index: int) -> void:
	var heater_sprite: Sprite2D = all_heater_sprites[knob_index]
	var knob_sprite: AnimatedSprite2D = heater_sprite.get_child(1)
	heater_sprite.set_instance_shader_parameter("enabled", false)
	knob_sprite.set_instance_shader_parameter("enabled", false)

#zoomed knob
func _on_knob_zoomed_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
		dragging_on_knob = true
	elif (event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT):
		dragging_on_knob = false

func rotate_zoomed_knob() -> void:
	if (dragging_on_knob):
		rotating_sprite.look_at(get_global_mouse_position())
		var knob_rotation_deg: float = rotating_sprite.global_rotation_degrees
		
		var old_knob_position: int = knob_zoomed.frame
		var new_knob_position: int = 0
		
		if (-100 < knob_rotation_deg and knob_rotation_deg < -80):
			new_knob_position = 0
		elif (-120 < knob_rotation_deg and knob_rotation_deg <= -100):
			new_knob_position = 1
		elif (-139.5 < knob_rotation_deg and knob_rotation_deg <= -120):
			new_knob_position = 2
		elif (-158.5 < knob_rotation_deg and knob_rotation_deg <= -139.5):
			new_knob_position = 3
		elif (-178 < knob_rotation_deg and knob_rotation_deg <= -158.5):
			new_knob_position = 4
		elif (-180 < knob_rotation_deg and knob_rotation_deg <= -178):
			new_knob_position = 5
		elif (164 < knob_rotation_deg and knob_rotation_deg <= 180):
			new_knob_position = 5
		elif (147 < knob_rotation_deg and knob_rotation_deg <= 164):
			new_knob_position = 6
		elif (138 < knob_rotation_deg and knob_rotation_deg <= 147):
			new_knob_position = 7
		else:
			new_knob_position = old_knob_position
		
		knob_zoomed.frame = new_knob_position
	

func _on_set_heat_level_button_pressed() -> void:
	var heat_level: int = knob_zoomed.frame
	var heat_level_correct: bool = heat_level in valid_heat_levels
	
	if (heat_level_correct):
		knob_zoomed.visible = false
		
		var boiling_pot_area: Area2D = boiling_pot_sprite.get_child(0)
		boiling_pot_area.input_pickable = true
		
		for sprite in all_heater_sprites:
			var knob_area: Area2D = sprite.get_child(1).get_child(0)
			knob_area.input_pickable = true
		
		inventory_list.mouse_filter = Control.MOUSE_FILTER_STOP
		$ShowRecipeButton.mouse_filter = Control.MOUSE_FILTER_STOP
		$GoToCountertopButton.mouse_filter = Control.MOUSE_FILTER_STOP
		
		if (not heating_completed):
			start_heating()
			
		else:
			heating_progress_bar.visible = false
			boiling_pot_sprite.animation = "default"
			boiling_pot_sprite.set_frame_and_progress(2, 2)
			
			var vapours_sprite: AnimatedSprite2D = $BoilingPot/Vapours
			vapours_sprite.stop()
			vapours_sprite.visible = false
			
		
	else:
		if (not heating_completed):
			show_interaction_error_hint(-1, "knob_interaction")
		
		else:
			show_interaction_error_hint(-2, "knob_interaction")


func start_heating() -> void:
	var boiling_pot_area: Area2D = boiling_pot_sprite.get_child(0)
	boiling_pot_area.input_pickable = false
	boiling_pot_sprite.play("milk_boil", 1.0)
	heating_progress_bar.max_value = heating_timer.wait_time
	heating_timer.start()
	heating_progress_bar.visible = true
	
func _on_heating_timer_timeout() -> void:
	heating_completed = true
	var boiling_pot_area: Area2D = boiling_pot_sprite.get_child(0)
	boiling_pot_sprite.stop()
	boiling_pot_sprite.animation = "milk_boil"
	boiling_pot_sprite.set_frame_and_progress(4, 4)
	
	valid_heat_levels = [0]
	
	var vapours_sprite: AnimatedSprite2D = $BoilingPot/Vapours
	vapours_sprite.visible = true
	vapours_sprite.play("default")


func _on_pouring_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT):
		if ((selected_item_name == "Boiling pot") and heating_completed):
			var interaction_result_list: Array = get_interaction_result("Coffee mug")
			var boiling_pot_new_frame: int = interaction_result_list[0]
			var coffee_mug_new_frame: int = interaction_result_list[1]
			
			var cursor_image: Texture2D = boiling_pot_sprite.sprite_frames.get_frame_texture("default", boiling_pot_new_frame)
			var relative_cursor_position: Vector2
			relative_cursor_position = Vector2(199.0, 293.5)
			Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, relative_cursor_position)
			
			boiling_pot_sprite.set_frame_and_progress(boiling_pot_new_frame, boiling_pot_new_frame)
			
			coffee_mug_sprite.set_frame_and_progress(coffee_mug_new_frame, coffee_mug_new_frame)
			
			coffee_mug_sprite.set_instance_shader_parameter("enabled", false)
			
			
			
	
func _on_pouring_area_mouse_entered() -> void:
	if ((selected_item_name == "Boiling pot") and boiling_pot_sprite.frame == 2):
		coffee_mug_sprite.set_instance_shader_parameter("enabled", true)

func _on_pouring_area_mouse_exited() -> void:
	if ((selected_item_name == "Boiling pot") and boiling_pot_sprite.frame == 2):
		coffee_mug_sprite.set_instance_shader_parameter("enabled", false)


func _process(delta: float) -> void:
	rotate_zoomed_knob()
	heating_progress_bar.value = heating_progress_bar.max_value - heating_timer.time_left
