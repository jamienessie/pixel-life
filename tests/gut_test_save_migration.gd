extends GutTest

# Tests that a v1 save can be migrated forward to v2.

const _reg_save_payload := preload("res://scripts/systems/save/save_payload.gd")
const _reg_family_tree := preload("res://resources/family_tree.gd")

func _make_v1_payload() -> Resource:
	var p = SavePayload.new()
	p.version = 1
	p.created_at_unix = 1700000000
	p.time_state = {"minute": 0, "hour": 8, "day": 1, "season": "spring", "year": 1}
	p.active_character_id = "legacy_player"
	var profile := CharacterProfile.new()
	profile.id = "legacy_player"
	profile.character_name = "Legacy"
	profile.age = 30
	profile.money = 500
	p.character_profile = profile
	p.economy_state = {"money": 500}
	p.needs_state = {}
	p.inventory_state = []
	p.job_state = {}
	p.family_tree = null
	p.pregnancy_state = {}
	return p

func test_v1_migrates_to_current() -> void:
	var payload = _make_v1_payload()
	var migrated = SaveManager._migrate(payload)
	assert_eq(migrated.version, 4, "version bumped to 4 (v1→v2→v3→v4)")
	assert_not_null(migrated.family_tree, "family_tree created during migration")
	assert_eq(migrated.family_tree.members.size(), 1, "single legacy character migrated")
	assert_eq(migrated.family_tree.active_id, "legacy_player", "active id set")
	assert_eq(migrated.active_character_id, "legacy_player", "active character id populated")
	assert_eq(migrated.farming_state, {}, "farming_state initialized (v3)")
	assert_eq(migrated.weather_state, {}, "weather_state initialized (v4)")
	assert_eq(migrated.festival_state, {}, "festival_state initialized (v4)")
	assert_eq(migrated.audio_settings, {}, "audio_settings initialized (v4)")

func test_v1_preserves_money_and_time() -> void:
	var payload = _make_v1_payload()
	var migrated = SaveManager._migrate(payload)
	assert_eq(migrated.economy_state.get("money", 0), 500, "money survives migration")
	assert_eq(migrated.time_state.get("hour", 0), 8, "time survives migration")
	assert_eq(migrated.character_profile.character_name, "Legacy", "profile reference preserved")

func test_v2_migrates_through_v3_v4() -> void:
	var payload = SavePayload.new()
	payload.version = 2
	payload.family_tree = FamilyTree.new()
	var profile := CharacterProfile.new()
	profile.id = "p2"
	payload.family_tree.add_member(profile)
	payload.family_tree.active_id = "p2"
	payload.active_character_id = "p2"
	var migrated = SaveManager._migrate(payload)
	assert_eq(migrated.version, 4, "version bumped to 4 (v2→v3→v4)")
	assert_eq(migrated.family_tree.members.size(), 1, "members untouched")
	assert_eq(migrated.farming_state, {}, "farming_state initialized (v3)")
	assert_eq(migrated.weather_state, {}, "weather_state initialized (v4)")
	assert_eq(migrated.festival_state, {}, "festival_state initialized (v4)")
	assert_eq(migrated.audio_settings, {}, "audio_settings initialized (v4)")
