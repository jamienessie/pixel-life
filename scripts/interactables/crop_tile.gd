extends Area2D

# CropTile (M9 RAI-36) — one farm plot the player can till/plant/water/harvest.
# State lives in FarmingSystem keyed by (zone_id, tile_index). The tile only
# reflects state visually + routes interactions.

@export var zone_id: String = "farm"
@export var tile_index: int = 0
# Default crop planted when the player interacts with a tilled tile and has
# only one viable seed in inventory; otherwise the player picks from a menu.
@export var default_crop_id: String = "tomato"

@onready var _sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var _label: Label = $StageLabel if has_node("StageLabel") else null

# Color tints stand in for sprites until tile art is imported.
const STAGE_COLORS := {
	"dirt":    Color(0.45, 0.32, 0.20),
	"tilled":  Color(0.30, 0.20, 0.12),
	"planted": Color(0.30, 0.50, 0.20),
	"growing": Color(0.35, 0.65, 0.25),
	"grown":   Color(0.95, 0.75, 0.20),
	"withered":Color(0.25, 0.25, 0.20),
}

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("crop_tile")
	FarmingSystem.crop_state_changed.connect(_on_state_changed)
	_refresh_visual()
	_install_prompt()

func _install_prompt() -> void:
	if has_node("InteractablePrompt"):
		return
	var prompt_scene := load("res://scenes/ui/interactable_prompt.tscn")
	if prompt_scene == null:
		return
	var inst := prompt_scene.instantiate()
	set_meta("prompt_text", "[E] Tend")
	add_child(inst)

func interact() -> Dictionary:
	# Single-button cycle (E): tills dirt, waters planted, harvests grown, plants from default seed when tilled.
	var s := FarmingSystem.get_tile_state(zone_id, tile_index)
	match s.stage:
		FarmingSystem.STAGE_DIRT, FarmingSystem.STAGE_WITHERED:
			var ok := FarmingSystem.till(zone_id, tile_index)
			return {"ok": ok, "action": "till"}
		FarmingSystem.STAGE_TILLED:
			var crop_to_plant := _pick_crop_to_plant()
			if crop_to_plant == "":
				return {"ok": false, "action": "plant", "reason": "no_seeds"}
			var ok2 := FarmingSystem.plant(zone_id, tile_index, crop_to_plant)
			return {"ok": ok2, "action": "plant", "crop": crop_to_plant}
		FarmingSystem.STAGE_PLANTED, FarmingSystem.STAGE_GROWING:
			var ok3 := FarmingSystem.water(zone_id, tile_index)
			return {"ok": ok3, "action": "water"}
		FarmingSystem.STAGE_GROWN:
			var res := FarmingSystem.harvest(zone_id, tile_index)
			res["action"] = "harvest"
			return res
		_:
			return {"ok": false, "action": "none"}

func _pick_crop_to_plant() -> String:
	# Prefer default if its seed is in inventory and season matches.
	var crop = load(FarmingSystem.CROP_PATH % default_crop_id)
	if crop != null \
		and (crop.seasons.is_empty() or crop.seasons.has(TimeManager.season)) \
		and InventoryManager.count(crop.seed_item_id) > 0:
		return default_crop_id
	# Else first seed found in inventory whose season matches.
	for crop_id in ["tomato", "wheat", "pumpkin", "potato"]:
		var c = load(FarmingSystem.CROP_PATH % crop_id)
		if c == null:
			continue
		if not c.seasons.is_empty() and not c.seasons.has(TimeManager.season):
			continue
		if InventoryManager.count(c.seed_item_id) > 0:
			return crop_id
	return ""

func _on_state_changed(z: String, idx: int) -> void:
	if z == zone_id and idx == tile_index:
		_refresh_visual()

func _refresh_visual() -> void:
	var s := FarmingSystem.get_tile_state(zone_id, tile_index)
	var stage_key: String = s.stage
	var color: Color = STAGE_COLORS.get(stage_key, Color.MAGENTA)
	if _sprite != null and _sprite.texture == null:
		_sprite.self_modulate = color
	if _label != null:
		var txt: String = stage_key
		if stage_key == FarmingSystem.STAGE_GROWING:
			txt = "growing %d" % int(s.growth_step)
		elif stage_key == FarmingSystem.STAGE_PLANTED or stage_key == FarmingSystem.STAGE_GROWING:
			if bool(s.watered_today):
				txt += " ✓"
		_label.text = txt
