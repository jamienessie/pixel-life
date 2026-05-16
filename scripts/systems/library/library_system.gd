extends Node

# LibrarySystem (RAI-51) — Library zone offers two services:
#  * `library.study` — advances diploma/degree faster than the bookshelf,
#    no schedule lock (open any time during open hours, costs money).
#  * `library.craft` — applies a recipe at the cooking station.

const STUDY_COST := 20
const STUDY_PROGRESS := 12.0
const STUDY_HOURS := 4
const OPEN_HOUR := 7
const CLOSE_HOUR := 22

const _reg_recipe_data := preload("res://resources/recipe_data.gd")
const RECIPE_PATH := "res://data/recipes/%s.tres"
const RECIPE_IDS: Array[String] = [
	"tomato_soup", "wheat_bread", "fish_sandwich", "pumpkin_pie", "potato_chips",
]

func study() -> bool:
	var profile = GameState.active_character
	if profile == null:
		return false
	if GameState.current_zone != "library":
		return false
	if TimeManager.hour < OPEN_HOUR or TimeManager.hour >= CLOSE_HOUR:
		return false
	if not EconomyManager.try_spend(STUDY_COST):
		return false
	profile.study_progress += STUDY_PROGRESS
	if not profile.unlocks.get("diploma", false) and profile.study_progress >= HouseManager.STUDY_DIPLOMA_THRESHOLD:
		profile.unlocks["diploma"] = true
	if not profile.unlocks.get("degree", false) and profile.study_progress >= HouseManager.STUDY_DEGREE_THRESHOLD:
		profile.unlocks["degree"] = true
	NeedsManager.modify("energy", -10.0)
	NeedsManager.modify("hunger", -8.0)
	for _i in range(STUDY_HOURS * 60):
		TimeManager._advance_minute()
	return true

# Crafts the FIRST recipe whose inputs are all present in the player's inventory.
# This is a v1 — Library doesn't surface a recipe picker UI yet.
func craft() -> bool:
	for rid in RECIPE_IDS:
		var r := load_recipe(rid)
		if r == null:
			continue
		if _has_all_inputs(r):
			return _execute_recipe(r)
	return false

func craft_recipe(recipe_id: String) -> bool:
	var r := load_recipe(recipe_id)
	if r == null:
		return false
	if not _has_all_inputs(r):
		return false
	return _execute_recipe(r)

func _has_all_inputs(r: RecipeData) -> bool:
	for item_id in r.inputs.keys():
		var need: int = int(r.inputs[item_id])
		if InventoryManager.count(item_id) < need:
			return false
	return true

func _execute_recipe(r: RecipeData) -> bool:
	for item_id in r.inputs.keys():
		var need: int = int(r.inputs[item_id])
		if not InventoryManager.remove(item_id, need):
			return false
	for item_id in r.outputs.keys():
		var qty: int = int(r.outputs[item_id])
		InventoryManager.add(item_id, qty)
		EventBus.item_acquired.emit(item_id, qty)
	for _i in range(r.time_minutes):
		TimeManager._advance_minute()
	return true

func load_recipe(recipe_id: String) -> RecipeData:
	return load(RECIPE_PATH % recipe_id)
