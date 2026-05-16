class_name CropData
extends Resource

# Crop definition for the farming system (M9 RAI-36).
@export var id: String = ""
@export var name: String = ""
@export var seed_item_id: String = ""        # item_id consumed when planting
@export var harvest_item_id: String = ""     # item_id produced when harvesting
@export var harvest_qty_min: int = 1
@export var harvest_qty_max: int = 1
@export var growth_stages: int = 4           # discrete growth steps; sprite frames map 1:1
@export var days_per_stage: int = 1          # game-days between stages when watered
@export var seasons: Array[String] = []      # ["spring","summer","autumn","winter"]; empty = any
@export var regrow: bool = false             # if true, after harvest returns to last-but-one stage
@export var regrow_days: int = 0             # days to recycle when regrow
@export var water_required: bool = true      # if false, advances each day regardless
@export var withers_in_wrong_season: bool = true
