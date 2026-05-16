extends Node

# FarmingSystem (M9 RAI-36) — owns persistent crop state for the Farm zone.
# Crop tiles in the world push state changes here via tile_index; this manager
# advances growth on EventBus.day_passed and persists into SavePayload.world_state.

const _reg_crop_data := preload("res://resources/crop_data.gd")
const CROP_PATH := "res://data/crops/%s.tres"

# Stages: "dirt" (0) -> "tilled" (1) -> "planted" (2) -> "growing_N" -> "grown" -> "withered"
const STAGE_DIRT := "dirt"
const STAGE_TILLED := "tilled"
const STAGE_PLANTED := "planted"
const STAGE_GROWING := "growing"
const STAGE_GROWN := "grown"
const STAGE_WITHERED := "withered"

# Per-zone crop state. Keyed by zone_id -> { tile_index (int) -> entry dict }
# Entry shape:
# {
#   "stage": String,
#   "crop_id": String,          # "" until planted
#   "growth_step": int,         # 0..crop.growth_stages-1; advances when watered + days_per_stage met
#   "watered_today": bool,
#   "days_since_water_step": int,
#   "regrowing": bool,
# }
var _zone_crops: Dictionary = {}

# Stats for shift-resolution / minigame integration.
var _crops_harvested_today: int = 0

signal crop_state_changed(zone_id: String, tile_index: int)
signal crop_harvested(zone_id: String, tile_index: int, item_id: String, qty: int)

func _ready() -> void:
	EventBus.day_passed.connect(_on_day_passed)

func ensure_zone(zone_id: String) -> void:
	if not _zone_crops.has(zone_id):
		_zone_crops[zone_id] = {}

func get_tile_state(zone_id: String, tile_index: int) -> Dictionary:
	ensure_zone(zone_id)
	if _zone_crops[zone_id].has(tile_index):
		return _zone_crops[zone_id][tile_index]
	return {
		"stage": STAGE_DIRT,
		"crop_id": "",
		"growth_step": 0,
		"watered_today": false,
		"days_since_water_step": 0,
		"regrowing": false,
	}

func _set_tile_state(zone_id: String, tile_index: int, state: Dictionary) -> void:
	ensure_zone(zone_id)
	_zone_crops[zone_id][tile_index] = state
	crop_state_changed.emit(zone_id, tile_index)

func till(zone_id: String, tile_index: int) -> bool:
	if InventoryManager.count("hoe") <= 0:
		return false
	var s := get_tile_state(zone_id, tile_index)
	if s.stage != STAGE_DIRT and s.stage != STAGE_WITHERED:
		return false
	s.stage = STAGE_TILLED
	s.crop_id = ""
	s.growth_step = 0
	s.watered_today = false
	s.days_since_water_step = 0
	s.regrowing = false
	_set_tile_state(zone_id, tile_index, s)
	return true

func plant(zone_id: String, tile_index: int, crop_id: String) -> bool:
	var s := get_tile_state(zone_id, tile_index)
	if s.stage != STAGE_TILLED:
		return false
	var crop := _load_crop(crop_id)
	if crop == null:
		return false
	if not crop.seasons.is_empty() and not crop.seasons.has(TimeManager.season):
		return false
	if InventoryManager.count(crop.seed_item_id) <= 0:
		return false
	if not InventoryManager.remove(crop.seed_item_id, 1):
		return false
	s.stage = STAGE_PLANTED
	s.crop_id = crop_id
	s.growth_step = 0
	s.watered_today = false
	s.days_since_water_step = 0
	s.regrowing = false
	_set_tile_state(zone_id, tile_index, s)
	return true

func water(zone_id: String, tile_index: int) -> bool:
	if InventoryManager.count("watering_can") <= 0:
		return false
	var s := get_tile_state(zone_id, tile_index)
	if s.stage != STAGE_PLANTED and s.stage != STAGE_GROWING:
		return false
	if s.watered_today:
		return true
	s.watered_today = true
	_set_tile_state(zone_id, tile_index, s)
	return true

func harvest(zone_id: String, tile_index: int) -> Dictionary:
	var s := get_tile_state(zone_id, tile_index)
	if s.stage != STAGE_GROWN:
		return {"ok": false}
	var crop := _load_crop(s.crop_id)
	if crop == null:
		return {"ok": false}
	var qty := randi_range(crop.harvest_qty_min, max(crop.harvest_qty_min, crop.harvest_qty_max))
	InventoryManager.add(crop.harvest_item_id, qty)
	EventBus.item_acquired.emit(crop.harvest_item_id, qty)
	_crops_harvested_today += 1
	if crop.regrow:
		s.stage = STAGE_GROWING
		s.growth_step = max(0, crop.growth_stages - 2)
		s.regrowing = true
		s.days_since_water_step = 0
		s.watered_today = false
	else:
		s.stage = STAGE_DIRT
		s.crop_id = ""
		s.growth_step = 0
		s.watered_today = false
		s.days_since_water_step = 0
		s.regrowing = false
	_set_tile_state(zone_id, tile_index, s)
	crop_harvested.emit(zone_id, tile_index, crop.harvest_item_id, qty)
	return {"ok": true, "item": crop.harvest_item_id, "qty": qty}

func crops_harvested_today() -> int:
	return _crops_harvested_today

# Called by external systems (e.g. weather) to mark all crops watered for the day.
func water_all_in_zone(zone_id: String) -> void:
	ensure_zone(zone_id)
	for tile_index in _zone_crops[zone_id].keys():
		var s: Dictionary = _zone_crops[zone_id][tile_index]
		if s.stage == STAGE_PLANTED or s.stage == STAGE_GROWING:
			s.watered_today = true
			_zone_crops[zone_id][tile_index] = s
			crop_state_changed.emit(zone_id, tile_index)

func _on_day_passed(_day: int, season: String, _year: int) -> void:
	_crops_harvested_today = 0
	for zone_id in _zone_crops.keys():
		for tile_index in _zone_crops[zone_id].keys():
			_advance_tile(zone_id, tile_index, season)

func _advance_tile(zone_id: String, tile_index: int, season: String) -> void:
	var s: Dictionary = _zone_crops[zone_id][tile_index]
	if s.stage == STAGE_DIRT or s.stage == STAGE_TILLED or s.stage == STAGE_GROWN or s.stage == STAGE_WITHERED:
		return
	var crop := _load_crop(s.crop_id)
	if crop == null:
		return
	if crop.withers_in_wrong_season and not crop.seasons.is_empty() and not crop.seasons.has(season):
		s.stage = STAGE_WITHERED
		_zone_crops[zone_id][tile_index] = s
		crop_state_changed.emit(zone_id, tile_index)
		return
	var days_needed: int = crop.regrow_days if s.regrowing else crop.days_per_stage
	if crop.water_required and not s.watered_today:
		_zone_crops[zone_id][tile_index] = s
		return
	s.days_since_water_step += 1
	if s.days_since_water_step >= max(1, days_needed):
		s.days_since_water_step = 0
		s.growth_step += 1
		if s.stage == STAGE_PLANTED:
			s.stage = STAGE_GROWING
		if s.growth_step >= crop.growth_stages - 1:
			s.stage = STAGE_GROWN
			s.growth_step = crop.growth_stages - 1
			s.regrowing = false
	s.watered_today = false
	_zone_crops[zone_id][tile_index] = s
	crop_state_changed.emit(zone_id, tile_index)

func _load_crop(crop_id: String) -> CropData:
	if crop_id == "":
		return null
	return load(CROP_PATH % crop_id)

# Save / load
func serialize() -> Dictionary:
	# Convert tile_index int keys to strings for JSON compatibility while keeping Dict round-trip.
	var out := {}
	for zone_id in _zone_crops.keys():
		var z := {}
		for tile_index in _zone_crops[zone_id].keys():
			z[str(tile_index)] = _zone_crops[zone_id][tile_index].duplicate()
		out[zone_id] = z
	return out

func deserialize(data: Dictionary) -> void:
	_zone_crops.clear()
	for zone_id in data.keys():
		var z := {}
		var inner: Dictionary = data[zone_id]
		for k in inner.keys():
			z[int(k)] = (inner[k] as Dictionary).duplicate()
		_zone_crops[zone_id] = z

# Diagnostics
func dump_zone(zone_id: String) -> Dictionary:
	ensure_zone(zone_id)
	return _zone_crops[zone_id].duplicate(true)
