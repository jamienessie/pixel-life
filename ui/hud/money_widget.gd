extends Control

@onready var _label: Label = $Label


func _ready() -> void:
	EventBus.money_changed.connect(_on_money_changed)
	_label.text = "$ %d" % EconomyManager.get_money()


func _on_money_changed(total: int, _delta: int) -> void:
	_label.text = "$ %d" % total
