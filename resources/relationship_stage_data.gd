class_name RelationshipStageData
extends Resource

# Relationship stage definitions
@export var stage: String = ""  # e.g., "stranger", "acquaintance", "friend", etc.
@export var min_value: float = 0.0  # Minimum relationship value for this stage
@export var max_value: float = 100.0  # Maximum relationship value for this stage
@export var unlocks: Array = []  # Array of strings describing what this stage unlocks