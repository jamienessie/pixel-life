extends GutTest

var fs: Node
var im: Node
var tm: Node
var bus: Node

const ZONE := "test_farm"

func before_each() -> void:
	fs = get_node("/root/FarmingSystem")
	im = get_node("/root/InventoryManager")
	tm = get_node("/root/TimeManager")
	bus = get_node("/root/EventBus")
	_reset()

func _reset() -> void:
	fs._zone_crops.clear()
	for i in im.INVENTORY_SIZE:
		im._slots[i] = null
	tm.season = "summer"

func _emit_day() -> void:
	bus.day_passed.emit(tm.day, tm.season, tm.year)

func test_till_requires_hoe() -> void:
	assert_false(fs.till(ZONE, 0), "till fails without hoe")
	im.add("hoe", 1)
	assert_true(fs.till(ZONE, 0), "till succeeds with hoe")
	assert_eq(fs.get_tile_state(ZONE, 0).stage, fs.STAGE_TILLED)

func test_plant_requires_tilled_and_seeds_and_season() -> void:
	im.add("hoe", 1)
	im.add("tomato_seeds", 3)
	# Untilled: cannot plant
	assert_false(fs.plant(ZONE, 0, "tomato"), "plant fails on dirt")
	fs.till(ZONE, 0)
	tm.season = "winter"
	assert_false(fs.plant(ZONE, 0, "tomato"), "plant fails wrong season")
	tm.season = "summer"
	assert_true(fs.plant(ZONE, 0, "tomato"), "plant succeeds in summer")
	assert_eq(im.count("tomato_seeds"), 2, "seed consumed")

func test_water_requires_can_and_advances_growth() -> void:
	im.add("hoe", 1)
	im.add("watering_can", 1)
	im.add("tomato_seeds", 1)
	tm.season = "summer"
	fs.till(ZONE, 0)
	fs.plant(ZONE, 0, "tomato")
	# Cycle through enough watered days to reach grown.
	for i in 5:
		assert_true(fs.water(ZONE, 0), "water OK on day %d" % i)
		_emit_day()
	var s = fs.get_tile_state(ZONE, 0)
	assert_eq(s.stage, fs.STAGE_GROWN, "tomato is grown after enough days")

func test_harvest_returns_produce_and_regrow() -> void:
	im.add("hoe", 1)
	im.add("watering_can", 1)
	im.add("tomato_seeds", 1)
	tm.season = "summer"
	fs.till(ZONE, 0)
	fs.plant(ZONE, 0, "tomato")
	for _i in 5:
		fs.water(ZONE, 0)
		_emit_day()
	var result = fs.harvest(ZONE, 0)
	assert_true(result.get("ok", false), "harvest succeeded")
	assert_eq(result.get("item"), "tomato", "produced tomato")
	assert_true(im.count("tomato") >= 1, "tomato in inventory")
	# Tomato regrows: stage should be growing or grown again after regrow_days watered cycles.
	var s = fs.get_tile_state(ZONE, 0)
	assert_eq(s.stage, fs.STAGE_GROWING, "regrowing after harvest")
	assert_true(s.regrowing, "regrowing flag set")

func test_withers_in_wrong_season() -> void:
	im.add("hoe", 1)
	im.add("watering_can", 1)
	im.add("tomato_seeds", 1)
	tm.season = "summer"
	fs.till(ZONE, 0)
	fs.plant(ZONE, 0, "tomato")
	fs.water(ZONE, 0)
	# Switch to winter and tick a day.
	tm.season = "winter"
	_emit_day()
	assert_eq(fs.get_tile_state(ZONE, 0).stage, fs.STAGE_WITHERED, "withered in winter")

func test_serialize_round_trip() -> void:
	im.add("hoe", 1)
	im.add("watering_can", 1)
	im.add("tomato_seeds", 1)
	tm.season = "summer"
	fs.till(ZONE, 0)
	fs.plant(ZONE, 0, "tomato")
	var snap = fs.serialize()
	fs._zone_crops.clear()
	fs.deserialize(snap)
	assert_eq(fs.get_tile_state(ZONE, 0).stage, fs.STAGE_PLANTED, "stage survived roundtrip")
	assert_eq(fs.get_tile_state(ZONE, 0).crop_id, "tomato", "crop_id survived")
