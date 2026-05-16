extends Node

# AchievementManager (RAI-50) — listens to EventBus signals and unlocks
# achievements when their trigger conditions match. Persisted in
# active_character.unlocks.achievements[].

const _reg_achievement_data := preload("res://resources/achievement_data.gd")
const ACHIEVEMENT_PATH := "res://data/achievements/%s.tres"
const IDS: Array[String] = [
	"first_job", "first_kiss", "married", "first_child",
	"first_harvest", "first_fish", "first_painting", "first_promotion",
	"first_house_upgrade", "lived_to_30", "lived_to_60", "succession_to_child",
]

signal achievement_unlocked(achievement_id: String)

func _ready() -> void:
	EventBus.job_assigned.connect(_on_job_assigned)
	EventBus.relationship_changed.connect(_on_relationship_changed)
	EventBus.marriage_completed.connect(_on_marriage_completed)
	EventBus.child_born.connect(_on_child_born)
	EventBus.item_acquired.connect(_on_item_acquired)
	EventBus.job_level_up.connect(_on_job_level_up)
	EventBus.house_upgraded.connect(_on_house_upgraded)
	EventBus.year_passed.connect(_on_year_passed)
	EventBus.playable_character_switched.connect(_on_succession)

func _unlocked() -> Array:
	if GameState.active_character == null:
		return []
	var d: Dictionary = GameState.active_character.unlocks
	return d.get("achievements", [])

func _unlock(id: String) -> void:
	if GameState.active_character == null:
		return
	var ach := load_achievement(id)
	if ach == null:
		return
	var d: Dictionary = GameState.active_character.unlocks
	var arr: Array = d.get("achievements", [])
	if arr.has(id):
		return
	arr.append(id)
	d["achievements"] = arr
	GameState.active_character.unlocks = d
	if ach.reward_money > 0:
		EconomyManager.add_money(ach.reward_money)
	if ach.reward_item_id != "" and ach.reward_item_qty > 0:
		InventoryManager.add(ach.reward_item_id, ach.reward_item_qty)
	AudioManager.play_sfx("sfx_achievement_unlock")
	achievement_unlocked.emit(id)

func is_unlocked(id: String) -> bool:
	return _unlocked().has(id)

func load_achievement(id: String) -> AchievementData:
	return load(ACHIEVEMENT_PATH % id)

func all_ids() -> Array[String]:
	return IDS

# --- Event handlers ---

func _on_job_assigned(_job_id: String) -> void:
	_unlock("first_job")

func _on_relationship_changed(_npc_id: String, _value: float, stage: String) -> void:
	if stage == "dating" or stage == "engaged" or stage == "married":
		_unlock("first_kiss")

func _on_marriage_completed(_npc_id: String) -> void:
	_unlock("married")

func _on_child_born(_child_id: String) -> void:
	_unlock("first_child")

func _on_item_acquired(item_id: String, _qty: int) -> void:
	# Crop items.
	if item_id in ["tomato", "wheat", "pumpkin", "potato", "corn"]:
		_unlock("first_harvest")
	if item_id in ["sardine", "bass", "salmon", "tuna", "legendary_pike"]:
		_unlock("first_fish")
	if item_id.begins_with("painting_"):
		_unlock("first_painting")

func _on_job_level_up(_job_id: String, _level: int) -> void:
	_unlock("first_promotion")

func _on_house_upgraded(_tier: int) -> void:
	_unlock("first_house_upgrade")

func _on_year_passed(_year: int) -> void:
	if GameState.active_character == null:
		return
	var age: int = GameState.active_character.age
	if age >= 30:
		_unlock("lived_to_30")
	if age >= 60:
		_unlock("lived_to_60")

func _on_succession(_new_actor_id: String) -> void:
	_unlock("succession_to_child")
