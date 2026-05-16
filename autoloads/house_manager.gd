extends Node

# HouseManager — M10.
# Tracks owned furniture, applies their passive effects, handles house tier upgrades,
# and spawns the house entrance + bed interactable into the world at the right times.

const _reg_furniture_data := preload("res://resources/furniture_data.gd")
const _reg_house_tier_data := preload("res://resources/house_tier_data.gd")

const FURNITURE_PATH := "res://data/furniture/%s.tres"
const HOUSE_TIER_PATH := "res://data/houses/%s.tres"
const HOUSE_INTERIOR_ZONE := "interior_tier%d"

const TIER_IDS := {
	1: "tier1_shack",
	2: "tier2_cottage",
	3: "tier3_house",
	4: "tier4_mansion",
}

const FURNITURE_IDS := [
	"bed_single", "bed_double", "bookshelf", "easel", "workbench", "chair", "table_small",
]

func _ready() -> void:
	EventBus.zone_changed.connect(_on_zone_changed)
	EventBus.hour_passed.connect(_on_hour_passed)
	EventBus.sleep_completed.connect(_on_sleep_completed)

# ---------- Ownership ----------

func owned_furniture() -> Array:
	if GameState.active_character == null:
		return []
	return GameState.active_character.owned_furniture

func owns(furniture_id: String) -> bool:
	return owned_furniture().has(furniture_id)

func buy_furniture(furniture_id: String) -> bool:
	if GameState.active_character == null:
		return false
	if owns(furniture_id):
		return false
	var data := load_furniture(furniture_id)
	if data == null:
		return false
	if GameState.active_character.house_tier < data.min_house_tier:
		return false
	if not EconomyManager.try_spend(data.cost):
		return false
	GameState.active_character.owned_furniture.append(furniture_id)
	return true

func sell_furniture(furniture_id: String) -> bool:
	if not owns(furniture_id):
		return false
	var data := load_furniture(furniture_id)
	if data == null:
		return false
	GameState.active_character.owned_furniture.erase(furniture_id)
	EconomyManager.add_money(int(data.cost * 0.5))
	return true

# ---------- House tiers ----------

func current_tier() -> int:
	if GameState.active_character == null:
		return 1
	return GameState.active_character.house_tier

func current_tier_data() -> HouseTierData:
	return load_tier(current_tier())

func can_upgrade_to(tier: int) -> bool:
	if tier <= current_tier() or tier > 4:
		return false
	var data := load_tier(tier)
	if data == null:
		return false
	return EconomyManager.get_money() >= data.cost

func buy_house_upgrade(tier: int) -> bool:
	if not can_upgrade_to(tier):
		return false
	var data := load_tier(tier)
	if not EconomyManager.try_spend(data.cost):
		return false
	GameState.active_character.house_tier = tier
	EventBus.house_upgraded.emit(tier)
	# If the player is currently inside the old interior, swap them to the new tier's interior.
	var zone := GameState.current_zone
	if zone.begins_with("interior_tier"):
		SceneRouter.goto_zone(HOUSE_INTERIOR_ZONE % tier, "spawn_default")
	return true

# ---------- Effects ----------

func get_effect(effect_name: String) -> float:
	var total: float = 0.0
	for fid in owned_furniture():
		var data := load_furniture(fid)
		if data == null:
			continue
		if data.effects.has(effect_name):
			total += float(data.effects[effect_name])
	return total

func is_at_home() -> bool:
	return GameState.current_zone.begins_with("interior_tier")

# ---------- Loaders ----------

func load_furniture(furniture_id: String) -> FurnitureData:
	return load(FURNITURE_PATH % furniture_id)

func load_tier(tier: int) -> HouseTierData:
	var id: String = TIER_IDS.get(tier, "")
	if id == "":
		return null
	return load(HOUSE_TIER_PATH % id)

# ---------- World wiring ----------

func _on_zone_changed(zone_id: String) -> void:
	if zone_id == "town":
		_install_town_house_entry()
	elif zone_id.begins_with("interior_tier"):
		_install_interior_bed()
		_install_interior_easel()

func _install_town_house_entry() -> void:
	var zone: Node = SceneRouter.get_current_zone()
	if zone == null:
		return
	var spawns: Node = zone.get_node_or_null("Spawns")
	var transitions: Node = zone.get_node_or_null("ZoneTransitions")
	if spawns == null or transitions == null:
		return

	# Ensure a spawn marker the interior's exit transition points at.
	if spawns.get_node_or_null("spawn_from_house") == null:
		var marker := Marker2D.new()
		marker.name = "spawn_from_house"
		marker.position = Vector2(224, 240) # left of default spawn
		spawns.add_child(marker)

	# Remove any stale entry so the destination always reflects current tier.
	var existing := transitions.get_node_or_null("to_house")
	if existing != null:
		existing.queue_free()

	var area := Area2D.new()
	area.name = "to_house"
	area.collision_layer = 16
	area.collision_mask = 2
	area.position = Vector2(208, 240)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	shape.shape = rect
	area.add_child(shape)
	var target := HOUSE_INTERIOR_ZONE % current_tier()
	area.set_meta("target_zone", target)
	area.body_entered.connect(_on_house_door_entered.bind(target))
	transitions.add_child(area)

func _on_house_door_entered(body: Node2D, target_zone: String) -> void:
	if body.is_in_group("player"):
		SceneRouter.goto_zone(target_zone, "spawn_default")

func _install_interior_bed() -> void:
	var zone: Node = SceneRouter.get_current_zone()
	if zone == null:
		return
	var interactables: Node = zone.get_node_or_null("Interactables")
	if interactables == null:
		return
	if interactables.get_node_or_null("Bed") != null:
		return
	var area := Area2D.new()
	area.name = "Bed"
	area.collision_layer = 8 # interactable layer
	area.position = Vector2(40, 40) # roughly tile (2.5, 2.5) in interior coords
	area.add_to_group("interactables_bed")
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	shape.shape = rect
	area.add_child(shape)
	area.body_entered.connect(_on_bed_body_entered)
	area.body_exited.connect(_on_bed_body_exited)
	interactables.add_child(area)

var _player_near_bed: bool = false

func _install_interior_easel() -> void:
	if not owns("easel"):
		return
	var zone: Node = SceneRouter.get_current_zone()
	if zone == null:
		return
	var interactables: Node = zone.get_node_or_null("Interactables")
	if interactables == null:
		return
	if interactables.get_node_or_null("Easel") != null:
		return
	var easel := preload("res://scenes/interactables/easel.tscn").instantiate()
	easel.name = "Easel"
	easel.position = Vector2(80, 40)
	interactables.add_child(easel)

func _on_bed_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near_bed = true

func _on_bed_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near_bed = false

func _unhandled_input(event: InputEvent) -> void:
	if not _player_near_bed:
		return
	if event.is_action_pressed("INTERACT"):
		_sleep()
		get_viewport().set_input_as_handled()

func _sleep() -> void:
	EventBus.sleep_requested.emit()
	TimeManager.advance_to_next_morning()
	# Refill energy + bed bonus
	var bonus: float = get_effect("sleep_energy_bonus")
	NeedsManager.modify("energy", 100.0 + bonus)
	var hygiene_bonus: float = get_effect("hygiene_bonus_on_sleep")
	if hygiene_bonus > 0.0:
		NeedsManager.modify("hygiene", hygiene_bonus)
	EventBus.sleep_completed.emit()

func _on_sleep_completed() -> void:
	# Placeholder for additional sleep effects.
	pass

# ---------- Per-hour effects ----------

func _on_hour_passed(_hour: int) -> void:
	if not is_at_home():
		return
	# Reduce need decay this hour by adding back some need from furniture buffs.
	var hunger_reduction := get_effect("hunger_decay_reduction")
	var fun_reduction := get_effect("fun_decay_reduction")
	var fun_bonus_per_hour := get_effect("fun_bonus_per_hour")
	if hunger_reduction > 0.0:
		NeedsManager.modify("hunger", hunger_reduction)
	if fun_reduction > 0.0:
		NeedsManager.modify("fun", fun_reduction)
	if fun_bonus_per_hour > 0.0:
		NeedsManager.modify("fun", fun_bonus_per_hour)

# ---------- Study action (bookshelf) ----------

const STUDY_DIPLOMA_THRESHOLD := 50.0
const STUDY_DEGREE_THRESHOLD := 150.0

func can_study() -> bool:
	if GameState.active_character == null:
		return false
	if not is_at_home():
		return false
	return get_effect("study_unlocks") > 0.0

func study_for_hours(hours: int) -> bool:
	if not can_study():
		return false
	var profile = GameState.active_character
	var mult: float = max(1.0, get_effect("study_speed_multiplier"))
	profile.study_progress += hours * 10.0 * mult
	if not profile.unlocks.get("diploma", false) and profile.study_progress >= STUDY_DIPLOMA_THRESHOLD:
		profile.unlocks["diploma"] = true
	if not profile.unlocks.get("degree", false) and profile.study_progress >= STUDY_DEGREE_THRESHOLD:
		profile.unlocks["degree"] = true
	# Studying takes time (cost: hours hours and energy)
	for _i in range(hours):
		NeedsManager.modify("energy", -5.0)
	# Advance time
	for _i in range(hours * 60):
		TimeManager._advance_minute()
	return true
