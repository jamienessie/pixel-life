extends GutTest

var im: Node

func before_each() -> void:
	im = get_node("/root/InventoryManager")
	_reset_inventory()

func _reset_inventory() -> void:
	for i in im.INVENTORY_SIZE:
		im._slots[i] = null

func test_inventory_initialization() -> void:
	assert_eq(im._slots.size(), im.INVENTORY_SIZE, "inventory size correct")
	for i in im.INVENTORY_SIZE:
		assert_null(im._slots[i], "slot %d starts null" % i)

func test_add_item_to_empty_slot() -> void:
	# test_item exists in data/items/ with stack_size=999
	var success = im.add("test_item", 1)
	assert_true(success, "add test_item to empty slot")
	assert_not_null(im._slots[0], "first slot occupied")
	assert_eq(im._slots[0]["id"], "test_item", "item id matches")
	assert_eq(im._slots[0]["quantity"], 1, "quantity == 1")

func test_add_item_partial_stack() -> void:
	# stackable_item exists in data/items/ with stack_size=100
	assert_true(im.add("stackable_item", 50), "add 50")
	assert_eq(im._slots[0]["quantity"], 50, "first stack = 50")

	assert_true(im.add("stackable_item", 30), "add 30 to existing")
	assert_eq(im._slots[0]["quantity"], 80, "stack now 80")
	assert_null(im._slots[1], "second slot untouched")

func test_add_item_full_stack_overflow() -> void:
	# stackable_item has stack_size=100
	assert_true(im.add("stackable_item", 100), "fill stack to 100")
	assert_eq(im._slots[0]["quantity"], 100, "stack at max")

	assert_true(im.add("stackable_item", 1), "overflow to new slot")
	assert_eq(im._slots[0]["quantity"], 100, "first stack unchanged")
	assert_eq(im._slots[1]["quantity"], 1, "overflow quantity 1")
	assert_eq(im._slots[1]["id"], "stackable_item", "overflow item matches")

func test_add_item_full_inventory() -> void:
	# Fill all slots using fishing_rod (stack_size=1, each add uses a new slot)
	var filled := 0
	for i in im.INVENTORY_SIZE:
		if im.add("fishing_rod", 1):
			filled += 1
		else:
			break
	assert_eq(filled, im.INVENTORY_SIZE, "filled all %d slots" % im.INVENTORY_SIZE)

	var success = im.add("test_item", 1)
	assert_false(success, "cannot add to full inventory")

func test_remove_item_partial() -> void:
	im.add("test_item", 100)
	assert_true(im.remove("test_item", 30), "remove partial")
	assert_eq(im._slots[0]["quantity"], 70, "70 remaining")

func test_remove_item_complete() -> void:
	im.add("test_item", 50)
	assert_true(im.remove("test_item", 50), "remove complete")
	assert_null(im._slots[0], "slot empty after complete removal")

func test_remove_nonexistent_item() -> void:
	assert_false(im.remove("nonexistent_item", 1), "cannot remove nonexistent item")

func test_move_slot() -> void:
	im.add("test_item", 1)
	im.add("wood", 1)
	assert_true(im.move_slot(0, 2), "move slot 0 to 2")
	assert_eq(im._slots[2]["id"], "test_item", "test_item in slot 2")
	assert_null(im._slots[0], "slot 0 empty after move")
	assert_eq(im._slots[1]["id"], "wood", "wood remains in slot 1")

func test_move_slot_invalid_indices() -> void:
	im.add("test_item", 1)
	assert_false(im.move_slot(-1, 0), "negative from index rejected")
	assert_false(im.move_slot(im.INVENTORY_SIZE, 0), "from beyond size rejected")
	assert_false(im.move_slot(0, -1), "negative to index rejected")
	assert_false(im.move_slot(0, im.INVENTORY_SIZE), "to beyond size rejected")

func test_move_slot_same_index() -> void:
	im.add("test_item", 1)
	assert_true(im.move_slot(0, 0), "same index is no-op")
	assert_eq(im._slots[0]["id"], "test_item", "item unchanged")

func test_count_items() -> void:
	assert_eq(im.count("nonexistent"), 0, "count 0 for missing item")
	im.add("test_item", 5)
	assert_eq(im.count("test_item"), 5, "count 5 after add")
	im.add("test_item", 3)
	assert_eq(im.count("test_item"), 8, "count 8 after stacking")

func test_count_multiple_slots() -> void:
	# Fill one slot then overflow to create second slot
	# stackable_item stack_size=100
	im.add("stackable_item", 180)
	assert_eq(im.count("stackable_item"), 180, "count across multiple slots")

func test_remove_from_multi_slot() -> void:
	im.add("stackable_item", 180)
	assert_true(im.remove("stackable_item", 50), "remove across slots")
	assert_eq(im.count("stackable_item"), 130, "130 remaining after multi-slot remove")

func test_add_zero_or_negative() -> void:
	assert_false(im.add("test_item", 0), "cannot add 0 items")
	assert_false(im.add("test_item", -1), "cannot add negative items")

func test_remove_zero_or_negative() -> void:
	assert_false(im.remove("test_item", 0), "cannot remove 0 items")
	assert_false(im.remove("test_item", -1), "cannot remove negative items")

func test_serialize_inventory() -> void:
	im.add("test_item", 5)
	im.add("wood", 3)
	var data = im.serialize_inventory()
	assert_eq(data.size(), im.INVENTORY_SIZE, "serialized size matches")
	var non_null = 0
	for slot in data:
		if slot != null:
			non_null += 1
	assert_eq(non_null, 2, "2 non-null slots")

func test_deserialize_inventory() -> void:
	_reset_inventory()
	im.add("test_item", 5)
	var data = im.serialize_inventory()
	_reset_inventory()
	im.deserialize_inventory(data)
	assert_eq(im.count("test_item"), 5, "restored count after deserialize")

func test_get_slot() -> void:
	im.add("test_item", 7)
	var slot = im.get_slot(0)
	assert_not_null(slot, "slot 0 has item")
	assert_eq(slot["id"], "test_item", "slot item id matches")
	assert_eq(slot["quantity"], 7, "slot quantity matches")
	assert_null(im.get_slot(1), "slot 1 is empty")
	assert_null(im.get_slot(-1), "negative index returns null")
	assert_null(im.get_slot(im.INVENTORY_SIZE), "out-of-range returns null")
