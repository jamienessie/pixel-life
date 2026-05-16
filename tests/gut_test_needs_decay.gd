extends GutTest

var nm: Node
var bus: Node

func before_each() -> void:
	nm = get_node("/root/NeedsManager")
	bus = get_node("/root/EventBus")
	_reset_needs()

func _reset_needs() -> void:
	nm.set_all_needs({"energy": 100.0, "hunger": 100.0, "hygiene": 100.0, "social": 100.0, "fun": 100.0})

func test_initial_needs_values() -> void:
	assert_eq(nm.get_need("energy"), 100.0, "initial energy = 100")
	assert_eq(nm.get_need("hunger"), 100.0, "initial hunger = 100")
	assert_eq(nm.get_need("hygiene"), 100.0, "initial hygiene = 100")
	assert_eq(nm.get_need("social"), 100.0, "initial social = 100")
	assert_eq(nm.get_need("fun"), 100.0, "initial fun = 100")

func test_energy_decay_per_hour() -> void:
	var initial = nm.get_need("energy")
	EventBus.hour_passed.emit(0)
	assert_eq(nm.get_need("energy"), initial - 4.0, "energy decays by 4.0 per hour")

func test_hunger_decay_per_hour() -> void:
	var initial = nm.get_need("hunger")
	EventBus.hour_passed.emit(1)
	assert_eq(nm.get_need("hunger"), initial - 3.0, "hunger decays by 3.0 per hour")

func test_hygiene_decay_per_hour() -> void:
	var initial = nm.get_need("hygiene")
	EventBus.hour_passed.emit(2)
	assert_eq(nm.get_need("hygiene"), initial - 1.0, "hygiene decays by 1.0 per hour")

func test_social_decay_per_hour() -> void:
	var initial = nm.get_need("social")
	EventBus.hour_passed.emit(3)
	assert_eq(nm.get_need("social"), initial - 1.5, "social decays by 1.5 per hour")

func test_fun_decay_per_hour() -> void:
	var initial = nm.get_need("fun")
	EventBus.hour_passed.emit(4)
	assert_eq(nm.get_need("fun"), initial - 2.0, "fun decays by 2.0 per hour")

func test_needs_capped_at_zero() -> void:
	# Decay many hours to push needs to zero
	for i in 100:
		EventBus.hour_passed.emit(i)
	assert_true(nm.get_need("energy") >= 0.0, "energy clamped >= 0")
	assert_true(nm.get_need("hunger") >= 0.0, "hunger clamped >= 0")
	assert_true(nm.get_need("hygiene") >= 0.0, "hygiene clamped >= 0")
	assert_true(nm.get_need("social") >= 0.0, "social clamped >= 0")
	assert_true(nm.get_need("fun") >= 0.0, "fun clamped >= 0")

func test_need_critical_signal() -> void:
	_reset_needs()
	nm.modify("energy", -95.0)
	assert_true(nm.get_need("energy") <= 10.0, "energy at or below critical threshold")

func test_apply_action_effects() -> void:
	_reset_needs()
	var effects = {"energy": 20.0, "hunger": -15.0, "fun": 10.0}
	nm.apply_action_effects(effects)
	assert_eq(nm.get_need("energy"), 100.0, "energy clamped at 100")
	assert_eq(nm.get_need("hunger"), 85.0, "hunger decreased by 15")
	assert_eq(nm.get_need("fun"), 100.0, "fun clamped at 100")
	assert_eq(nm.get_need("social"), 100.0, "social unchanged")
	assert_eq(nm.get_need("hygiene"), 100.0, "hygiene unchanged")

func test_get_all_needs() -> void:
	var all = nm.get_all_needs()
	assert_eq(all.size(), 5, "5 need types")
	assert_eq(all["energy"], 100.0, "energy in snapshot")

func test_modify_beyond_100_clamps() -> void:
	nm.modify("energy", 50.0)
	assert_eq(nm.get_need("energy"), 100.0, "energy clamped to 100")

func test_modify_below_0_clamps() -> void:
	nm.modify("energy", -200.0)
	assert_eq(nm.get_need("energy"), 0.0, "energy clamped to 0")
