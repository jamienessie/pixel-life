extends GutTest

var rm: Node
var bus: Node

func before_each() -> void:
	rm = get_node("/root/RelationshipManager")
	bus = get_node("/root/EventBus")
	# Clear relationships for clean tests
	for key in rm._relationships.keys():
		rm._relationships.erase(key)

func test_initial_stranger_state() -> void:
	assert_eq(rm.get_stage("test_npc"), "stranger", "new NPC starts as stranger")

func test_get_relationship_value_default() -> void:
	assert_eq(rm.get_relationship_value("any_npc"), 0.0, "default relationship value is 0.0")

func test_modify_increases_value() -> void:
	rm.modify("test_npc", 30.0)
	assert_eq(rm.get_relationship_value("test_npc"), 30.0, "value increased to 30")

func test_modify_value_clamped_to_100() -> void:
	rm.modify("test_npc", 200.0)
	assert_eq(rm.get_relationship_value("test_npc"), 100.0, "value clamped to 100")

func test_modify_value_clamped_to_neg_100() -> void:
	rm.modify("test_npc", -200.0)
	assert_eq(rm.get_relationship_value("test_npc"), -100.0, "value clamped to -100")

func test_stage_progression_stranger_to_acquaintance() -> void:
	rm.modify("test_npc", 30.0)
	assert_eq(rm.get_stage("test_npc"), "acquaintance", "value 30 = acquaintance")

func test_stage_progression_acquaintance_to_friend() -> void:
	rm.modify("test_npc", 50.0)
	assert_eq(rm.get_stage("test_npc"), "friend", "value 50 = friend")

func test_stage_progression_friend_to_close_friend() -> void:
	rm.modify("test_npc", 70.0)
	assert_eq(rm.get_stage("test_npc"), "close_friend", "value 70 = close_friend")

func test_stage_progression_close_friend_to_dating() -> void:
	rm.modify("test_npc", 90.0)
	assert_eq(rm.get_stage("test_npc"), "dating", "value 90 = dating")

func test_stage_progression_dating_to_engaged() -> void:
	rm.modify("test_npc", 95.0)
	assert_eq(rm.get_stage("test_npc"), "engaged", "value 95 = engaged")

func test_stage_progression_engaged_to_married() -> void:
	rm.modify("test_npc", 99.0)
	assert_eq(rm.get_stage("test_npc"), "married", "value 99 = married")

func test_stage_downgrade_as_value_decreases() -> void:
	rm.modify("test_npc", 90.0)
	assert_eq(rm.get_stage("test_npc"), "dating", "value 90 = dating")
	rm.modify("test_npc", -50.0)  # Now value = 40
	assert_eq(rm.get_stage("test_npc"), "acquaintance", "dropped to acquaintance")

func test_relationship_signal_emitted() -> void:
	watch_signals(bus)
	rm.modify("signal_npc", 25.0)
	assert_signal_emitted(bus, "relationship_changed", "relationship_changed signal fired")

func test_independent_npcs() -> void:
	rm.modify("npc_a", 10.0)
	rm.modify("npc_b", 50.0)
	assert_eq(rm.get_stage("npc_a"), "stranger", "npc_a still stranger")
	assert_eq(rm.get_stage("npc_b"), "friend", "npc_b is friend")

func test_multiple_modifies_accumulate() -> void:
	rm.modify("acc_npc", 10.0)
	rm.modify("acc_npc", 15.0)
	rm.modify("acc_npc", -5.0)
	assert_eq(rm.get_relationship_value("acc_npc"), 20.0, "accumulated: 10+15-5 = 20")

func test_try_advance_stage_boosts_to_next_threshold() -> void:
	rm.modify("adv_npc", 25.0)  # stranger (0-29)
	var advanced = rm.try_advance_stage("adv_npc")
	assert_true(advanced, "try_advance_stage succeeded")
	assert_eq(rm.get_stage("adv_npc"), "acquaintance", "stage boosted to acquaintance")
	assert_true(rm.get_relationship_value("adv_npc") >= 30.0, "value boosted to next threshold")

func test_try_advance_stage_at_max_returns_false() -> void:
	rm.modify("max_npc", 100.0)  # married
	var advanced = rm.try_advance_stage("max_npc")
	assert_false(advanced, "cannot advance beyond married")

func test_propose_marriage_requires_engaged() -> void:
	rm.modify("marry_npc", 50.0)  # friend
	assert_false(rm.propose_marriage("marry_npc"), "cannot propose at friend stage")

func test_propose_marriage_succeeds_at_engaged() -> void:
	rm.modify("marry_npc", 95.0)  # engaged
	var result = rm.propose_marriage("marry_npc")
	assert_true(result, "proposal succeeds at engaged")
	assert_eq(rm.get_stage("marry_npc"), "married", "stage becomes married")
	assert_eq(rm.get_relationship_value("marry_npc"), 100.0, "value becomes 100")

func test_get_stage_thresholds() -> void:
	var thresholds = rm.get_stage_thresholds()
	assert_eq(thresholds.size(), 7, "7 stage thresholds")

func test_get_all_relationships() -> void:
	rm.modify("npc_1", 10.0)
	rm.modify("npc_2", 50.0)
	var all = rm.get_all_relationships()
	assert_eq(all.size(), 2, "2 relationships in dict")
