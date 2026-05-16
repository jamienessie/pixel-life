extends Node

# JobManager — applies for jobs, schedules shifts, resolves payouts (M9).
# Connects EventBus.hour_passed to auto-start shifts on shift days.

const _reg_job_data := preload("res://resources/job_data.gd")
const _reg_career_track_data := preload("res://resources/career_track_data.gd")

const JOB_PATH := "res://data/jobs/%s.tres"
const CAREER_PATH := "res://data/careers/%s.tres"
const SHIFT_DC := 12 # base difficulty class for skill_check resolution

var current_job: String = ""
var career_level: int = 0
var performance_avg: float = 0.0
var fame: float = 0.0
var shifts_completed: int = 0

var _in_shift: bool = false
var _shift_data: JobData = null

func _ready() -> void:
	EventBus.hour_passed.connect(_on_hour_passed)

func apply_for(job_id: String) -> bool:
	var job := _load_job(job_id)
	if job == null:
		return false
	if not _meets_education(job):
		return false
	current_job = job_id
	career_level = 0
	performance_avg = 0.0
	shifts_completed = 0
	EventBus.job_assigned.emit(job_id)
	return true

func quit() -> void:
	current_job = ""
	career_level = 0
	performance_avg = 0.0
	shifts_completed = 0
	_in_shift = false
	_shift_data = null

func start_shift() -> void:
	if current_job == "" or _in_shift:
		return
	_shift_data = _load_job(current_job)
	if _shift_data == null:
		return
	_in_shift = true
	# Teleport player to workplace.
	if SceneRouter.get_player() != null and _shift_data.workplace_zone != GameState.current_zone:
		SceneRouter.goto_zone(_shift_data.workplace_zone, _shift_data.workplace_marker)
	EventBus.shift_started.emit()

func end_shift(payout: int = -1, performance: float = -1.0) -> void:
	if not _in_shift:
		return
	var job := _shift_data if _shift_data != null else _load_job(current_job)
	if job == null:
		_in_shift = false
		return
	var perf: float = performance
	var pay: int = payout
	if perf < 0.0 or pay < 0:
		var rolled := _resolve(job)
		pay = rolled["pay"]
		perf = rolled["performance"]
	EconomyManager.add_money(pay)
	# Running average over completed shifts.
	performance_avg = (performance_avg * shifts_completed + perf) / float(shifts_completed + 1)
	shifts_completed += 1
	if job.category == "creative" and perf >= 0.5:
		fame += perf
	_in_shift = false
	_shift_data = null
	EventBus.shift_ended.emit(pay, perf)
	try_promote()

func try_promote() -> bool:
	var job := _load_job(current_job)
	if job == null:
		return false
	var track := _load_career(job.career_track)
	if track == null:
		return false
	var next_idx := career_level + 1
	if next_idx >= track.levels.size():
		return false
	var next_level: Dictionary = track.levels[next_idx]
	var shifts_req: int = int(next_level.get("shifts_required", 0))
	var perf_req: float = float(next_level.get("performance_required", 0.0))
	if shifts_completed >= shifts_req and performance_avg >= perf_req:
		career_level = next_idx
		shifts_completed = 0
		EventBus.job_assigned.emit(current_job)
		EventBus.job_level_up.emit(current_job, career_level)
		# Visual + audio juice (juice/audio bridges silently no-op if FxPlayer/AudioManager missing).
		if Engine.has_singleton("FxPlayer") or get_node_or_null("/root/FxPlayer") != null:
			FxPlayer.play_level_up_at_player()
		AudioManager.play_sfx("sfx_level_up")
		return true
	return false

func current_pay() -> int:
	var job := _load_job(current_job)
	if job == null:
		return 0
	var track := _load_career(job.career_track)
	var mult: float = 1.0
	if track != null and career_level < track.levels.size():
		mult = float(track.levels[career_level].get("pay_multiplier", 1.0))
	return int(round(job.base_pay_per_shift * mult))

func current_title() -> String:
	var job := _load_job(current_job)
	if job == null:
		return ""
	var track := _load_career(job.career_track)
	if track != null and career_level < track.levels.size():
		return String(track.levels[career_level].get("title", job.name))
	return job.name

func is_in_shift() -> bool:
	return _in_shift

func _resolve(job: JobData) -> Dictionary:
	var base := job.base_pay_per_shift
	var track := _load_career(job.career_track)
	var mult: float = 1.0
	if track != null and career_level < track.levels.size():
		mult = float(track.levels[career_level].get("pay_multiplier", 1.0))
	var furniture_perf_bonus: float = 0.0
	if Engine.has_singleton("HouseManager") or get_node_or_null("/root/HouseManager") != null:
		match job.category:
			"creative":
				furniture_perf_bonus = HouseManager.get_effect("painter_perf_bonus")
			"self_employed":
				furniture_perf_bonus = HouseManager.get_effect("farmer_perf_bonus")
	match job.resolution:
		"skill_check":
			var roll := randi_range(1, 20) + career_level
			var pay_mod: float = 0.5
			var perf: float = 0.25
			if roll >= SHIFT_DC + 8:
				pay_mod = 1.5
				perf = 0.95
			elif roll >= SHIFT_DC:
				pay_mod = 1.0
				perf = 0.7
			return {"pay": int(round(base * mult * pay_mod)), "performance": clampf(perf + furniture_perf_bonus, 0.0, 1.0)}
		_:
			var jitter := 0.9 + randf() * 0.3 # 0.9 .. 1.2
			var perf2 := clampf(jitter - 0.4 + furniture_perf_bonus, 0.0, 1.0)
			return {"pay": int(round(base * mult * jitter)), "performance": perf2}

func _on_hour_passed(hour: int) -> void:
	if current_job == "" or _in_shift:
		return
	var job := _load_job(current_job)
	if job == null:
		return
	# Day-of-week from TimeManager.day (1-based within season). 0 = Mon ... 6 = Sun.
	var dow: int = (TimeManager.day - 1) % 7
	if not job.shift_days.has(dow):
		return
	if hour == job.shift_hours.x:
		start_shift()
		# Auto-end at shift end hour for `auto`/`skill_check` resolutions (no minigame yet).
		var duration: int = max(1, job.shift_hours.y - job.shift_hours.x)
		# Advance time fast inside shift: just immediately end this turn since
		# the player is teleported away. The shift represents the next `duration` hours,
		# but for the v1 implementation we resolve instantly to keep flow tight.
		end_shift()

func _meets_education(job: JobData) -> bool:
	if job.requires_education == "":
		return true
	var profile = GameState.active_character
	if profile == null:
		return false
	if profile.get("unlocks") == null:
		return false
	return bool(profile.unlocks.get(job.requires_education, false))

func _load_job(job_id: String) -> JobData:
	if job_id == "":
		return null
	return load(JOB_PATH % job_id)

func _load_career(career_id: String) -> CareerTrackData:
	if career_id == "":
		return null
	return load(CAREER_PATH % career_id)

func serialize() -> Dictionary:
	return {
		"current_job": current_job,
		"career_level": career_level,
		"performance_avg": performance_avg,
		"fame": fame,
		"shifts_completed": shifts_completed,
	}

func deserialize(data: Dictionary) -> void:
	current_job = data.get("current_job", "")
	career_level = data.get("career_level", 0)
	performance_avg = data.get("performance_avg", 0.0)
	fame = data.get("fame", 0.0)
	shifts_completed = data.get("shifts_completed", 0)
	_in_shift = false
	_shift_data = null
