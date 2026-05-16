extends Node2D

# fx_money_pop — floating "+$N" text that drifts up and fades out.

const DURATION := 1.0
const RISE_PX := 24.0

@onready var _label: Label = $Label
var _t: float = 0.0

func _ready() -> void:
	var delta := int(get_meta("delta", 0))
	_label.text = "+$%d" % delta if delta >= 0 else "$%d" % delta

func _process(d: float) -> void:
	_t += d
	var k: float = clampf(_t / DURATION, 0.0, 1.0)
	_label.position.y = -k * RISE_PX
	_label.modulate.a = 1.0 - k
	if _t >= DURATION:
		queue_free()
