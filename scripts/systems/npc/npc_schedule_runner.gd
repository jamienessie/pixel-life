extends Node

# Force class_name registration for Resource types used in this script
const _reg_npc_data := preload("res://resources/npc_data.gd")
const _reg_schedule_data := preload("res://resources/schedule_data.gd")

var _npc_map: Dictionary = {}

func _ready() -> void:
	EventBus.hour_passed.connect(_on_hour_passed)
	EventBus.minute_passed.connect(_on_minute_passed)

func register_npc(npc_id: String, controller: Node2D) -> void:
	_npc_map[npc_id] = controller

func unregister_npc(npc_id: String) -> void:
	_npc_map.erase(npc_id)

func _on_hour_passed(_hour: int) -> void:
	_process_schedules()

func _on_minute_passed(_minute: int) -> void:
	if TimeManager.minute % 15 == 0:
		_process_schedules()

func _process_schedules() -> void:
	var current_hour := TimeManager.hour
	var current_minute := TimeManager.minute
	var current_zone := GameState.current_zone

	for npc_id in _npc_map:
		var controller := _npc_map[npc_id] as Node2D
		if controller == null:
			continue
		var data := _load_npc_data(npc_id)
		if data == null:
			continue
		var override := FamilyManager.get_npc_override(npc_id) if FamilyManager.has_npc_override(npc_id) else {}
		var effective_home: String = data.home_zone
		var effective_schedule_id: String = data.schedule_id
		if override is Dictionary and not override.is_empty():
			effective_home = override.get("home_zone", effective_home)
			effective_schedule_id = override.get("schedule_id", effective_schedule_id)
		if effective_home != current_zone:
			continue

		var schedule := _load_schedule(effective_schedule_id)
		if schedule == null:
			continue

		var active_entry = _find_active_entry(schedule, current_hour, current_minute)
		if active_entry == null:
			continue

		var zone_node := SceneRouter.get_current_zone()
		if zone_node == null:
			continue
		var spawn := zone_node.get_node_or_null("Spawns/" + active_entry.target_marker)
		if spawn != null:
			controller.set_target(spawn.global_position)

func _find_active_entry(schedule: Resource, hour: int, minute: int) -> Dictionary:
	var best_entry: Dictionary = {}
	var best_time := -1

	for entry in schedule.entries:
		var entry_minutes: int = entry.hour * 60 + entry.minute
		if entry_minutes <= hour * 60 + minute and entry_minutes > best_time:
			best_entry = entry
			best_time = entry_minutes

	return best_entry

func _load_npc_data(npc_id: String) -> Resource:
	return load("res://data/npcs/%s.tres" % npc_id)

func _load_schedule(schedule_id: String) -> Resource:
	return load("res://data/schedules/%s.tres" % schedule_id)
