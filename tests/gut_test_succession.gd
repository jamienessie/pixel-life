extends GutTest

# End-to-end-ish test for succession (M12).
# Constructs a family tree directly, then applies inheritance logic by hand
# (we can't easily drive UI signals from GUT, so the controller is not exercised here).

const _reg_family_tree := preload("res://resources/family_tree.gd")

var _rules: Object

func before_each() -> void:
	_rules = load("res://scripts/systems/save/inheritance_rules.gd").new()

func _make_profile(id: String, age: int = 18, money: int = 0, house_tier: int = 1, spouse: String = "", children: Array = []) -> CharacterProfile:
	var p := CharacterProfile.new()
	p.id = id
	p.character_name = id.capitalize()
	p.age = age
	p.money = money
	p.house_tier = house_tier
	p.spouse = spouse
	p.children = children.duplicate()
	return p

func test_eligible_heirs_filters_minors_and_deceased() -> void:
	var parent := _make_profile("parent", 75, 1000, 3, "", ["child_a", "child_b", "child_c"])
	var tree := FamilyTree.new()
	tree.add_member(parent)
	tree.add_member(_make_profile("child_a", 22)) # adult, alive
	tree.add_member(_make_profile("child_b", 12)) # minor
	var dead_adult := _make_profile("child_c", 30)
	dead_adult.deceased = true
	tree.add_member(dead_adult)
	var heirs := tree.eligible_heirs("parent")
	assert_eq(heirs.size(), 1)
	assert_eq(heirs[0].id, "child_a")

func test_inheritance_distributes_money_and_house() -> void:
	var parent := _make_profile("parent", 80, 1000, 3, "spouse", ["child_a", "child_b"])
	var spouse := _make_profile("spouse", 60, 0, 1)
	var ca := _make_profile("child_a", 25, 0, 1)
	var cb := _make_profile("child_b", 22, 0, 1)
	var tree := FamilyTree.new()
	tree.add_member(parent)
	tree.add_member(spouse)
	tree.add_member(ca)
	tree.add_member(cb)
	var inheritance: Array = _rules.determine_heirs(parent, tree)
	assert_eq(inheritance.size(), 4, "1 house + 3 money entries")
	# Spouse should be the house heir.
	var house_entries := inheritance.filter(func(e): return e.inheritance_type == "house")
	assert_eq(house_entries.size(), 1)
	assert_eq(house_entries[0].character_id, "spouse")
	# Money split: 50/25/25.
	var money_entries := inheritance.filter(func(e): return e.inheritance_type == "money")
	assert_eq(money_entries.size(), 3)

func test_no_heirs_yields_empty_succession() -> void:
	var loner := _make_profile("loner", 80, 500, 1)
	var tree := FamilyTree.new()
	tree.add_member(loner)
	assert_eq(tree.eligible_heirs("loner").size(), 0)
