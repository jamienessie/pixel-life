extends Node

const _reg_character_profile := preload("res://resources/character_profile.gd")
const _reg_family_tree := preload("res://resources/family_tree.gd")

var active_character: CharacterProfile = null
var family_tree: FamilyTree = null
var current_zone: String = ""
var is_paused: bool = false

func start_new_game() -> void:
	active_character = CharacterProfile.new()
	active_character.id = "player_001"
	active_character.character_name = "Player"
	active_character.age = 18
	active_character.birth_year = 1
	active_character.house_tier = 1
	family_tree = FamilyTree.new()
	family_tree.add_member(active_character)
	family_tree.active_id = active_character.id
	current_zone = "town"
	is_paused = false
	_grant_starter_inventory()

func _grant_starter_inventory() -> void:
	# Starter tools so the farming and fishing loops are reachable on day 1.
	InventoryManager.add("hoe", 1)
	InventoryManager.add("watering_can", 1)
	InventoryManager.add("fishing_rod", 1)
	InventoryManager.add("tomato_seeds", 5)
	InventoryManager.add("potato_seeds", 3)

func ensure_family_tree() -> void:
	if family_tree != null:
		return
	family_tree = FamilyTree.new()
	if active_character != null:
		family_tree.add_member(active_character)
		family_tree.active_id = active_character.id

func switch_active_character(child_id: String) -> void:
	if family_tree == null:
		return
	var heir: CharacterProfile = family_tree.get_member_by_id(child_id)
	if heir == null or heir.deceased:
		return
	active_character = heir
	family_tree.active_id = child_id
	current_zone = heir.current_zone if heir.current_zone != "" else "town"
	EventBus.playable_character_switched.emit(child_id)

func pause() -> void:
	is_paused = true
	get_tree().paused = true

func resume() -> void:
	is_paused = false
	get_tree().paused = false
