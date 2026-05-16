extends Control

## Floating virtual joystick. Synthesizes MOVE_* and RUN actions so the
## existing keyboard-driven player controller works unchanged on touch.

const DEAD_ZONE := 0.15
const RUN_THRESHOLD := 0.85
const RADIUS := 56.0
const PUCK_RADIUS := 22.0

var _active_touch_index := -1
var _origin := Vector2.ZERO
var _current := Vector2.ZERO
var _stick := Vector2.ZERO

var _ring_color: Color = Color(0, 0, 0, 0.35)
var _ring_border: Color = Color(1, 1, 1, 0.55)
var _puck_color: Color = Color(1, 1, 1, 0.75)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(true)
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var t := event as InputEventScreenTouch
		print("[JOYSTICK._input] touch pressed=", t.pressed, " idx=", t.index, " pos=", t.position, " rect=", get_global_rect())
	elif event is InputEventScreenDrag:
		var d := event as InputEventScreenDrag
		print("[JOYSTICK._input] drag idx=", d.index, " pos=", d.position)
	if Engine.has_singleton("Palette") or typeof(Palette) == TYPE_OBJECT:
		_ring_border = Palette.BRAND_CREAM
		_puck_color = Palette.SUN_GOLD

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		print("[JOYSTICK] gui_input touch pressed=", touch.pressed, " idx=", touch.index, " pos=", touch.position)
		if touch.pressed and _active_touch_index == -1:
			_active_touch_index = touch.index
			_origin = touch.position
			_current = touch.position
			_stick = Vector2.ZERO
			accept_event()
			queue_redraw()
		elif not touch.pressed and touch.index == _active_touch_index:
			_release()
			accept_event()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _active_touch_index:
			_current = drag.position
			var delta := _current - _origin
			var mag := delta.length()
			if mag > RADIUS:
				delta = delta * (RADIUS / mag)
				_current = _origin + delta
			_stick = delta / RADIUS
			accept_event()
			queue_redraw()
	elif event is InputEventMouseButton and OS.is_debug_build():
		# Allow mouse preview on desktop debug builds.
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed and _active_touch_index == -1:
				_active_touch_index = 0
				_origin = mb.position
				_current = mb.position
				_stick = Vector2.ZERO
				accept_event()
				queue_redraw()
			elif not mb.pressed and _active_touch_index == 0:
				_release()
				accept_event()
	elif event is InputEventMouseMotion and _active_touch_index == 0 and OS.is_debug_build():
		var mm := event as InputEventMouseMotion
		_current = mm.position
		var delta2 := _current - _origin
		var mag2 := delta2.length()
		if mag2 > RADIUS:
			delta2 = delta2 * (RADIUS / mag2)
			_current = _origin + delta2
		_stick = delta2 / RADIUS
		queue_redraw()

func _process(_delta: float) -> void:
	if _active_touch_index == -1:
		return
	var x := _stick.x
	var y := _stick.y
	# Horizontal
	if x > DEAD_ZONE:
		Input.action_press(InputActions.MOVE_RIGHT, clampf(x, 0.0, 1.0))
		Input.action_release(InputActions.MOVE_LEFT)
	elif x < -DEAD_ZONE:
		Input.action_press(InputActions.MOVE_LEFT, clampf(-x, 0.0, 1.0))
		Input.action_release(InputActions.MOVE_RIGHT)
	else:
		Input.action_release(InputActions.MOVE_LEFT)
		Input.action_release(InputActions.MOVE_RIGHT)
	# Vertical
	if y > DEAD_ZONE:
		Input.action_press(InputActions.MOVE_DOWN, clampf(y, 0.0, 1.0))
		Input.action_release(InputActions.MOVE_UP)
	elif y < -DEAD_ZONE:
		Input.action_press(InputActions.MOVE_UP, clampf(-y, 0.0, 1.0))
		Input.action_release(InputActions.MOVE_DOWN)
	else:
		Input.action_release(InputActions.MOVE_UP)
		Input.action_release(InputActions.MOVE_DOWN)
	# Run when pushed near the edge.
	if _stick.length() > RUN_THRESHOLD:
		Input.action_press(InputActions.RUN, 1.0)
	else:
		Input.action_release(InputActions.RUN)

func _release() -> void:
	_active_touch_index = -1
	_stick = Vector2.ZERO
	Input.action_release(InputActions.MOVE_LEFT)
	Input.action_release(InputActions.MOVE_RIGHT)
	Input.action_release(InputActions.MOVE_UP)
	Input.action_release(InputActions.MOVE_DOWN)
	Input.action_release(InputActions.RUN)
	queue_redraw()

func _draw() -> void:
	if _active_touch_index == -1:
		# Hint ring near bottom-left so the player sees where to touch.
		var hint_center := Vector2(size.x * 0.5, size.y * 0.5)
		draw_circle(hint_center, RADIUS, _ring_color)
		draw_arc(hint_center, RADIUS, 0.0, TAU, 32, _ring_border, 2.0)
		draw_circle(hint_center, PUCK_RADIUS, Color(_puck_color.r, _puck_color.g, _puck_color.b, 0.35))
		return
	var local_origin := _origin
	var local_current := _current
	draw_circle(local_origin, RADIUS, _ring_color)
	draw_arc(local_origin, RADIUS, 0.0, TAU, 32, _ring_border, 2.0)
	draw_circle(local_current, PUCK_RADIUS, _puck_color)
