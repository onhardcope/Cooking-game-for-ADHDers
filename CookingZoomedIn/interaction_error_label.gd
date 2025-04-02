extends Label

@export var fade_out_duration: float
var fade_tween: Tween

func _ready() -> void:
	modulate.a = 0

func fade_out():
	if (fade_tween):
		fade_tween.kill()
		fade_tween = null
	
	modulate.a = 1.0
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0, fade_out_duration).set_trans(Tween.TRANS_EXPO)
