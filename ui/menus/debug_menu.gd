extends Control

# Developer debug menu (F1) — speed-up, kill, marry, conceive, year-skip.

const _reg_npc_data := preload("res://resources/npc_data.gd")

const NPC_IDS := ["anna", "bryan", "cora"]

@onready var _time_label: Label = $Panel/VBoxContainer/TimeLabel
@onready var _speed_slider: HSlider = $Panel/VBoxContainer/SpeedSlider
@onready var _speed_value_label: Label = $Panel/VBoxContainer/SpeedValueLabel
@onready var _kill_button: Button = $Panel/VBoxContainer/KillButton
@onready var _skip_year_button: Button = $Panel/VBoxContainer/SkipYearButton
@onready var _conceive_button: Button = $Panel/VBoxContainer/ConceiveButton
@onready var _grant_degree_button: Button = $Panel/VBoxContainer/GrantDegreeButton
@onready var _study_button: Button = $Panel/VBoxContainer/StudyButton
@onready var _free_cash_button: Button = $Panel/VBoxContainer/FreeCashButton
@onready var _marriage_container: VBoxContainer = $Panel/VBoxContainer/MarriageContainer
@onready var _close_button: Button = $Panel/VBoxContainer/CloseButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_speed_slider.min_value = 1.0
	_speed_slider.max_value = 600.0
	_speed_slider.value = 1.0
	_speed_slider.step = 1.0
	_speed_slider.value_changed.connect(_on_speed_changed)
	_kill_button.pressed.connect(_on_kill)
	_skip_year_button.pressed.connect(_on_skip_year)
	_conceive_button.pressed.connect(_on_conceive)
	_grant_degree_button.pressed.connect(_on_grant_degree)
	_study_button.pressed.connect(_on_study)
	_free_cash_button.pressed.connect(_on_free_cash)
	_close_button.pressed.connect(toggle)
	_build_marriage_buttons()
	EventBus.minute_passed.connect(_on_minute)

func toggle() -> void:
	visible = not visible
	if visible:
		_refresh()

func _refresh() -> void:
	_update_time_label()
	_speed_value_label.text = "Speed: %dx" % int(_speed_slider.value)

func _build_marriage_buttons() -> void:
	for child in _marriage_container.get_children():
		child.queue_free()
	var header := Label.new()
	header.text = "Force marriage:"
	_marriage_container.add_child(header)
	for npc_id in NPC_IDS:
		var btn := Button.new()
		btn.text = "Marry %s" % npc_id.capitalize()
		var captured: String = npc_id
		btn.pressed.connect(func(): _force_marriage(captured))
		_marriage_container.add_child(btn)

func _on_minute(_m: int) -> void:
	if visible:
		_update_time_label()

func _update_time_label() -> void:
	if GameState.active_character != null:
		_time_label.text = "%s, Year %d, %s Day %d, %02d:%02d  •  Age %d" % [
			GameState.active_character.character_name,
			TimeManager.year, TimeManager.season.capitalize(), TimeManager.day,
			TimeManager.hour, TimeManager.minute,
			GameState.active_character.age,
		]
	else:
		_time_label.text = "Year %d, %s Day %d, %02d:%02d" % [
			TimeManager.year, TimeManager.season.capitalize(), TimeManager.day,
			TimeManager.hour, TimeManager.minute,
		]

func _on_speed_changed(v: float) -> void:
	TimeManager.set_time_scale(v)
	_speed_value_label.text = "Speed: %dx" % int(v)

func _on_kill() -> void:
	if GameState.active_character == null:
		return
	# Force-age to LIFE_EXPECTANCY_MAX so try_die is guaranteed.
	GameState.active_character.age = FamilyManager.LIFE_EXPECTANCY_MAX + 1
	FamilyManager.try_die(GameState.active_character.id)

func _on_skip_year() -> void:
	TimeManager.year += 1
	EventBus.year_passed.emit(TimeManager.year)

func _on_conceive() -> void:
	FamilyManager.try_conceive()

func _on_grant_degree() -> void:
	if GameState.active_character != null:
		GameState.active_character.unlocks["degree"] = true
		GameState.active_character.unlocks["diploma"] = true

func _on_study() -> void:
	HouseManager.study_for_hours(2)
	_update_time_label()

func _on_free_cash() -> void:
	EconomyManager.add_money(10000)

func _force_marriage(npc_id: String) -> void:
	# Force-advance relationship and fire marriage_completed.
	RelationshipManager.modify(npc_id, 200.0)
	RelationshipManager.propose_marriage(npc_id)
