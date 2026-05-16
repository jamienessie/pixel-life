extends GutTest

var tm: Node
var bus: Node

func before_each() -> void:
	tm = get_node("/root/TimeManager")
	bus = get_node("/root/EventBus")
	_reset_time()

func _reset_time() -> void:
	tm.minute = 0
	tm.hour = 6
	tm.day = 1
	tm.season = "spring"
	tm.year = 1
	tm._elapsed = 0.0
	tm._paused = false
	tm._time_scale = 1.0

func test_initial_state() -> void:
	assert_eq(tm.minute, 0, "initial minute = 0")
	assert_eq(tm.hour, 6, "initial hour = 6")
	assert_eq(tm.day, 1, "initial day = 1")
	assert_eq(tm.season, "spring", "initial season = spring")
	assert_eq(tm.year, 1, "initial year = 1")

func test_tick_threshold_under() -> void:
	tm._process(0.624)
	assert_eq(tm.minute, 0, "no tick below 0.625s threshold")

func test_tick_threshold_at() -> void:
	tm._process(0.625)
	assert_eq(tm.minute, 1, "tick advances at exactly 0.625s")

func test_minute_rollover() -> void:
	tm.minute = 59
	tm._process(0.625)
	assert_eq(tm.minute, 0, "minute rolls from 59 to 0")
	assert_eq(tm.hour, 7, "hour increments on minute rollover")

func test_hour_rollover() -> void:
	tm.hour = 23
	tm.minute = 59
	tm._process(0.625)
	assert_eq(tm.hour, 0, "hour rolls from 23 to 0")
	assert_eq(tm.day, 2, "day increments on hour rollover")

func test_day_rollover() -> void:
	tm.day = 28
	tm.hour = 23
	tm.minute = 59
	tm._process(0.625)
	assert_eq(tm.day, 1, "day resets after season boundary")
	assert_eq(tm.season, "summer", "season advances to summer")

func test_season_cycle() -> void:
	var seasons = ["spring", "summer", "autumn", "winter"]
	for i in range(4):
		_reset_time()
		tm.season = seasons[i]
		tm.day = 28
		tm.hour = 23
		tm.minute = 59
		tm._process(0.625)
		var expected_next = seasons[(i + 1) % 4]
		assert_eq(tm.season, expected_next, "%s → %s" % [seasons[i], expected_next])

func test_year_rollover() -> void:
	tm.season = "winter"
	tm.day = 28
	tm.hour = 23
	tm.minute = 59
	tm._process(0.625)
	assert_eq(tm.season, "spring", "season rolls to spring after winter")
	assert_eq(tm.year, 2, "year increments on spring rollover")

func test_pause_resume() -> void:
	tm.pause_time()
	tm._process(10.0)
	assert_eq(tm.minute, 0, "no ticks while paused")
	tm.resume_time()
	tm._process(0.625)
	assert_eq(tm.minute, 1, "ticks resume after unpause")

func test_time_scale_double() -> void:
	tm.set_time_scale(2.0)
	tm._process(0.625)
	assert_eq(tm.minute, 2, "2x scale: 0.625s advances 2 minutes")

func test_time_scale_half() -> void:
	tm.set_time_scale(0.5)
	tm._process(0.625)
	assert_eq(tm.minute, 0, "0.5x scale: 0.625s advances 0")
	tm._process(0.625)
	assert_eq(tm.minute, 1, "0.5x scale: 1.25s advances 1")

func test_advance_to_next_morning() -> void:
	tm.hour = 14
	tm.minute = 30
	tm.advance_to_next_morning()
	assert_eq(tm.hour, 6, "morning hour = 6")
	assert_eq(tm.minute, 0, "morning minute = 0")
	assert_eq(tm.day, 2, "day advances after morning jump")

func test_serialize_roundtrip() -> void:
	tm.hour = 15
	tm.minute = 42
	tm.day = 14
	tm.season = "autumn"
	tm.year = 3
	var data = tm.serialize()
	tm.deserialize(data)
	assert_eq(tm.hour, 15, "deserialized hour")
	assert_eq(tm.minute, 42, "deserialized minute")
	assert_eq(tm.day, 14, "deserialized day")
	assert_eq(tm.season, "autumn", "deserialized season")
	assert_eq(tm.year, 3, "deserialized year")

func test_is_paused() -> void:
	assert_false(tm.is_paused(), "not paused initially")
	tm.pause_time()
	assert_true(tm.is_paused(), "is_paused returns true after pause")
	tm.resume_time()
	assert_false(tm.is_paused(), "is_paused returns false after resume")
