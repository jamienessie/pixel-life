class_name RecipeData
extends Resource

# RecipeData (RAI-51) — crafting recipe used at workbench/cooking station.
@export var id: String = ""
@export var name: String = ""
@export var inputs: Dictionary = {}   # item_id -> qty
@export var outputs: Dictionary = {}  # item_id -> qty
@export var station: String = "kitchen"   # "kitchen" | "workbench" | "easel"
@export var time_minutes: int = 30
@export var description: String = ""
