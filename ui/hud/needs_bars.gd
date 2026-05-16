extends Control

const NEED_COLORS := {
	"energy": Color(0.2, 0.6, 1.0),
	"hunger": Color(1.0, 0.5, 0.2),
	"hygiene": Color(0.4, 0.8, 0.4),
	"social": Color(1.0, 0.8, 0.2),
	"fun": Color(0.9, 0.3, 0.7),
}

@onready var _bars: Dictionary = {
	"energy": $VBox/EnergyBar,
	"hunger": $VBox/HungerBar,
	"hygiene": $VBox/HygieneBar,
	"social": $VBox/SocialBar,
	"fun": $VBox/FunBar,
}


func _ready() -> void:
	EventBus.need_changed.connect(_on_need_changed)
	for need in _bars:
		var bar = _bars[need]
		bar.modulate = NEED_COLORS[need]
		bar.value = NeedsManager.get_need(need)
		bar.get_node("Label").text = need.capitalize()


func _on_need_changed(need: String, value: float) -> void:
	if not _bars.has(need):
		return
	_bars[need].value = value
