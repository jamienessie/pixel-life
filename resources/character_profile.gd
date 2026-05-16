class_name CharacterProfile
extends Resource

@export var id: String = ""
@export var character_name: String = ""
@export var gender: String = ""
@export var portrait_index: int = 0
@export var sprite_index: int = 0
@export var birth_year: int = 1
@export var age: int = 18
@export var parents: Array = []
@export var spouse: String = ""
@export var children: Array = []
@export var money: int = 0
@export var deceased: bool = false
@export var current_zone: String = "town"
@export var last_position_x: float = 240.0
@export var last_position_y: float = 240.0
# M9+M11 extensions
@export var unlocks: Dictionary = {} # e.g. {"diploma": true, "degree": true}
@export var house_tier: int = 1
@export var owned_furniture: Array[String] = []
@export var study_progress: float = 0.0 # M10: progress toward next education unlock
