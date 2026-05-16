extends Resource
class_name FurnitureData

## Defines a placeable furniture item for the build/buy system.
## Grid-snapped placement persisted via world_state.owned_furniture.

@export var id: String = ""
@export var item_id: String = ""
@export var display_name: String = ""
@export var placed_scene: PackedScene
@export var footprint: Vector2i = Vector2i(1, 1)
@export var provides_action: String = ""
@export var cost: int = 0
@export var category: String = "general"
@export var min_house_tier: int = 1
## Passive effects granted while owned. Aggregated by HouseManager.get_effect(name).
## Examples:
##   {"sleep_energy_bonus": 25}          — bed: add 25 energy refill on sleep
##   {"painter_perf_bonus": 0.1}         — easel: +0.1 to painter shift performance
##   {"study_speed_multiplier": 1.5}     — bookshelf: study 1.5x faster
##   {"comfort_bonus": 1}                — chair/table: small ambient
@export var effects: Dictionary = {}
@export var description: String = ""
