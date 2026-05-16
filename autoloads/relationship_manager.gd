extends Node

# Force class_name registration for Resource types used in this script
const _reg_npc_data := preload("res://resources/npc_data.gd")

var _relationships := {}

const STAGE_THRESHOLDS := [
	{"stage": "stranger", "min": -100.0, "max": 29.0},
	{"stage": "acquaintance", "min": 30.0, "max": 49.0},
	{"stage": "friend", "min": 50.0, "max": 69.0},
	{"stage": "close_friend", "min": 70.0, "max": 89.0},
	{"stage": "dating", "min": 90.0, "max": 94.0},
	{"stage": "engaged", "min": 95.0, "max": 98.0},
	{"stage": "married", "min": 99.0, "max": 100.0},
]

func get_relationship_value(npc_id: String) -> float:
	var rel = _relationships.get(npc_id, {"value": 0.0, "stage": "stranger"})
	return rel.value

func modify(npc_id: String, delta: float) -> void:
	var rel = _relationships.get(npc_id, {"value": 0.0, "stage": "stranger"})
	rel.value = clampf(rel.value + delta, -100.0, 100.0)
	rel.stage = _compute_stage(rel.value)
	_relationships[npc_id] = rel
	EventBus.relationship_changed.emit(npc_id, rel.value, rel.stage)

func get_stage(npc_id: String) -> String:
	var rel = _relationships.get(npc_id, {"value": 0.0, "stage": "stranger"})
	rel.stage = _compute_stage(rel.value)
	return rel.stage

func try_advance_stage(npc_id: String) -> bool:
	var rel = _relationships.get(npc_id, {"value": 0.0, "stage": "stranger"})
	var current_stage = _compute_stage(rel.value)
	var current_idx = _stage_index(current_stage)
	if current_idx < 0 or current_idx >= STAGE_THRESHOLDS.size() - 1:
		return false
	var next_threshold = STAGE_THRESHOLDS[current_idx + 1]
	rel.value = maxf(rel.value, next_threshold.min)
	rel.stage = _compute_stage(rel.value)
	_relationships[npc_id] = rel
	EventBus.relationship_changed.emit(npc_id, rel.value, rel.stage)
	return true

func propose_marriage(npc_id: String) -> bool:
	var rel = _relationships.get(npc_id, {"value": 0.0, "stage": "stranger"})
	if rel.stage != "engaged":
		return false
	var success = true
	if success:
		rel.stage = "married"
		rel.value = 100.0
		_relationships[npc_id] = rel
		EventBus.relationship_changed.emit(npc_id, rel.value, rel.stage)
		EventBus.marriage_completed.emit(npc_id)
	return success

func _compute_stage(value: float) -> String:
	for i in range(STAGE_THRESHOLDS.size() - 1, -1, -1):
		var t = STAGE_THRESHOLDS[i]
		if value >= t.min:
			return t.stage
	return "stranger"

func _stage_index(stage: String) -> int:
	for i in range(STAGE_THRESHOLDS.size()):
		if STAGE_THRESHOLDS[i].stage == stage:
			return i
	return -1

func _get_npc_data(npc_id: String) -> Resource:
	return load("res://data/npcs/%s.tres" % npc_id)

func get_stage_thresholds() -> Array:
	return STAGE_THRESHOLDS.duplicate()

func reset() -> void:
	_relationships.clear()

func get_all_relationships() -> Dictionary:
	return _relationships.duplicate()
