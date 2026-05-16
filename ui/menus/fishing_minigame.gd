extends CanvasLayer

# FishingMinigame (RAI-37) — timing-bar style: an oscillating cursor moves
# along a horizontal bar; the player presses INTERACT to lock it in. The
# closer the lock is to the target zone, the higher the success_quality
# passed into FishingSystem.roll_catch. Three attempts per cast.

const ATTEMPTS := 3
const OSC_SECONDS := 1.2          # full sweep (left-to-right-to-left)
const TARGET_WIDTH := 0.18        # 0..1 of the bar (centered)
const BAR_WIDTH_PX := 240

@onready var _bar: ColorRect = $Panel/BarBg
@onready var _target: ColorRect = $Panel/BarBg/Target
@onready var _cursor: ColorRect = $Panel/BarBg/Cursor
@onready var _status: Label = $Panel/Status
@onready var _attempts_label: Label = $Panel/AttemptsLabel
@onready var _result_label: Label = $Panel/ResultLabel
@onready var _close_button: Button = $Panel/CloseButton

var _t: float = 0.0
var _attempts_left: int = ATTEMPTS
var _best_quality: float = 0.0
var _done: bool = false

func _ready() -> void:
	TimeManager.pause_time()
	_attempts_left = ATTEMPTS
	_best_quality = 0.0
	_done = false
	_close_button.pressed.connect(_close)
	_close_button.hide()
	_result_label.text = ""
	_status.text = "Press INTERACT to lock in the cursor near the green zone."
	_update_attempts()
	_position_target()

func _exit_tree() -> void:
	TimeManager.resume_time()

func _process(delta: float) -> void:
	if _done:
		return
	_t = fmod(_t + delta, OSC_SECONDS)
	var phase: float = _t / OSC_SECONDS
	# triangle wave 0->1->0
	var x: float = phase * 2.0 if phase < 0.5 else (1.0 - (phase - 0.5) * 2.0)
	_cursor.position.x = x * (BAR_WIDTH_PX - _cursor.size.x)

func _unhandled_input(event: InputEvent) -> void:
	if _done:
		return
	if event.is_action_pressed(InputActions.INTERACT):
		get_viewport().set_input_as_handled()
		_lock_in()

func _lock_in() -> void:
	# Distance from cursor center to target center, normalized to 0..1 across the bar.
	var cursor_center_x: float = _cursor.position.x + _cursor.size.x * 0.5
	var target_center_x: float = _target.position.x + _target.size.x * 0.5
	var max_dist: float = BAR_WIDTH_PX
	var dist_norm: float = clampf(abs(cursor_center_x - target_center_x) / max_dist, 0.0, 1.0)
	var quality: float = clampf(1.0 - dist_norm * 3.0, 0.0, 1.0)
	if quality > _best_quality:
		_best_quality = quality
	_attempts_left -= 1
	_update_attempts()
	_position_target()
	if _attempts_left <= 0:
		_resolve()

func _resolve() -> void:
	_done = true
	var fish := FishingSystem.roll_catch(TimeManager.season, TimeManager.hour, _best_quality)
	if fish == null:
		_result_label.text = "Nothing's biting…"
	else:
		var qty := 1
		InventoryManager.add(fish.item_id, qty)
		EventBus.item_acquired.emit(fish.item_id, qty)
		_result_label.text = "Caught a %s! (quality %d%%)" % [fish.name, int(_best_quality * 100.0)]
	_close_button.show()
	_status.text = "Done."

func _position_target() -> void:
	var t_w: float = BAR_WIDTH_PX * TARGET_WIDTH
	_target.size.x = t_w
	var max_x: float = BAR_WIDTH_PX - t_w
	_target.position.x = randf() * max_x

func _update_attempts() -> void:
	_attempts_label.text = "Attempts: %d" % _attempts_left

func _close() -> void:
	queue_free()
