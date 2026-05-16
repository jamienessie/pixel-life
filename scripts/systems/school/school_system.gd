extends Node

# SchoolSystem (RAI-39) — alternative path to diploma/degree.
# Dialogue trigger: "school.attend" → attend()
# Each call advances time by CLASS_HOURS and grants STUDY_POINTS_PER_CLASS.

const CLASS_START_HOUR := 8
const CLASS_END_HOUR := 14
const CLASS_HOURS := CLASS_END_HOUR - CLASS_START_HOUR  # 6 hours
const STUDY_POINTS_PER_CLASS := 6.0  # ~9 classes for diploma (50 threshold)

const DIPLOMA_THRESHOLD := 50.0
const DEGREE_THRESHOLD := 150.0

func can_attend() -> bool:
	if GameState.active_character == null:
		return false
	if GameState.current_zone != "school":
		return false
	# Weekdays only (0=Mon..6=Sun).
	var dow: int = (TimeManager.day - 1) % 7
	if dow > 4:
		return false
	# Only during class hours.
	if TimeManager.hour < CLASS_START_HOUR or TimeManager.hour >= CLASS_END_HOUR:
		return false
	return true

func attend() -> bool:
	var profile = GameState.active_character
	if profile == null:
		return false
	if not can_attend():
		return false
	# Advance time straight to class end. Use existing TimeManager loop.
	var hours_left: int = CLASS_END_HOUR - TimeManager.hour
	for _i in range(hours_left * 60):
		TimeManager._advance_minute()
	NeedsManager.modify("energy", -15.0)
	NeedsManager.modify("hunger", -10.0)
	NeedsManager.modify("social", 8.0)
	profile.study_progress += STUDY_POINTS_PER_CLASS
	if not profile.unlocks.get("diploma", false) and profile.study_progress >= DIPLOMA_THRESHOLD:
		profile.unlocks["diploma"] = true
	if not profile.unlocks.get("degree", false) and profile.study_progress >= DEGREE_THRESHOLD:
		profile.unlocks["degree"] = true
	return true
