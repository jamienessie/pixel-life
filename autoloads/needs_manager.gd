extends Node

var _needs := {
	"energy": 100.0,
	"hunger": 100.0,
	"hygiene": 100.0,
	"social": 100.0,
	"fun": 100.0,
}

func _ready() -> void:
	EventBus.hour_passed.connect(_on_hour_passed)

func get_need(need: String) -> float:
	return _needs.get(need, 0.0)

func modify(need: String, delta: float) -> void:
	var value := clampf(_needs.get(need, 0.0) + delta, 0.0, 100.0)
	_needs[need] = value
	EventBus.need_changed.emit(need, value)
	if value <= 10.0:
		EventBus.need_critical.emit(need)

func apply_action_effects(effects: Dictionary) -> void:
	for need in effects:
		modify(need, effects[need])

const DECAY_RATES := {
	"energy": -4.0,
	"hunger": -3.0,
	"hygiene": -1.0,
	"social": -1.5,
	"fun": -2.0,
}

func get_all_needs() -> Dictionary:
	return _needs.duplicate()

func set_all_needs(data: Dictionary) -> void:
	for need in _needs:
		_needs[need] = data.get(need, 100.0)

func _on_hour_passed(_hour: int) -> void:
	for need in DECAY_RATES:
		modify(need, DECAY_RATES[need])
