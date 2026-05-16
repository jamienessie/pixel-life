extends Resource
class_name HouseTierData

## Defines a housing tier with cost, interior scene, and furniture layout.
## Used by EconomyManager for upgrades and build/buy menu for placements.

@export var tier: int = 1
@export var name: String = "Shack"
@export var cost: int = 0
@export var interior_scene: PackedScene
@export var bed_count: int = 1

## Furniture slots available at this tier. Each entry is a FurnitureData reference.
@export var furniture_slots: Array[FurnitureData] = []
