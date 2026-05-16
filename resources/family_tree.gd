class_name FamilyTree
extends Resource

# FamilyTree — spans generations (M11/M12).
# Holds every CharacterProfile ever created in this save, living + deceased.

@export var members: Array[Resource] = []
@export var active_id: String = ""
@export var deceased_ids: Array[String] = []

func get_member_by_id(member_id: String) -> CharacterProfile:
	for m in members:
		if m is CharacterProfile and m.id == member_id:
			return m
	return null

func find(id: String) -> CharacterProfile:
	return get_member_by_id(id)

func add_member(profile: CharacterProfile) -> void:
	if profile == null:
		return
	if get_member_by_id(profile.id) == null:
		members.append(profile)

func mark_deceased(member_id: String) -> void:
	var m := get_member_by_id(member_id)
	if m == null:
		return
	m.deceased = true
	if not deceased_ids.has(member_id):
		deceased_ids.append(member_id)

func adults() -> Array:
	var result: Array = []
	for m in members:
		if m is CharacterProfile and not m.deceased and m.age >= 18:
			result.append(m)
	return result

func living() -> Array:
	var result: Array = []
	for m in members:
		if m is CharacterProfile and not m.deceased:
			result.append(m)
	return result

func eligible_heirs(deceased_id: String) -> Array:
	# Adult children of the deceased who are themselves alive.
	var deceased: CharacterProfile = get_member_by_id(deceased_id)
	if deceased == null:
		return []
	var result: Array = []
	for child_id in deceased.children:
		var child = get_member_by_id(child_id)
		if child != null and not child.deceased and child.age >= 18:
			result.append(child)
	return result
