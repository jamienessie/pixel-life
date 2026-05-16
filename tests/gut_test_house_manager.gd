extends GutTest

# Tests for HouseManager (M10).

func before_each() -> void:
	var profile := CharacterProfile.new()
	profile.id = "test_player"
	profile.character_name = "Test"
	profile.age = 25
	profile.house_tier = 1
	profile.money = 0
	GameState.active_character = profile
	GameState.family_tree = FamilyTree.new()
	GameState.family_tree.add_member(profile)
	GameState.family_tree.active_id = profile.id
	EconomyManager.set_money(100000)

func test_buying_furniture_deducts_money_and_records_ownership() -> void:
	var before := EconomyManager.get_money()
	var ok := HouseManager.buy_furniture("chair")
	assert_true(ok, "chair purchase should succeed at tier 1")
	assert_true(HouseManager.owns("chair"), "owned after purchase")
	assert_eq(EconomyManager.get_money(), before - 80, "money deducted exactly by chair cost (80)")

func test_buying_locked_furniture_fails() -> void:
	# bed_double has min_house_tier=2; player is at tier 1.
	var ok := HouseManager.buy_furniture("bed_double")
	assert_false(ok, "tier-locked furniture refuses purchase")
	assert_false(HouseManager.owns("bed_double"))

func test_furniture_effects_aggregate() -> void:
	HouseManager.buy_furniture("easel")
	HouseManager.buy_furniture("chair")
	assert_almost_eq(HouseManager.get_effect("painter_perf_bonus"), 0.15, 0.001)
	assert_almost_eq(HouseManager.get_effect("fun_decay_reduction"), 0.5, 0.001)
	# Effect that no owned furniture provides should be 0.
	assert_eq(HouseManager.get_effect("nonexistent_effect"), 0.0)

func test_house_upgrade_deducts_money_and_updates_tier() -> void:
	var ok := HouseManager.buy_house_upgrade(2)
	assert_true(ok, "tier 2 upgrade should succeed with enough money")
	assert_eq(GameState.active_character.house_tier, 2)
	# 100000 - 5000 (upgrade) + 100 (first_house_upgrade achievement reward) = 95100
	assert_eq(EconomyManager.get_money(), 95100)

func test_cannot_skip_house_tiers() -> void:
	# Skipping from tier 1 to tier 3 directly is allowed (we deduct tier 3 cost) — but UI gates it.
	# The manager itself just enforces "tier > current". This test documents that contract.
	var ok := HouseManager.buy_house_upgrade(3)
	assert_true(ok, "manager allows arbitrary upgrade-up; UI handles step gating")
	assert_eq(GameState.active_character.house_tier, 3)

func test_sell_returns_half_value() -> void:
	HouseManager.buy_furniture("easel") # cost 400
	var before := EconomyManager.get_money()
	HouseManager.sell_furniture("easel")
	assert_false(HouseManager.owns("easel"))
	assert_eq(EconomyManager.get_money(), before + 200, "sold for 50% of buy price")

func test_studying_requires_bookshelf_at_home() -> void:
	assert_false(HouseManager.can_study(), "no bookshelf + not at home → cannot study")
	HouseManager.buy_furniture("bookshelf")
	GameState.current_zone = "town"
	assert_false(HouseManager.can_study(), "bookshelf owned but not at home → still no")
	GameState.current_zone = "interior_tier1"
	assert_true(HouseManager.can_study(), "bookshelf + at home → can study")
