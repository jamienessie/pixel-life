extends Node

# FamilyManager — aging, pregnancy, death triggers (M11/M12).
# Resource registrations so class_name types resolve at autoload load.
const _reg_character_profile := preload("res://resources/character_profile.gd")
const _reg_family_tree := preload("res://resources/family_tree.gd")

const LIFE_EXPECTANCY_MIN := 70
const LIFE_EXPECTANCY_MAX := 90
const PREGNANCY_DAYS := 14
const STAGE_AGE := {
	"baby": 0,
	"child": 5,
	"teen": 13,
	"adult": 18,
}

var _pregnancy_ticking: bool = false
var _pregnancy_days_left: int = 0
var _pregnancy_parent_id: String = ""

# RAI-40: NPC overrides. After marriage the spouse's effective home_zone and
# schedule are replaced. NPCSpawner and NPCScheduleRunner consult this map
# in preference to the NPC's own .tres data.
# Shape: npc_id -> {"home_zone": String, "schedule_id": String}
var _npc_overrides: Dictionary = {}

func _ready() -> void:
	EventBus.year_passed.connect(_on_year_passed)
	EventBus.day_passed.connect(_on_day_passed)
	EventBus.marriage_completed.connect(_on_marriage_completed)

func try_conceive() -> bool:
	var profile: CharacterProfile = GameState.active_character
	if profile == null:
		return false
	if profile.spouse == "":
		return false
	if profile.house_tier < 1:
		return false
	if _pregnancy_ticking:
		return false
	# Spouse alive?
	var tree: FamilyTree = GameState.family_tree
	if tree != null:
		var spouse: CharacterProfile = tree.get_member_by_id(profile.spouse)
		if spouse != null and spouse.deceased:
			return false
	_pregnancy_ticking = true
	_pregnancy_days_left = PREGNANCY_DAYS
	_pregnancy_parent_id = profile.id
	return true

func is_pregnant() -> bool:
	return _pregnancy_ticking

func pregnancy_days_left() -> int:
	return _pregnancy_days_left

func tick_year() -> void:
	var tree: FamilyTree = GameState.family_tree
	if tree == null:
		return
	# Snapshot the member list so deaths don't mutate iteration.
	var members_snapshot: Array = tree.members.duplicate()
	for m in members_snapshot:
		if m is CharacterProfile and not m.deceased:
			age_actor(m.id)
	# Second pass: deaths.
	for m in members_snapshot:
		if m is CharacterProfile and not m.deceased and m.age >= LIFE_EXPECTANCY_MIN:
			try_die(m.id)

func age_actor(actor_id: String) -> void:
	var tree: FamilyTree = GameState.family_tree
	if tree == null:
		return
	var m: CharacterProfile = tree.get_member_by_id(actor_id)
	if m == null or m.deceased:
		return
	var prev_stage := _stage_for_age(m.age)
	m.age += 1
	var new_stage := _stage_for_age(m.age)
	if new_stage != prev_stage:
		EventBus.child_aged.emit(actor_id, new_stage)

func try_die(actor_id: String) -> bool:
	var tree: FamilyTree = GameState.family_tree
	if tree == null:
		return false
	var m: CharacterProfile = tree.get_member_by_id(actor_id)
	if m == null or m.deceased:
		return false
	if m.age < LIFE_EXPECTANCY_MIN:
		return false
	var p: float = clampf(
		float(m.age - LIFE_EXPECTANCY_MIN) / float(LIFE_EXPECTANCY_MAX - LIFE_EXPECTANCY_MIN),
		0.0, 1.0
	)
	var forced: bool = m.age >= LIFE_EXPECTANCY_MAX
	if forced or randf() < p:
		tree.mark_deceased(actor_id)
		if actor_id == tree.active_id:
			EventBus.player_died.emit("old_age")
		return true
	return false

func move_out_adult_child(actor_id: String) -> void:
	# Optional. v1: no-op; the child still belongs to the family tree.
	pass

func succeed_to(child_id: String) -> void:
	# Implemented via succession_controller.gd at slice 3.
	GameState.switch_active_character(child_id)

func _on_year_passed(_year: int) -> void:
	tick_year()

func _on_day_passed(_day: int, _season: String, _year: int) -> void:
	if not _pregnancy_ticking:
		return
	_pregnancy_days_left -= 1
	if _pregnancy_days_left <= 0:
		_complete_pregnancy()

func _complete_pregnancy() -> void:
	_pregnancy_ticking = false
	_pregnancy_days_left = 0
	var tree: FamilyTree = GameState.family_tree
	var parent: CharacterProfile = null
	if tree != null:
		parent = tree.get_member_by_id(_pregnancy_parent_id)
	if parent == null:
		parent = GameState.active_character
	if parent == null:
		return
	var child := CharacterProfile.new()
	child.id = "child_%d" % Time.get_unix_time_from_system()
	child.character_name = "Child of %s" % parent.character_name
	child.age = 0
	child.birth_year = TimeManager.year
	child.parents = [parent.id]
	if parent.spouse != "":
		child.parents.append(parent.spouse)
	child.house_tier = parent.house_tier
	child.current_zone = parent.current_zone
	if tree != null:
		tree.add_member(child)
	if not parent.children.has(child.id):
		parent.children.append(child.id)
	# Also append the child to the spouse's children list if present.
	if tree != null and parent.spouse != "":
		var spouse: CharacterProfile = tree.get_member_by_id(parent.spouse)
		if spouse != null and not spouse.children.has(child.id):
			spouse.children.append(child.id)
	EventBus.child_born.emit(child.id)

func _on_marriage_completed(npc_id: String) -> void:
	var profile: CharacterProfile = GameState.active_character
	if profile == null:
		return
	profile.spouse = npc_id
	# Override the spouse NPC's home zone + schedule so they live at the player's
	# interior. Index keyed by current house tier; spouse follows tier upgrades.
	var home_zone: String = "interior_tier%d" % max(1, profile.house_tier)
	_npc_overrides[npc_id] = {
		"home_zone": home_zone,
		"schedule_id": "spouse_default",
	}
	# Create a shadow CharacterProfile for the NPC spouse so they can age and inherit.
	var tree: FamilyTree = GameState.family_tree
	if tree == null:
		return
	if tree.get_member_by_id(npc_id) != null:
		return
	var spouse := CharacterProfile.new()
	spouse.id = npc_id
	var npc_path := "res://data/npcs/%s.tres" % npc_id
	var npc_data = ResourceLoader.load(npc_path, "", ResourceLoader.CACHE_MODE_IGNORE) if FileAccess.file_exists(npc_path) else null
	if npc_data != null:
		spouse.character_name = npc_data.npc_name
		spouse.gender = npc_data.gender
	else:
		spouse.character_name = npc_id.capitalize()
	spouse.age = max(profile.age, 22)
	spouse.spouse = profile.id
	spouse.house_tier = profile.house_tier
	tree.add_member(spouse)

func get_npc_override(npc_id: String) -> Dictionary:
	return _npc_overrides.get(npc_id, {})

func has_npc_override(npc_id: String) -> bool:
	return _npc_overrides.has(npc_id)

func clear_npc_override(npc_id: String) -> void:
	_npc_overrides.erase(npc_id)

func _stage_for_age(age: int) -> String:
	if age < STAGE_AGE["child"]:
		return "baby"
	elif age < STAGE_AGE["teen"]:
		return "child"
	elif age < STAGE_AGE["adult"]:
		return "teen"
	return "adult"

func serialize() -> Dictionary:
	return {
		"pregnancy_ticking": _pregnancy_ticking,
		"pregnancy_days_left": _pregnancy_days_left,
		"pregnancy_parent_id": _pregnancy_parent_id,
		"npc_overrides": _npc_overrides.duplicate(true),
	}

func deserialize(data: Dictionary) -> void:
	_pregnancy_ticking = data.get("pregnancy_ticking", false)
	_pregnancy_days_left = data.get("pregnancy_days_left", 0)
	_pregnancy_parent_id = data.get("pregnancy_parent_id", "")
	_npc_overrides = data.get("npc_overrides", {})
