extends CanvasLayer

# AchievementsMenu (RAI-50) — grid of all achievements with unlocked/locked
# state. Press A to toggle. Also shows toast on unlock.

@onready var _grid: VBoxContainer = $Panel/Grid
@onready var _close_btn: Button = $Panel/CloseButton
@onready var _toast: Label = $Toast

var _toast_timer: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide_panel()
	_close_btn.pressed.connect(close)
	AchievementManager.achievement_unlocked.connect(_on_unlocked)
	_toast.hide()

func _process(d: float) -> void:
	if _toast.visible:
		_toast_timer -= d
		if _toast_timer <= 0:
			_toast.hide()

func toggle() -> void:
	if $Panel.visible:
		close()
	else:
		open()

func open() -> void:
	$Panel.show()
	_refresh()
	get_tree().paused = true

func close() -> void:
	$Panel.hide()
	get_tree().paused = false

func hide_panel() -> void:
	$Panel.hide()

func _refresh() -> void:
	for child in _grid.get_children():
		child.queue_free()
	for id in AchievementManager.all_ids():
		var data := AchievementManager.load_achievement(id)
		if data == null:
			continue
		var row := HBoxContainer.new()
		var status := Label.new()
		var unlocked := AchievementManager.is_unlocked(id)
		status.text = "[X] " if unlocked else "[ ] "
		status.custom_minimum_size.x = 28
		row.add_child(status)
		var name_label := Label.new()
		name_label.text = data.name + "  —  " + data.description
		name_label.modulate = Color.WHITE if unlocked else Color(0.55, 0.55, 0.55, 1)
		row.add_child(name_label)
		_grid.add_child(row)

func _on_unlocked(id: String) -> void:
	var data := AchievementManager.load_achievement(id)
	if data == null:
		return
	_toast.text = "🏆 %s — %s" % [data.name, data.description]
	_toast.show()
	_toast_timer = 3.0
	if $Panel.visible:
		_refresh()
