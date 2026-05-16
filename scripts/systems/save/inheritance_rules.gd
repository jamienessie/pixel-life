# Inheritance rules for succession system (M12).
# Centralized, pure-function logic. Static so the test can call via `load(...).method()`.
# `family_tree` is duck-typed (must expose .get_member_by_id) so mocks work in tests.

const ADULT_AGE := 18

static func determine_heirs(deceased: CharacterProfile, family_tree) -> Array:
	var heirs: Array = []

	# Rule 1: House inheritance.
	var house_heir := _determine_house_heir(deceased, family_tree)
	if house_heir != "":
		heirs.append({
			"character_id": house_heir,
			"inheritance_type": "house",
			"percentage": 100,
		})

	# Rule 2: Money inheritance.
	var money_heirs := _determine_money_heirs(deceased, family_tree)
	heirs.append_array(money_heirs)

	# Rule 3: Relationships are NOT transferred (per design).
	return heirs

static func _determine_house_heir(deceased: CharacterProfile, family_tree) -> String:
	# Spouse if alive.
	if deceased.spouse != "":
		var spouse = family_tree.get_member_by_id(deceased.spouse)
		if spouse != null and not spouse.deceased:
			return deceased.spouse
	# Else eldest adult child.
	var adult_children: Array = []
	for child_id in deceased.children:
		var child = family_tree.get_member_by_id(child_id)
		if child != null and not child.deceased and child.age >= ADULT_AGE:
			adult_children.append(child)
	if adult_children.size() > 0:
		adult_children.sort_custom(func(a, b): return b.age < a.age)
		return adult_children[0].id
	return ""

static func _determine_money_heirs(deceased: CharacterProfile, family_tree) -> Array:
	var heirs: Array = []
	var has_living_spouse := false
	if deceased.spouse != "":
		var spouse = family_tree.get_member_by_id(deceased.spouse)
		if spouse != null and not spouse.deceased:
			has_living_spouse = true

	var living_children: Array = []
	for child_id in deceased.children:
		var child = family_tree.get_member_by_id(child_id)
		if child != null and not child.deceased:
			living_children.append(child_id)
	var children_count := living_children.size()

	if has_living_spouse:
		heirs.append({
			"character_id": deceased.spouse,
			"inheritance_type": "money",
			"percentage": 50.0,
		})
		if children_count > 0:
			var per_child := 50.0 / float(children_count)
			for child_id in living_children:
				heirs.append({
					"character_id": child_id,
					"inheritance_type": "money",
					"percentage": per_child,
				})
	else:
		if children_count > 0:
			var per_child := 100.0 / float(children_count)
			for child_id in living_children:
				heirs.append({
					"character_id": child_id,
					"inheritance_type": "money",
					"percentage": per_child,
				})
	return heirs
