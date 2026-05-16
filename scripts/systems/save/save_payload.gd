class_name SavePayload
extends Resource

# Force class_name registration of types referenced in @export.
const _reg_character_profile := preload("res://resources/character_profile.gd")
const _reg_family_tree := preload("res://resources/family_tree.gd")

@export var version: int = 4
@export var created_at_unix: int = 0
@export var time_state: Dictionary = {}
@export var active_character_id: String = ""
@export var current_zone: String = ""
# v1 field — kept for backwards compatibility with old saves.
@export var character_profile: Resource = null
# v2 — multi-generation
@export var family_tree: Resource = null
@export var pregnancy_state: Dictionary = {}
@export var needs_state: Dictionary = {}
@export var economy_state: Dictionary = {}
@export var inventory_state: Array = []
@export var job_state: Dictionary = {}
# v3 — world state (farming, etc.)
@export var farming_state: Dictionary = {}
# v4 — weather, festivals, audio settings
@export var weather_state: Dictionary = {}
@export var festival_state: Dictionary = {}
@export var audio_settings: Dictionary = {}
