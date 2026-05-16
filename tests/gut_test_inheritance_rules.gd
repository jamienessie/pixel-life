extends GutTest

var _rules: Object

func before_each() -> void:
	_rules = load("res://scripts/systems/save/inheritance_rules.gd")

func _make_profile(id: String, spouse: String = "", children: Array = [], money: int = 0, age: int = 18, deceased: bool = false) -> CharacterProfile:
	var p = CharacterProfile.new()
	p.id = id
	p.spouse = spouse
	p.children = children.duplicate()
	p.money = money
	p.age = age
	p.deceased = deceased
	return p

func _find_heir(heirs: Array, cid: String, itype: String) -> Dictionary:
	for h in heirs:
		if h["character_id"] == cid and h["inheritance_type"] == itype:
			return h
	return {}

func _find_heirs_by_type(heirs: Array, itype: String) -> Array:
	var result = []
	for h in heirs:
		if h["inheritance_type"] == itype:
			result.append(h)
	return result

func _build_tree_with(members: Array) -> Resource:
	var tree = load("res://resources/family_tree.gd").new()
	for m in members:
		tree.add_member(m)
	return tree

func test_spouse_alive_gets_house() -> void:
	var deceased = _make_profile("deceased_001", "spouse_001", ["child_001", "child_002"], 1000)
	var spouse = _make_profile("spouse_001", "", [], 0, 30, false)
	var child1 = _make_profile("child_001", "", [], 0, 25, false)
	var child2 = _make_profile("child_002", "", [], 0, 20, false)
	var ft = _build_tree_with([deceased, spouse, child1, child2])
	var heirs = _rules.determine_heirs(deceased, ft)

	var house = _find_heir(heirs, "spouse_001", "house")
	assert_eq(house["character_id"], "spouse_001", "house goes to spouse")
	assert_eq(house["percentage"], 100, "spouse gets 100% of house")

	var money = _find_heirs_by_type(heirs, "money")
	assert_eq(money.size(), 3, "3 money heirs: spouse + 2 children")
	var sm = _find_heir(heirs, "spouse_001", "money")
	assert_eq(sm["percentage"], 50.0, "spouse gets 50% of money")
	var cm1 = _find_heir(heirs, "child_001", "money")
	assert_eq(cm1["percentage"], 25.0, "child 1 gets 25%")
	var cm2 = _find_heir(heirs, "child_002", "money")
	assert_eq(cm2["percentage"], 25.0, "child 2 gets 25%")

func test_no_spouse_eldest_adult_child_gets_house() -> void:
	var deceased = _make_profile("deceased_002", "", ["child_003", "child_004", "child_005"], 800)
	var child1 = _make_profile("child_003", "", [], 0, 15, false)
	var child2 = _make_profile("child_004", "", [], 0, 25, false)
	var child3 = _make_profile("child_005", "", [], 0, 30, false)
	var ft = _build_tree_with([deceased, child1, child2, child3])
	var heirs = _rules.determine_heirs(deceased, ft)

	var house = _find_heir(heirs, "child_005", "house")
	assert_eq(house["character_id"], "child_005", "house goes to eldest adult child")
	assert_eq(house["percentage"], 100, "100% of house")

	var money = _find_heirs_by_type(heirs, "money")
	assert_eq(money.size(), 3, "3 money heirs (all children)")
	for m in money:
		assert_true(abs(m["percentage"] - 33.333) < 0.001, "child gets ~33.33%")

func test_no_heirs() -> void:
	var deceased = _make_profile("deceased_003", "", [], 600)
	var ft = _build_tree_with([deceased])
	var heirs = _rules.determine_heirs(deceased, ft)

	var house = _find_heirs_by_type(heirs, "house")
	assert_eq(house.size(), 0, "no house heir")
	var money = _find_heirs_by_type(heirs, "money")
	assert_eq(money.size(), 0, "no money heir")

func test_money_split_spouse_one_child() -> void:
	var deceased = _make_profile("deceased_004", "spouse_002", ["child_006"], 2000)
	var spouse = _make_profile("spouse_002", "", [], 0, 30, false)
	var child = _make_profile("child_006", "", [], 0, 22, false)
	var ft = _build_tree_with([deceased, spouse, child])
	var heirs = _rules.determine_heirs(deceased, ft)

	var money = _find_heirs_by_type(heirs, "money")
	assert_eq(money.size(), 2, "2 money heirs")
	var sm = _find_heir(heirs, "spouse_002", "money")
	assert_eq(sm["percentage"], 50.0, "spouse 50%")
	var cm = _find_heir(heirs, "child_006", "money")
	assert_eq(cm["percentage"], 50.0, "child 50%")

func test_money_no_spouse_two_children() -> void:
	var deceased = _make_profile("deceased_005", "", ["child_007", "child_008"], 1500)
	var c1 = _make_profile("child_007", "", [], 0, 20, false)
	var c2 = _make_profile("child_008", "", [], 0, 25, false)
	var ft = _build_tree_with([deceased, c1, c2])
	var heirs = _rules.determine_heirs(deceased, ft)

	var money = _find_heirs_by_type(heirs, "money")
	assert_eq(money.size(), 2, "2 money heirs")
	for m in money:
		assert_eq(m["percentage"], 50.0, "each child 50%")

func test_no_money_heirs_when_no_family() -> void:
	var deceased = _make_profile("lonely_001", "", [], 1000)
	var ft = _build_tree_with([deceased])
	var heirs = _rules.determine_heirs(deceased, ft)
	var money = _find_heirs_by_type(heirs, "money")
	assert_eq(money.size(), 0, "no money heirs")

func test_spouse_deceased_falls_back_to_children() -> void:
	var deceased = _make_profile("deceased_006", "dead_spouse", ["heir_child"], 1000)
	var spouse = _make_profile("dead_spouse", "", [], 0, 35, true)
	var child = _make_profile("heir_child", "", [], 0, 28, false)
	var ft = _build_tree_with([deceased, spouse, child])
	var heirs = _rules.determine_heirs(deceased, ft)

	var house = _find_heir(heirs, "heir_child", "house")
	assert_eq(house["character_id"], "heir_child", "child gets house when spouse dead")

	var money = _find_heirs_by_type(heirs, "money")
	assert_eq(money.size(), 1, "1 money heir (no spouse)")
	assert_eq(money[0]["character_id"], "heir_child", "child gets 100% money")
	assert_eq(money[0]["percentage"], 100.0, "child gets 100%")
