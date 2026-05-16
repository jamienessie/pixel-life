extends Control

## FadeTransition — reusable full-screen fade in/out effect.
## Instantiated by SceneRouter into the persistent UI layer.

@onready var _rect: ColorRect = $ColorRect

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.color = Color(0, 0, 0, 0)
	_rect.visible = false
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_out(duration: float) -> void:
	_rect.visible = true
	_rect.color = Color(0, 0, 0, 0)
	var tween := create_tween()
	tween.tween_property(_rect, "color:a", 1.0, duration)
	await tween.finished

func fade_in(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(_rect, "color:a", 0.0, duration)
	await tween.finished
	_rect.visible = false
