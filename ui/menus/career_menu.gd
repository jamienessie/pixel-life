extends Control

const _reg_job_data := preload("res://resources/job_data.gd")
const _reg_career_track_data := preload("res://resources/career_track_data.gd")

const JOB_IDS := ["cashier", "farmer", "painter", "doctor"]

@onready var _list: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/ListContainer
@onready var _status_label: Label = $Panel/MarginContainer/VBoxContainer/StatusLabel
@onready var _close_button: Button = $Panel/MarginContainer/VBoxContainer/CloseButton

var _is_open := false

func _ready() -> void:
	visible = false
	if _close_button != null:
		_close_button.pressed.connect(close)
	EventBus.job_assigned.connect(_on_job_changed)
	EventBus.shift_ended.connect(_on_shift_ended)

func open() -> void:
	_is_open = true
	visible = true
	_refresh()

func close() -> void:
	_is_open = false
	visible = false

func toggle() -> void:
	if _is_open:
		close()
	else:
		open()

func is_open() -> bool:
	return _is_open

func _on_job_changed(_id: String) -> void:
	if _is_open:
		_refresh()

func _on_shift_ended(_payout: int, _perf: float) -> void:
	if _is_open:
		_refresh()

func _refresh() -> void:
	for child in _list.get_children():
		child.queue_free()

	for job_id in JOB_IDS:
		var job: JobData = load("res://data/jobs/%s.tres" % job_id)
		if job == null:
			continue

		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 28)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label := Label.new()
		name_label.text = "%s  (%d/shift, %s)" % [job.name, job.base_pay_per_shift, job.category]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)

		var btn := Button.new()
		if job_id == JobManager.current_job:
			btn.text = JobManager.current_title() + " (L%d)" % (JobManager.career_level + 1)
			btn.disabled = true
		else:
			btn.text = "Apply"
			btn.pressed.connect(func(): _apply(job_id))
		row.add_child(btn)

		_list.add_child(row)

	if _status_label != null:
		if JobManager.current_job == "":
			_status_label.text = "Unemployed."
		else:
			_status_label.text = "Job: %s  •  Title: %s  •  Pay: %d  •  Perf: %.2f  •  Shifts: %d" % [
				JobManager.current_job,
				JobManager.current_title(),
				JobManager.current_pay(),
				JobManager.performance_avg,
				JobManager.shifts_completed,
			]

func _apply(job_id: String) -> void:
	var ok := JobManager.apply_for(job_id)
	if not ok:
		if _status_label != null:
			_status_label.text = "Cannot apply (education required?)"
	_refresh()
