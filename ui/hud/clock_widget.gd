extends VBoxContainer

@onready var time_label: Label = $TimeLabel
@onready var date_label: Label = $DateLabel

func _ready() -> void:
	EventBus.minute_passed.connect(_on_minute_passed)
	_update_display()

func _on_minute_passed(_minute: int) -> void:
	_update_display()

func _update_display() -> void:
	var tm := TimeManager
	time_label.text = "%02d:%02d" % [tm.hour, tm.minute]
	date_label.text = "Day %d, %s Y%d" % [tm.day, tm.season.capitalize(), tm.year]
