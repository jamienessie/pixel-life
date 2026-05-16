extends CanvasLayer

# PaintingMinigame (RAI-38) — color-match rhythm: a sequence of 5 colors
# appears in order; the player presses the matching arrow key in time.
# Number of correct presses → score (0..1) → painting quality + fame bonus.

const SEQUENCE_LEN := 5
const STEP_SECONDS := 1.2

# Each step maps an arrow direction to a swatch color.
const STEPS := [
	{"action": "MOVE_UP",    "color": Color(0.95, 0.30, 0.30)},
	{"action": "MOVE_RIGHT", "color": Color(0.30, 0.85, 0.45)},
	{"action": "MOVE_DOWN",  "color": Color(0.30, 0.55, 0.95)},
	{"action": "MOVE_LEFT",  "color": Color(0.95, 0.80, 0.25)},
]

@onready var _swatch: ColorRect = $Panel/Swatch
@onready var _prompt: Label = $Panel/PromptLabel
@onready var _status: Label = $Panel/Status
@onready var _result: Label = $Panel/ResultLabel
@onready var _close_btn: Button = $Panel/CloseButton

var _sequence: Array = []
var _step_idx: int = 0
var _hits: int = 0
var _step_t: float = 0.0
var _consumed_this_step: bool = false
var _done: bool = false

func _ready() -> void:
	TimeManager.pause_time()
	_sequence.clear()
	for i in SEQUENCE_LEN:
		_sequence.append(STEPS[randi() % STEPS.size()])
	_step_idx = 0
	_hits = 0
	_consumed_this_step = false
	_done = false
	_close_btn.pressed.connect(_close)
	_close_btn.hide()
	_result.text = ""
	_status.text = "Hit the matching arrow when the swatch lights up."
	_show_current_step()

func _exit_tree() -> void:
	TimeManager.resume_time()

func _process(delta: float) -> void:
	if _done:
		return
	_step_t += delta
	if _step_t >= STEP_SECONDS:
		_step_t = 0.0
		_advance_step()

func _unhandled_input(event: InputEvent) -> void:
	if _done:
		return
	if _consumed_this_step:
		return
	var step = _sequence[_step_idx]
	if event.is_action_pressed(step.action):
		get_viewport().set_input_as_handled()
		_consumed_this_step = true
		_hits += 1
		_swatch.modulate = Color(1.5, 1.5, 1.5, 1)

func _advance_step() -> void:
	_consumed_this_step = false
	_step_idx += 1
	_swatch.modulate = Color(1, 1, 1, 1)
	if _step_idx >= _sequence.size():
		_resolve()
		return
	_show_current_step()

func _show_current_step() -> void:
	var step = _sequence[_step_idx]
	_swatch.color = step.color
	_prompt.text = "Press: %s   (%d / %d)" % [step.action.replace("MOVE_", "").capitalize(), _step_idx + 1, SEQUENCE_LEN]

func _resolve() -> void:
	_done = true
	var quality: float = float(_hits) / float(SEQUENCE_LEN)
	var painting_id := preload("res://scripts/interactables/easel.gd").random_painting_id()
	InventoryManager.add(painting_id, 1)
	EventBus.item_acquired.emit(painting_id, 1)
	# Fame bonus for painter career; reuse JobManager fame field if currently painter.
	if JobManager.current_job == "painter":
		JobManager.fame += quality
	# Bonus money if quality is high enough to "sell on the spot" — keep simple: just inventory item.
	_result.text = "Painted a %s. Quality %d%%." % [_pretty(painting_id), int(quality * 100.0)]
	_close_btn.show()
	_status.text = "Done."

func _pretty(item_id: String) -> String:
	return item_id.replace("painting_", "").replace("_", " ")

func _close() -> void:
	queue_free()
