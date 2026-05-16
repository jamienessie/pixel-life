extends Control

# Build/Buy menu — house tier upgrades + furniture purchases.

@onready var _tab: TabContainer = $Panel/MarginContainer/TabContainer
@onready var _tier_list: VBoxContainer = $Panel/MarginContainer/TabContainer/Upgrade/ScrollContainer/TierList
@onready var _tier_status: Label = $Panel/MarginContainer/TabContainer/Upgrade/StatusLabel
@onready var _furn_list: VBoxContainer = $Panel/MarginContainer/TabContainer/Furniture/ScrollContainer/FurnList
@onready var _furn_status: Label = $Panel/MarginContainer/TabContainer/Furniture/StatusLabel
@onready var _close_button: Button = $Panel/MarginContainer/CloseButton

var _is_open := false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_close_button.pressed.connect(close)
	EventBus.house_upgraded.connect(_on_house_changed)
	EventBus.money_changed.connect(_on_money_changed)

func open() -> void:
	_is_open = true
	visible = true
	_refresh()

func close() -> void:
	_is_open = false
	visible = false

func toggle() -> void:
	if _is_open:
		close()
	else:
		open()

func is_open() -> bool:
	return _is_open

func _on_house_changed(_tier: int) -> void:
	if _is_open: _refresh()

func _on_money_changed(_total: int, _delta: int) -> void:
	if _is_open: _refresh()

func _refresh() -> void:
	_refresh_tier()
	_refresh_furniture()

func _refresh_tier() -> void:
	for child in _tier_list.get_children():
		child.queue_free()
	var current_tier := HouseManager.current_tier()
	for tier in [1, 2, 3, 4]:
		var data := HouseManager.load_tier(tier)
		if data == null:
			continue
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 28)
		var label := Label.new()
		var marker := "  ← current" if tier == current_tier else ""
		label.text = "Tier %d — %s  (cost %d)%s" % [tier, data.name, data.cost, marker]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(120, 0)
		if tier <= current_tier:
			btn.text = "—"
			btn.disabled = true
		elif tier != current_tier + 1:
			btn.text = "Locked"
			btn.disabled = true
		else:
			btn.text = "Upgrade"
			btn.disabled = not HouseManager.can_upgrade_to(tier)
			var captured: int = tier
			btn.pressed.connect(func(): _upgrade(captured))
		row.add_child(btn)
		_tier_list.add_child(row)
	_tier_status.text = "Money: %d  •  Current home: %s (T%d)" % [
		EconomyManager.get_money(),
		HouseManager.current_tier_data().name if HouseManager.current_tier_data() else "?",
		current_tier,
	]

func _refresh_furniture() -> void:
	for child in _furn_list.get_children():
		child.queue_free()
	var current_tier := HouseManager.current_tier()
	for fid in HouseManager.FURNITURE_IDS:
		var data := HouseManager.load_furniture(fid)
		if data == null:
			continue
		var owned := HouseManager.owns(fid)
		var locked := data.min_house_tier > current_tier
		var row := VBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 0)
		var head := HBoxContainer.new()
		var name_lbl := Label.new()
		name_lbl.text = "%s — %d gold" % [data.display_name, data.cost]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(name_lbl)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(100, 0)
		if owned:
			btn.text = "Sell (+%d)" % int(data.cost * 0.5)
			var captured1: String = fid
			btn.pressed.connect(func(): _sell(captured1))
		elif locked:
			btn.text = "Tier %d" % data.min_house_tier
			btn.disabled = true
		else:
			btn.text = "Buy"
			btn.disabled = EconomyManager.get_money() < data.cost
			var captured2: String = fid
			btn.pressed.connect(func(): _buy(captured2))
		head.add_child(btn)
		row.add_child(head)
		var desc := Label.new()
		desc.text = "  " + data.description
		desc.modulate = Color(0.85, 0.85, 0.85)
		desc.add_theme_font_size_override("font_size", 10)
		row.add_child(desc)
		_furn_list.add_child(row)
	_furn_status.text = "Money: %d" % EconomyManager.get_money()

func _upgrade(tier: int) -> void:
	HouseManager.buy_house_upgrade(tier)
	_refresh()

func _buy(fid: String) -> void:
	HouseManager.buy_furniture(fid)
	_refresh()

func _sell(fid: String) -> void:
	HouseManager.sell_furniture(fid)
	_refresh()
