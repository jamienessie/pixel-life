class_name AchievementData
extends Resource

# AchievementData (RAI-50) — single achievement definition.
@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var hidden: bool = false
# Trigger event name (matches an EventBus signal) and optional condition dict.
@export var trigger_event: String = ""
@export var trigger_condition: Dictionary = {}
@export var reward_money: int = 0
@export var reward_item_id: String = ""
@export var reward_item_qty: int = 0
