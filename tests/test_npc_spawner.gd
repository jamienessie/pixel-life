extends SceneTree

# GDScript unit tests for NPC system data loading.
# Run: godot --path <project> --headless --script tests/test_npc_spawner.gd

func _initialize() -> void:
	await self.process_frame

	print("=== NPC System Unit Tests ===")

	_test_npc_data_exists("anna")
	_test_npc_data_exists("bryan")
	_test_npc_data_exists("cora")
	_test_npc_data_properties()
	_test_npc_dialogue_data_exists()
	_test_npc_schedule_data_exists()
	_test_schedule_entries()

	print("\n✓ All NPC system tests passed!")
	quit(0)

func _test_npc_data_exists(npc_id: String) -> void:
	var data = load("res://data/npcs/%s.tres" % npc_id)
	assert(data != null, "NPC %s data loaded" % npc_id)
	assert(data is Resource, "NPC %s is Resource" % npc_id)
	assert(data.get("id") == npc_id, "NPC %s id matches" % npc_id)
	print("  _test_npc_data_exists(%s) ✓" % npc_id)

func _test_npc_data_properties() -> void:
	var anna = load("res://data/npcs/anna.tres")
	assert(anna.get("npc_name") == "Anna", "anna name")
	assert(anna.get("home_zone") == "town", "anna home zone")
	assert(anna.get("marriageable") == true, "anna marriageable")
	assert(anna.get("dialogue_id") == "anna_dialogue", "anna dialogue id")
	assert(anna.get("schedule_id") == "anna_schedule", "anna schedule id")

	var bryan = load("res://data/npcs/bryan.tres")
	assert(bryan.get("home_zone") == "farm", "bryan home zone")

	var cora = load("res://data/npcs/cora.tres")
	assert(cora.get("home_zone") == "beach", "cora home zone")
	print("  _test_npc_data_properties ✓")

func _test_npc_dialogue_data_exists() -> void:
	var npc_ids := ["anna", "bryan", "cora"]
	for npc_id in npc_ids:
		var data = load("res://data/npcs/%s.tres" % npc_id)
		var dialogue_id = data.get("dialogue_id", "")
		var dialogue = load("res://data/dialogue/%s.tres" % dialogue_id)
		assert(dialogue != null, "dialogue %s loaded" % dialogue_id)
		var nodes = dialogue.get("nodes", {})
		assert(nodes.has("greet"), "dialogue %s has greet node" % dialogue_id)
		assert(nodes.has("farewell"), "dialogue %s has farewell node" % dialogue_id)
	print("  _test_npc_dialogue_data_exists ✓")

func _test_npc_schedule_data_exists() -> void:
	var npc_ids := ["anna", "bryan", "cora"]
	for npc_id in npc_ids:
		var data = load("res://data/npcs/%s.tres" % npc_id)
		var schedule_id = data.get("schedule_id", "")
		var schedule = load("res://data/schedules/%s.tres" % schedule_id)
		assert(schedule != null, "schedule %s loaded" % schedule_id)
		var entries = schedule.get("entries", [])
		assert(entries.size() > 0, "schedule %s has entries" % schedule_id)
	print("  _test_npc_schedule_data_exists ✓")

func _test_schedule_entries() -> void:
	var schedule = load("res://data/schedules/anna_schedule.tres")
	var entries = schedule.get("entries", [])
	for entry in entries:
		assert(entry.has("hour"), "entry has hour")
		assert(entry.has("minute"), "entry has minute")
		assert(entry.has("zone_id"), "entry has zone_id")
		assert(entry.has("target_marker"), "entry has target_marker")
		assert(entry.has("action"), "entry has action")
		assert(entry.hour >= 0 and entry.hour < 24, "entry hour in range")
		assert(entry.minute >= 0 and entry.minute < 60, "entry minute in range")
	print("  _test_schedule_entries ✓")
