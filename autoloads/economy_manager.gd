extends Node

var _money := 0

func get_money() -> int:
	return _money

func set_money(amount: int) -> void:
	_money = amount
	EventBus.money_changed.emit(_money, 0)

func add_money(amount: int) -> void:
	_money += amount
	EventBus.money_changed.emit(_money, amount)

func try_spend(amount: int) -> bool:
	if _money >= amount:
		_money -= amount
		EventBus.money_changed.emit(_money, -amount)
		return true
	return false

func price_of(item_id: String) -> int:
	var item = load("res://data/items/%s.tres" % item_id)
	if item != null and item is Resource and item.get("base_buy_price") != null:
		return item.base_buy_price
	return 0

func sell_value(item_id: String) -> int:
	var item = load("res://data/items/%s.tres" % item_id)
	if item != null and item is Resource and item.get("base_sell_price") != null:
		return item.base_sell_price
	return 0
