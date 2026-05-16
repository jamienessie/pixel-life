class_name FestivalData
extends Resource

# FestivalData (RAI-48) — seasonal town event.
@export var id: String = ""
@export var name: String = ""
@export var season: String = ""     # "spring" | "summer" | "autumn" | "winter"
@export var day_of_season: int = 14
@export var zone_id: String = "town"
@export var blurb: String = ""
# Optional spawn overrides: npc_id -> zone_id (force-attend the festival).
@export var npc_overrides: Dictionary = {}
