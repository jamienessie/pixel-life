extends Control

## On-screen button that fires an Input action OR synthesizes a keystroke
## (for menu hotkeys handled by raw keycode in scene_router._unhandled_input).
## Set either `action` OR `synth_keycode`, not both.

@export var action: StringName = &""
@export var synth_keycode: int = 0
@export var label_text: String = ""

var _pressed := false
var _label: Label = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if _label == null:
		_label = Label.new()
		_label.text = label_text
		_label.add_theme_color_override("font_color", Palette.UI_TEXT_ON_DARK)
		_label.add_theme_font_size_override("font_size", 14)
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_label.anchor_right = 1.0
		_label.anchor_bottom = 1.0
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_label)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_press()
		else:
			_release()
		accept_event()
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_press()
			else:
				_release()
			accept_event()

func _press() -> void:
	if _pressed:
		return
	_pressed = true
	if action != &"":
		Input.action_press(action)
	elif synth_keycode != 0:
		var ev := InputEventKey.new()
		ev.pressed = true
		ev.physical_keycode = synth_keycode
		ev.keycode = synth_keycode
		Input.parse_input_event(ev)
	queue_redraw()

func _release() -> void:
	if not _pressed:
		return
	_pressed = false
	if action != &"":
		Input.action_release(action)
	elif synth_keycode != 0:
		var ev := InputEventKey.new()
		ev.pressed = false
		ev.physical_keycode = synth_keycode
		ev.keycode = synth_keycode
		Input.parse_input_event(ev)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_EXIT_TREE and _pressed:
		_release()

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var fill := Color(0, 0, 0, 0.45)
	var border := Palette.BRAND_CREAM
	if _pressed:
		fill = Color(Palette.SUN_GOLD.r, Palette.SUN_GOLD.g, Palette.SUN_GOLD.b, 0.65)
	draw_rect(rect, fill, true)
	draw_rect(rect, border, false, 2.0)
