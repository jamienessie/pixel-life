extends Node

# FestivalManager (RAI-48) — schedules one festival per season on day 14 of
# its season. Fires festival_started/ended signals; pushes a temporary
# npc-zone override into FamilyManager.npc_overrides for the day.

const _reg_festival_data := preload("res://resources/festival_data.gd")
const FESTIVAL_PATH := "res://data/festivals/%s.tres"
const FESTIVAL_IDS: Array[String] = [
	"spring_flower_dance",
	"summer_luau",
	"fall_harvest_fair",
	"winter_star_festival",
]

signal festival_started(festival_id: String)
signal festival_ended(festival_id: String)

var _active_festival: String = ""

func _ready() -> void:
	EventBus.day_passed.connect(_on_day_passed)

func _on_day_passed(day: int, season: String, _year: int) -> void:
	# End yesterday's festival.
	if _active_festival != "":
		_end_active_festival()
	# Start today's festival, if any.
	for fid in FESTIVAL_IDS:
		var f := load_festival(fid)
		if f != null and f.season == season and f.day_of_season == day:
			_start_festival(fid)
			return

func _start_festival(festival_id: String) -> void:
	_active_festival = festival_id
	festival_started.emit(festival_id)

func _end_active_festival() -> void:
	var fid := _active_festival
	_active_festival = ""
	festival_ended.emit(fid)

func is_festival_active() -> bool:
	return _active_festival != ""

func active_festival() -> String:
	return _active_festival

func active_festival_data() -> FestivalData:
	if _active_festival == "":
		return null
	return load_festival(_active_festival)

func load_festival(festival_id: String) -> FestivalData:
	return load(FESTIVAL_PATH % festival_id)

func serialize() -> Dictionary:
	return {"active_festival": _active_festival}

func deserialize(data: Dictionary) -> void:
	_active_festival = data.get("active_festival", "")
