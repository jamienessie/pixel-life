extends GutTest

# Tests for FamilyManager (M11).

const _reg_family_tree := preload("res://resources/family_tree.gd")

func before_each() -> void:
	# Fresh family tree on each test.
	var profile := CharacterProfile.new()
	profile.id = "test_player"
	profile.character_name = "Test"
	profile.age = 25
	profile.house_tier = 1
	var tree := FamilyTree.new()
	tree.add_member(profile)
	tree.active_id = profile.id
	GameState.active_character = profile
	GameState.family_tree = tree
	# Reset pregnancy state.
	FamilyManager.deserialize({})

func test_stage_thresholds() -> void:
	var fm = FamilyManager
	assert_eq(fm._stage_for_age(0), "baby")
	assert_eq(fm._stage_for_age(4), "baby")
	assert_eq(fm._stage_for_age(5), "child")
	assert_eq(fm._stage_for_age(12), "child")
	assert_eq(fm._stage_for_age(13), "teen")
	assert_eq(fm._stage_for_age(17), "teen")
	assert_eq(fm._stage_for_age(18), "adult")
	assert_eq(fm._stage_for_age(75), "adult")

func test_aging_advances_year() -> void:
	var start := GameState.active_character.age
	FamilyManager.tick_year()
	assert_eq(GameState.active_character.age, start + 1)

func test_conceive_requires_spouse() -> void:
	GameState.active_character.spouse = ""
	assert_false(FamilyManager.try_conceive(), "no spouse → no pregnancy")
	GameState.active_character.spouse = "anna"
	# Add a living spouse profile.
	var spouse := CharacterProfile.new()
	spouse.id = "anna"
	spouse.age = 26
	GameState.family_tree.add_member(spouse)
	assert_true(FamilyManager.try_conceive(), "with living spouse + house_tier 1 → OK")
	assert_true(FamilyManager.is_pregnant())

func test_pregnancy_completes_after_14_days() -> void:
	GameState.active_character.spouse = "anna"
	var spouse := CharacterProfile.new()
	spouse.id = "anna"
	spouse.age = 26
	GameState.family_tree.add_member(spouse)
	FamilyManager.try_conceive()
	for i in range(FamilyManager.PREGNANCY_DAYS):
		FamilyManager._on_day_passed(1, "spring", 1)
	assert_false(FamilyManager.is_pregnant(), "pregnancy ended after 14 days")
	assert_eq(GameState.family_tree.living().size(), 3, "player + spouse + child")
	assert_eq(GameState.active_character.children.size(), 1)

func test_try_die_at_max_age_is_certain() -> void:
	GameState.active_character.age = FamilyManager.LIFE_EXPECTANCY_MAX + 1
	var died := FamilyManager.try_die(GameState.active_character.id)
	assert_true(died, "death is guaranteed past LIFE_EXPECTANCY_MAX")
	assert_true(GameState.active_character.deceased)

func test_try_die_before_min_age_is_blocked() -> void:
	GameState.active_character.age = 30
	var died := FamilyManager.try_die(GameState.active_character.id)
	assert_false(died, "no death below LIFE_EXPECTANCY_MIN")
	assert_false(GameState.active_character.deceased)

func test_marriage_completed_sets_spouse_and_adds_to_tree() -> void:
	EventBus.marriage_completed.emit("anna")
	# Manager listens to the signal in _ready, so the active character should now have a spouse.
	assert_eq(GameState.active_character.spouse, "anna")
	var spouse: CharacterProfile = GameState.family_tree.get_member_by_id("anna")
	assert_not_null(spouse, "spouse added as shadow profile")
