extends AnimatedSprite2D


signal item_released

var mouse_dragged: bool = false
var revert_position: Vector2 = Vector2.ZERO


func move_with_cursor():
	if mouse_dragged:
		global_position = get_global_mouse_position()
		

func _process(delta: float) -> void:
	move_with_cursor()
	

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if (event.is_pressed()):
			mouse_dragged = true
		elif (event.is_released()):
			mouse_dragged = false
			emit_signal("item_released")
			
