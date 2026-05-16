class_name AudioTrackData
extends Resource

# AudioTrackData (RAI-41) — describes a music or SFX stream + how to play it.
@export var id: String = ""
@export var stream: AudioStream
@export var loop: bool = true
@export var volume_db: float = 0.0
@export var bus: String = "Music"
@export var pitch_min: float = 1.0
@export var pitch_max: float = 1.0
