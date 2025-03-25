extends Node2D

signal item_entered_working_area

@onready var sugar_bottle_sprite: AnimatedSprite2D = %"SugarBottle"
@onready var milk_bottle_sprite: AnimatedSprite2D = %"MilkBottle"
@onready var coffee_powder_bottle_sprite: AnimatedSprite2D = %"CoffeePowderBottle"
@onready var coffee_mug_sprite: AnimatedSprite2D = %"CoffeeMug"
@onready var boiling_pot_sprite: AnimatedSprite2D = %"BoilingPot"
@onready var tablespoon_sprite: AnimatedSprite2D = %"Tablespoon"

@onready var ingredient_sprite_list: Array[AnimatedSprite2D]
@onready var utensil_sprite_list: Array[AnimatedSprite2D]

var mouse_dragged: bool = false
