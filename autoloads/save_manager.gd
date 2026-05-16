extends Node

const SAVE_PATH := "user://saves/slot0.tres"
const JSON_PATH := "user://saves/slot0.json"
const SAVE_VERSION := 4

var _save_payload_script = load("res://scripts/systems/save/save_payload.gd")
var _character_profile_script = load("res://resources/character_profile.gd")
var _family_tree_script = load("res://resources/family_tree.gd")

func _ready() -> void:
	EventBus.sleep_completed.connect(_on_sleep_completed)
	EventBus.player_died.connect(_on_player_died)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_now("quit")

func save_now(reason: String) -> void:
	EventBus.save_requested.emit()

	# Sync active character's transform into the FamilyTree before serializing.
	if GameState.active_character != null:
		GameState.active_character.money = EconomyManager.get_money()
		GameState.active_character.current_zone = GameState.current_zone
		if SceneRouter.get_player() != null:
			var pos := SceneRouter.get_player().global_position
			GameState.active_character.last_position_x = pos.x
			GameState.active_character.last_position_y = pos.y
	GameState.ensure_family_tree()

	var payload = _save_payload_script.new()
	payload.version = SAVE_VERSION
	payload.created_at_unix = Time.get_unix_time_from_system()
	payload.time_state = TimeManager.serialize()
	payload.active_character_id = _resolve_character_id()
	payload.current_zone = GameState.current_zone
	payload.character_profile = GameState.active_character
	payload.family_tree = GameState.family_tree
	payload.pregnancy_state = FamilyManager.serialize()

	# Needs / economy / inventory / job
	payload.needs_state = NeedsManager.get_all_needs()
	payload.economy_state = {"money": EconomyManager.get_money()}
	payload.inventory_state = InventoryManager.serialize_inventory()
	payload.job_state = JobManager.serialize()
	payload.farming_state = FarmingSystem.serialize()
	payload.weather_state = WeatherManager.serialize()
	payload.festival_state = FestivalManager.serialize()
	payload.audio_settings = AudioManager.serialize()

	var save_dir := "user://saves"
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_recursive_absolute(save_dir)

	var err := ResourceSaver.save(payload, SAVE_PATH)
	if err != OK:
		push_error("SaveManager: failed to write .tres: %s" % err)
		return

	_save_json_sidecar(payload)
	EventBus.save_completed.emit()

func _save_json_sidecar(payload: Resource) -> void:
	var member_count := 0
	if payload.family_tree != null and payload.family_tree.get("members") != null:
		member_count = payload.family_tree.members.size()
	var json_data := {
		"version": payload.version,
		"created_at_unix": payload.created_at_unix,
		"active_character_id": payload.active_character_id,
		"time_state": payload.time_state,
		"character_name": payload.character_profile.character_name if payload.character_profile else "",
		"money": payload.economy_state.get("money", 0) if payload.economy_state else 0,
		"family_size": member_count,
	}
	var json_string := JSON.stringify(json_data, "\t")
	var file := FileAccess.open(JSON_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)

func load_slot() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		EventBus.load_completed.emit()
		return false

	var payload = ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	if payload == null:
		push_error("SaveManager: failed to load .tres")
		EventBus.load_completed.emit()
		return false

	payload = _migrate(payload)

	TimeManager.deserialize(payload.time_state)

	# Restore family tree first so active_character lookups resolve.
	if payload.family_tree != null:
		GameState.family_tree = payload.family_tree
		var active_id: String = payload.active_character_id
		if active_id == "" and payload.character_profile != null:
			active_id = payload.character_profile.id
		GameState.family_tree.active_id = active_id
		GameState.active_character = GameState.family_tree.get_member_by_id(active_id)
	if GameState.active_character == null and payload.character_profile != null:
		GameState.active_character = payload.character_profile
		GameState.ensure_family_tree()

	if payload.current_zone != "":
		GameState.current_zone = payload.current_zone
	elif GameState.active_character != null and GameState.active_character.current_zone != "":
		GameState.current_zone = GameState.active_character.current_zone
	else:
		GameState.current_zone = "town"

	EconomyManager.set_money(payload.economy_state.get("money", 0) if payload.economy_state else 0)
	NeedsManager.set_all_needs(payload.needs_state if payload.needs_state else {})
	InventoryManager.deserialize_inventory(payload.inventory_state if payload.inventory_state else [])
	JobManager.deserialize(payload.job_state if payload.job_state else {})
	FamilyManager.deserialize(payload.pregnancy_state if payload.pregnancy_state else {})
	FarmingSystem.deserialize(payload.farming_state if payload.get("farming_state") else {})
	WeatherManager.deserialize(payload.weather_state if payload.get("weather_state") else {})
	FestivalManager.deserialize(payload.festival_state if payload.get("festival_state") else {})
	AudioManager.deserialize(payload.audio_settings if payload.get("audio_settings") else {})

	EventBus.load_completed.emit()
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	if FileAccess.file_exists(JSON_PATH):
		DirAccess.remove_absolute(JSON_PATH)

func _resolve_character_id() -> String:
	if GameState.active_character != null and GameState.active_character.id != "":
		return GameState.active_character.id
	return "player_001"

func _on_sleep_completed() -> void:
	save_now("sleep")

func _on_player_died(_cause: String) -> void:
	save_now("death")

func _migrate(payload: Resource) -> Resource:
	while payload.version < SAVE_VERSION:
		match payload.version:
			1:
				# v1 → v2: wrap the single character_profile into a FamilyTree.
				if payload.family_tree == null:
					var tree = _family_tree_script.new()
					if payload.character_profile != null:
						tree.members.append(payload.character_profile)
						tree.active_id = payload.character_profile.id
						if payload.active_character_id == "":
							payload.active_character_id = payload.character_profile.id
					payload.family_tree = tree
				if payload.pregnancy_state == null or payload.pregnancy_state.is_empty():
					payload.pregnancy_state = {
						"pregnancy_ticking": false,
						"pregnancy_days_left": 0,
						"pregnancy_parent_id": "",
					}
				payload.version = 2
			2:
				# v2 → v3: introduce farming_state. Default to empty dict so the world
				# starts fresh with no planted crops; old saves never had a farm system.
				if payload.get("farming_state") == null:
					payload.farming_state = {}
				payload.version = 3
			3:
				# v3 → v4: weather, festivals, audio settings.
				if payload.get("weather_state") == null:
					payload.weather_state = {}
				if payload.get("festival_state") == null:
					payload.festival_state = {}
				if payload.get("audio_settings") == null:
					payload.audio_settings = {}
				payload.version = 4
			_:
				push_error("SaveManager: unsupported migration from version %d" % payload.version)
				break
	return payload
