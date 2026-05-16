extends Control

# ToastWidget — short-lived HUD notifications for key life events.

const DURATION := 3.0

@onready var _label: Label = $Label

var _tween: Tween = null

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.marriage_completed.connect(_on_marriage)
	EventBus.child_born.connect(_on_child_born)
	EventBus.player_died.connect(_on_player_died)
	EventBus.job_assigned.connect(_on_job_assigned)
	EventBus.shift_ended.connect(_on_shift_ended)

func show_text(text: String) -> void:
	_label.text = text
	visible = true
	modulate.a = 1.0
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_interval(DURATION - 0.5)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	_tween.tween_callback(func(): visible = false)

func _on_marriage(npc_id: String) -> void:
	show_text("Married to %s!" % npc_id.capitalize())

func _on_child_born(child_id: String) -> void:
	show_text("A child is born: %s" % child_id)

func _on_player_died(cause: String) -> void:
	show_text("Character died (%s)" % cause)

func _on_job_assigned(job_id: String) -> void:
	show_text("Job: %s — %s" % [job_id.capitalize(), JobManager.current_title()])

func _on_shift_ended(payout: int, perf: float) -> void:
	show_text("Shift complete: +%d  (perf %.0f%%)" % [payout, perf * 100.0])
