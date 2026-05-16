class_name CareerTrackData
extends Resource

# Career progression track. Each level is a Dictionary with keys:
#   title (String), pay_multiplier (float), shifts_required (int), performance_required (float)
@export var id: String = ""
@export var name: String = ""
@export var levels: Array[Dictionary] = []
