extends Node

const MINUTES_PER_DAY := 1440
const DAYS_PER_SEASON := 28
const REAL_SECONDS_PER_GAME_MINUTE := 0.625

var minute := 0
var hour := 6
var day := 1
var season := "spring"
var year := 1

var _elapsed := 0.0
var _paused := false
var _time_scale := 1.0

func _process(delta: float) -> void:
	if _paused:
		return
	_elapsed += delta * _time_scale
	while _elapsed >= REAL_SECONDS_PER_GAME_MINUTE:
		_elapsed -= REAL_SECONDS_PER_GAME_MINUTE
		_advance_minute()

func _advance_minute() -> void:
	minute += 1
	EventBus.minute_passed.emit(minute)
	if minute >= 60:
		minute = 0
		hour += 1
		EventBus.hour_passed.emit(hour)
		if hour >= 24:
			hour = 0
			_advance_day()

func _advance_day() -> void:
	day += 1
	if day > DAYS_PER_SEASON:
		day = 1
		_advance_season()
	EventBus.day_passed.emit(day, season, year)

func _advance_season() -> void:
	var seasons := ["spring", "summer", "autumn", "winter"]
	var idx := seasons.find(season)
	idx = (idx + 1) % seasons.size()
	season = seasons[idx]
	if idx == 0:
		year += 1
		EventBus.year_passed.emit(year)
	EventBus.season_changed.emit(season)

func is_paused() -> bool:
	return _paused

func pause_time() -> void:
	_paused = true

func resume_time() -> void:
	_paused = false

func set_time_scale(scale: float) -> void:
	_time_scale = scale

func advance_to_next_morning() -> void:
	hour = 6
	minute = 0
	_advance_day()

func serialize() -> Dictionary:
	return {
		"minute": minute,
		"hour": hour,
		"day": day,
		"season": season,
		"year": year,
	}

func deserialize(data: Dictionary) -> void:
	minute = data.get("minute", 0)
	hour = data.get("hour", 6)
	day = data.get("day", 1)
	season = data.get("season", "spring")
	year = data.get("year", 1)
