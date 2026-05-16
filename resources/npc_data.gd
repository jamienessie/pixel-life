class_name NPCData
extends Resource

@export var id: String = ""
@export var npc_name: String = ""
@export var gender: String = ""
@export var birthday: Dictionary = {"day": 1, "season": "spring"}
@export var home_id: String = ""
@export var home_zone: String = ""
@export var work_job_id: String = ""
@export var sprite_set: String = ""
@export var personality_tags: Array = []
@export var loved_gifts: Array = []
@export var liked_gifts: Array = []
@export var disliked_gifts: Array = []
@export var hated_gifts: Array = []
@export var dialogue_id: String = ""
@export var schedule_id: String = ""
@export var marriageable: bool = false
@export var compatibility: Dictionary = {}
