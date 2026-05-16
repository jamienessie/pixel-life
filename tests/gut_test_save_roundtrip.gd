extends GutTest

var sm: Node
var bus: Node

func before_each() -> void:
	sm = get_node("/root/SaveManager")
	bus = get_node("/root/EventBus")
	sm.delete_save()

func after_all() -> void:
	sm.delete_save()

func test_constants() -> void:
	assert_eq(sm.SAVE_VERSION, 4, "SAVE_VERSION == 4 (current)")
	assert_eq(sm.SAVE_PATH, "user://saves/slot0.tres", "SAVE_PATH")
	assert_eq(sm.JSON_PATH, "user://saves/slot0.json", "JSON_PATH")

func test_no_save_by_default() -> void:
	assert_false(sm.has_save(), "has_save false with no save")
	assert_false(sm.load_slot(), "load_slot false with no save")

func test_delete_save_no_error_when_empty() -> void:
	sm.delete_save()
	assert_false(sm.has_save(), "no save after delete on empty")

func test_save_payload_is_resource() -> void:
	var SavePayloadClass = load("res://scripts/systems/save/save_payload.gd")
	var payload = SavePayloadClass.new()
	assert_true(payload is Resource, "SavePayload is Resource")
	assert_eq(payload.version, 4, "default version 4 (current)")
	assert_eq(payload.created_at_unix, 0, "default created_at 0")

func test_save_payload_fields_roundtrip() -> void:
	var SavePayloadClass = load("res://scripts/systems/save/save_payload.gd")
	var payload = SavePayloadClass.new()
	payload.version = 1
	payload.created_at_unix = 1712345678
	payload.time_state = {"minute": 30, "hour": 12, "day": 15, "season": "summer", "year": 2}
	payload.active_character_id = "test_char_001"

	assert_eq(payload.version, 1, "version persisted")
	assert_eq(payload.created_at_unix, 1712345678, "timestamp persisted")
	assert_eq(payload.time_state["minute"], 30, "time_state minute persisted")
	assert_eq(payload.time_state["hour"], 12, "time_state hour persisted")
	assert_eq(payload.time_state["day"], 15, "time_state day persisted")
	assert_eq(payload.time_state["season"], "summer", "time_state season persisted")
	assert_eq(payload.time_state["year"], 2, "time_state year persisted")
	assert_eq(payload.active_character_id, "test_char_001", "active_character_id persisted")

func test_save_signals_fire() -> void:
	var save_requested_fired := false
	var save_completed_fired := false
	var load_completed_fired := false

	bus.save_requested.connect(func(): save_requested_fired = true)
	bus.save_completed.connect(func(): save_completed_fired = true)
	bus.load_completed.connect(func(): load_completed_fired = true)

	sm.save_now("test")
	assert_true(save_requested_fired, "save_requested signal fired")
	assert_true(save_completed_fired, "save_completed signal fired")

	sm.load_slot()
	assert_true(load_completed_fired, "load_completed signal fired")

func test_disk_round_trip() -> void:
	GameState.active_character = null
	GameState.current_zone = "forest"
	TimeManager.hour = 14
	TimeManager.minute = 30
	TimeManager.day = 15
	TimeManager.season = "summer"
	TimeManager.year = 2
	EconomyManager.set_money(1250)

	sm.save_now("test_roundtrip")
	assert_true(sm.has_save(), "save file exists after save_now")
	assert_true(FileAccess.file_exists(sm.JSON_PATH), "JSON sidecar exists")

	var json_file := FileAccess.open(sm.JSON_PATH, FileAccess.READ)
	var json_text := json_file.get_as_text()
	var parsed := JSON.parse_string(json_text)
	assert_true(parsed is Dictionary, "JSON sidecar is valid JSON")
	assert_eq(parsed.get("version"), 4, "JSON version matches v4")
	assert_eq(parsed.get("money"), 1250, "JSON money matches")

	TimeManager.hour = 6
	TimeManager.minute = 0
	TimeManager.day = 1
	TimeManager.season = "spring"
	TimeManager.year = 1
	EconomyManager.set_money(0)
	GameState.current_zone = ""

	var loaded := sm.load_slot()
	assert_true(loaded, "load_slot returns true")

	assert_eq(TimeManager.hour, 14, "loaded hour == 14")
	assert_eq(TimeManager.minute, 30, "loaded minute == 30")
	assert_eq(TimeManager.day, 15, "loaded day == 15")
	assert_eq(TimeManager.season, "summer", "loaded season == summer")
	assert_eq(TimeManager.year, 2, "loaded year == 2")
	assert_eq(EconomyManager.get_money(), 1250, "loaded money == 1250")
	assert_eq(GameState.current_zone, "forest", "loaded zone == forest")

	sm.delete_save()
	assert_false(sm.has_save(), "save deleted after cleanup")
