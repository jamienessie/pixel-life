extends Node

const _reg_item_data := preload("res://resources/item_data.gd")

const INVENTORY_WIDTH := 6
const INVENTORY_HEIGHT := 4
const INVENTORY_SIZE := INVENTORY_WIDTH * INVENTORY_HEIGHT

var _slots: Array = []

func _ready() -> void:
	_slots.resize(INVENTORY_SIZE)
	for i in INVENTORY_SIZE:
		_slots[i] = null

func add(item_id: String, qty: int) -> bool:
	if qty <= 0:
		return false
	
	var item_data = load_item_data(item_id)
	if item_data == null:
		return false
		
	var stack_size = item_data.stack_size
	
	# Try to stack with existing items
	for i in INVENTORY_SIZE:
		if _slots[i] != null and _slots[i]["id"] == item_id:
			var current_qty = _slots[i]["quantity"]
			var available_space = stack_size - current_qty
			if available_space > 0:
				var to_add = min(qty, available_space)
				_slots[i]["quantity"] += to_add
				qty -= to_add
				if qty <= 0:
					return true
	
	# Try to place in empty slots
	if qty > 0:
		for i in INVENTORY_SIZE:
			if _slots[i] == null:
				var to_add = min(qty, stack_size)
				_slots[i] = {
					"id": item_id,
					"quantity": to_add
				}
				qty -= to_add
				if qty <= 0:
					return true
	
	# If we still have items left, inventory is full
	return qty <= 0

func remove(item_id: String, qty: int) -> bool:
	if qty <= 0:
		return false
	
	var removed = 0
	for i in INVENTORY_SIZE:
		if _slots[i] != null and _slots[i]["id"] == item_id:
			var current_qty = _slots[i]["quantity"]
			var to_remove = min(qty - removed, current_qty)
			_slots[i]["quantity"] -= to_remove
			removed += to_remove
			
			if _slots[i]["quantity"] <= 0:
				_slots[i] = null
				
			if removed >= qty:
				return true
	
	return removed >= qty

func count(item_id: String) -> int:
	var total = 0
	for i in INVENTORY_SIZE:
		if _slots[i] != null and _slots[i]["id"] == item_id:
			total += _slots[i]["quantity"]
	return total

func move_slot(from_idx: int, to_idx: int) -> bool:
	if from_idx < 0 or from_idx >= INVENTORY_SIZE:
		return false
	if to_idx < 0 or to_idx >= INVENTORY_SIZE:
		return false
	if from_idx == to_idx:
		return true
		
	_slots[to_idx] = _slots[from_idx]
	_slots[from_idx] = null
	return true

func get_slot(idx: int):
	if idx >= 0 and idx < INVENTORY_SIZE:
		return _slots[idx]
	return null

func load_item_data(item_id: String):
	# Try to load the item data resource
	var item_data = load("res://data/items/%s.tres" % item_id)
	return item_data

func serialize_inventory() -> Array:
	var result := []
	for slot in _slots:
		if slot != null and slot is Dictionary:
			result.append(slot.duplicate())
		else:
			result.append(null)
	return result

func deserialize_inventory(data: Array) -> void:
	_slots.resize(INVENTORY_SIZE)
	for i in range(min(data.size(), INVENTORY_SIZE)):
		_slots[i] = data[i] if data[i] != null else null
