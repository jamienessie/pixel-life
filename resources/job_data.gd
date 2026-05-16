class_name JobData
extends Resource

# Job definition for the game (M9 — Careers).
@export var id: String = ""
@export var name: String = ""
@export var category: String = "" # service | skilled | self_employed | creative
@export var career_track: String = "" # id of CareerTrackData under data/careers/
@export var shift_hours: Vector2i = Vector2i(9, 17) # x=start hour, y=end hour
@export var shift_days: Array[int] = [0, 1, 2, 3, 4] # 0=Mon ... 6=Sun
@export var base_pay_per_shift: int = 50
@export var requires_education: String = "" # "" | "diploma" | "degree"
@export var resolution: String = "auto" # auto | skill_check | minigame
@export var workplace_zone: String = "town"
@export var workplace_marker: String = "spawn_default"
