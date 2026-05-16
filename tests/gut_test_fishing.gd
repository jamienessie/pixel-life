extends GutTest

var fsh: Node

func before_each() -> void:
	fsh = get_node("/root/FishingSystem")

func test_eligible_filters_by_season() -> void:
	var winter_at_noon = fsh.get_eligible_fish("winter", 12)
	# Sardine is any-season, any-time. Tuna is summer 8-16; should not appear in winter.
	var ids: Array = []
	for f in winter_at_noon:
		ids.append(f.id)
	assert_has(ids, "sardine", "sardine eligible year-round")
	assert_does_not_have(ids, "tuna", "tuna NOT eligible in winter")
	assert_does_not_have(ids, "salmon", "salmon NOT eligible in winter")

func test_eligible_filters_by_time_window() -> void:
	# Tuna window 8..16 — at hour 7 it shouldn't appear even in summer.
	var summer_dawn = fsh.get_eligible_fish("summer", 7)
	var ids: Array = []
	for f in summer_dawn:
		ids.append(f.id)
	assert_does_not_have(ids, "tuna", "tuna NOT eligible before 8h")

func test_legendary_pike_winter_midnight_window() -> void:
	# Legendary pike: winter only, time_window 22..24.
	var winter_midnight = fsh.get_eligible_fish("winter", 23)
	var ids: Array = []
	for f in winter_midnight:
		ids.append(f.id)
	assert_has(ids, "legendary_pike", "legendary pike at winter midnight")

func test_roll_returns_eligible_fish() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = 1234
	var f = fsh.roll_catch("summer", 12, 0.5, rng)
	assert_not_null(f, "rolled a fish")
	# Hour 12 summer: sardine, bass, tuna allowed; salmon (autumn) and legendary_pike (winter midnight) not.
	assert_does_not_have(["salmon", "legendary_pike"], f.id, "did not roll out-of-season fish")

func test_sell_value_lerps_min_max() -> void:
	var sardine = fsh.load_fish("sardine")
	assert_eq(fsh.sell_value(sardine, 0.0), sardine.min_sell_price, "min at quality 0")
	assert_eq(fsh.sell_value(sardine, 1.0), sardine.max_sell_price, "max at quality 1")
