extends Node

# AudioManager (RAI-41) — owns music bus crossfading + SFX playback.
#
# Music: two AudioStreamPlayer nodes (A/B) we swap and tween between for smooth
# crossfade on zone_changed / time-of-day. Per-zone tracks live in
# data/audio/zone_music.tres as a Dictionary keyed by zone_id ->
# {"day_track_id": String, "night_track_id": String}.
#
# SFX: pool of AudioStreamPlayer nodes reused round-robin so concurrent
# overlapping sounds don't stomp each other.

const _reg_audio_track_data := preload("res://resources/audio_track_data.gd")
const AUDIO_PATH := "res://data/audio/%s.tres"
const CROSSFADE_SECONDS := 1.6
const SFX_POOL_SIZE := 8
const DAY_HOUR := 6
const NIGHT_HOUR := 19

# Static mapping of zone_id -> {day, night} music track ids.
# Track .tres files live in data/audio/; missing files no-op silently.
const ZONE_MUSIC := {
	"town":             {"day": "music_town_day",   "night": "music_town_night"},
	"farm":             {"day": "music_farm_day",   "night": "music_farm_night"},
	"forest":           {"day": "music_forest_day", "night": "music_forest_night"},
	"beach":            {"day": "music_beach_day",  "night": "music_beach_night"},
	"school":           {"day": "music_town_day",   "night": "music_town_night"},
	"library":          {"day": "music_library",    "night": "music_library"},
	"interior_tier1":   {"day": "music_home_calm",  "night": "music_home_calm"},
	"interior_tier2":   {"day": "music_home_calm",  "night": "music_home_calm"},
	"interior_tier3":   {"day": "music_home_calm",  "night": "music_home_calm"},
	"interior_tier4":   {"day": "music_home_calm",  "night": "music_home_calm"},
}

# Music bus state.
var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _active_music: AudioStreamPlayer = null
var _current_music_track_id: String = ""

# SFX pool.
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_idx: int = 0

# Volumes (linear 0..1), persisted by SaveManager.
var _master_volume: float = 1.0
var _music_volume: float = 0.8
var _sfx_volume: float = 1.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_buses()
	_setup_music_players()
	_setup_sfx_pool()
	EventBus.zone_changed.connect(_on_zone_changed)
	EventBus.hour_passed.connect(_on_hour_passed)

# ---------- Setup ----------

func _setup_buses() -> void:
	# Ensure Music + SFX buses exist; if they aren't in the project's bus layout,
	# treat the Master bus as a fallback rather than crashing.
	_ensure_bus("Music")
	_ensure_bus("SFX")

func _ensure_bus(name: String) -> void:
	if AudioServer.get_bus_index(name) >= 0:
		return
	AudioServer.add_bus()
	var idx := AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, name)
	AudioServer.set_bus_send(idx, "Master")

func _setup_music_players() -> void:
	_music_a = _make_music_player("MusicA")
	_music_b = _make_music_player("MusicB")
	add_child(_music_a)
	add_child(_music_b)
	_active_music = _music_a

func _make_music_player(name: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = name
	p.bus = "Music"
	p.volume_db = -80.0
	return p

func _setup_sfx_pool() -> void:
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.name = "SFX_%d" % i
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)

# ---------- Music ----------

func play_music(track_id: String, crossfade_sec: float = CROSSFADE_SECONDS) -> void:
	if track_id == "" or track_id == _current_music_track_id:
		return
	var data := _load_track(track_id)
	if data == null or data.stream == null:
		_current_music_track_id = track_id  # remember even if missing so we don't replay
		return
	var next_player: AudioStreamPlayer = _music_b if _active_music == _music_a else _music_a
	next_player.stream = data.stream
	next_player.volume_db = -80.0
	next_player.play()
	# Crossfade in next, out current.
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(next_player, "volume_db", data.volume_db + linear_to_db(_music_volume), crossfade_sec)
	if _active_music.playing:
		tw.tween_property(_active_music, "volume_db", -80.0, crossfade_sec)
	tw.chain().tween_callback(_active_music.stop)
	_active_music = next_player
	_current_music_track_id = track_id

func stop_music(fade_sec: float = 1.0) -> void:
	_current_music_track_id = ""
	if _active_music == null or not _active_music.playing:
		return
	var tw := create_tween()
	tw.tween_property(_active_music, "volume_db", -80.0, fade_sec)
	tw.tween_callback(_active_music.stop)

# ---------- SFX ----------

func play_sfx(track_id: String, _position_2d: Vector2 = Vector2.ZERO) -> void:
	var data := _load_track(track_id)
	if data == null or data.stream == null:
		return
	var p := _sfx_pool[_sfx_pool_idx]
	_sfx_pool_idx = (_sfx_pool_idx + 1) % SFX_POOL_SIZE
	p.stream = data.stream
	p.volume_db = data.volume_db + linear_to_db(_sfx_volume)
	if data.pitch_min < data.pitch_max:
		p.pitch_scale = randf_range(data.pitch_min, data.pitch_max)
	else:
		p.pitch_scale = data.pitch_min
	p.play()

# ---------- Volume sliders (settings menu hooks) ----------

func set_master_volume(linear: float) -> void:
	_master_volume = clampf(linear, 0.0, 1.0)
	var idx := AudioServer.get_bus_index("Master")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(_master_volume))

func set_music_volume(linear: float) -> void:
	_music_volume = clampf(linear, 0.0, 1.0)
	var idx := AudioServer.get_bus_index("Music")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(_music_volume))

func set_sfx_volume(linear: float) -> void:
	_sfx_volume = clampf(linear, 0.0, 1.0)
	var idx := AudioServer.get_bus_index("SFX")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(_sfx_volume))

func get_master_volume() -> float: return _master_volume
func get_music_volume() -> float: return _music_volume
func get_sfx_volume() -> float: return _sfx_volume

func serialize() -> Dictionary:
	return {
		"master_volume": _master_volume,
		"music_volume": _music_volume,
		"sfx_volume": _sfx_volume,
	}

func deserialize(data: Dictionary) -> void:
	set_master_volume(data.get("master_volume", 1.0))
	set_music_volume(data.get("music_volume", 0.8))
	set_sfx_volume(data.get("sfx_volume", 1.0))

# ---------- Event handlers ----------

func _on_zone_changed(zone_id: String) -> void:
	_play_zone_track(zone_id, TimeManager.hour)

func _on_hour_passed(hour: int) -> void:
	if hour == DAY_HOUR or hour == NIGHT_HOUR:
		_play_zone_track(GameState.current_zone, hour)

func _play_zone_track(zone_id: String, hour: int) -> void:
	var entry: Variant = ZONE_MUSIC.get(zone_id, null)
	if entry == null:
		return
	var is_night: bool = hour < DAY_HOUR or hour >= NIGHT_HOUR
	var track_id: String = entry.get("night", "") if is_night else entry.get("day", "")
	if track_id != "":
		play_music(track_id)

func _load_track(track_id: String) -> AudioTrackData:
	var path := AUDIO_PATH % track_id
	if not ResourceLoader.exists(path):
		return null
	return load(path)
