extends GutTest

func test_npc_anna_data_exists() -> void:
	var data: Variant = load("res://data/npcs/anna.tres")
	assert_not_null(data, "anna NPC data loads")
	assert_eq(data.get("id"), "anna", "anna id matches")

func test_npc_bryan_data_exists() -> void:
	var data: Variant = load("res://data/npcs/bryan.tres")
	assert_not_null(data, "bryan NPC data loads")
	assert_eq(data.get("id"), "bryan", "bryan id matches")

func test_npc_cora_data_exists() -> void:
	var data: Variant = load("res://data/npcs/cora.tres")
	assert_not_null(data, "cora NPC data loads")
	assert_eq(data.get("id"), "cora", "cora id matches")

func test_npc_anna_properties() -> void:
	var anna: Variant = load("res://data/npcs/anna.tres")
	assert_eq(anna.get("npc_name"), "Anna", "anna name")
	assert_eq(anna.get("home_zone"), "town", "anna home zone")
	assert_eq(anna.get("marriageable"), true, "anna marriageable")
	assert_eq(anna.get("dialogue_id"), "anna_dialogue", "anna dialogue id")
	assert_eq(anna.get("schedule_id"), "anna_schedule", "anna schedule id")

func test_npc_bryan_home_zone() -> void:
	var bryan: Variant = load("res://data/npcs/bryan.tres")
	assert_eq(bryan.get("home_zone"), "farm", "bryan home zone is farm")

func test_npc_cora_home_zone() -> void:
	var cora: Variant = load("res://data/npcs/cora.tres")
	assert_eq(cora.get("home_zone"), "beach", "cora home zone is beach")

func test_all_npc_dialogue_data_exists() -> void:
	var npc_ids := ["anna", "bryan", "cora"]
	for npc_id in npc_ids:
		var data: Variant = load("res://data/npcs/%s.tres" % npc_id)
		var dialogue_id: String = data.get("dialogue_id", "")
		var dialogue: Variant = load("res://data/dialogue/%s.tres" % dialogue_id)
		assert_not_null(dialogue, "dialogue %s loads" % dialogue_id)
		var nodes: Variant = dialogue.get("nodes", {})
		assert_true(nodes.has("greet"), "dialogue %s has greet node" % dialogue_id)
		assert_true(nodes.has("farewell"), "dialogue %s has farewell node" % dialogue_id)

func test_all_npc_schedule_data_exists() -> void:
	var npc_ids := ["anna", "bryan", "cora"]
	for npc_id in npc_ids:
		var data: Variant = load("res://data/npcs/%s.tres" % npc_id)
		var schedule_id: String = data.get("schedule_id", "")
		var schedule: Variant = load("res://data/schedules/%s.tres" % schedule_id)
		assert_not_null(schedule, "schedule %s loads" % schedule_id)
		var entries: Variant = schedule.get("entries", [])
		assert_gt(entries.size(), 0, "schedule %s has entries" % schedule_id)

func test_anna_schedule_entries_valid() -> void:
	var schedule: Variant = load("res://data/schedules/anna_schedule.tres")
	var entries: Variant = schedule.get("entries", [])
	for entry in entries:
		assert_true(entry.has("hour"), "entry has hour")
		assert_true(entry.has("minute"), "entry has minute")
		assert_true(entry.has("zone_id"), "entry has zone_id")
		assert_true(entry.has("target_marker"), "entry has target_marker")
		assert_true(entry.has("action"), "entry has action")
		assert_gte(entry.hour, 0, "entry hour >= 0")
		assert_lt(entry.hour, 24, "entry hour < 24")
		assert_gte(entry.minute, 0, "entry minute >= 0")
		assert_lt(entry.minute, 60, "entry minute < 60")
