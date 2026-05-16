extends Node

# AudioEventBridge (RAI-42) — listens to EventBus and triggers SFX through
# AudioManager. Keeps audio coupling out of game logic; missing AudioTrackData
# .tres files silently no-op (AudioManager._load_track returns null).

func _ready() -> void:
	EventBus.sleep_completed.connect(_on_sleep_completed)
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.house_upgraded.connect(_on_house_upgraded)
	EventBus.shift_ended.connect(_on_shift_ended)
	EventBus.child_born.connect(_on_child_born)
	EventBus.marriage_completed.connect(_on_marriage_completed)
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.item_acquired.connect(_on_item_acquired)
	EventBus.player_died.connect(_on_player_died)
	EventBus.season_changed.connect(_on_season_changed)

func _on_sleep_completed() -> void:
	AudioManager.play_sfx("sfx_sleep_zzz")

func _on_money_changed(_total: int, delta: int) -> void:
	if delta > 0:
		AudioManager.play_sfx("sfx_money_chime")

func _on_house_upgraded(_tier: int) -> void:
	AudioManager.play_sfx("sfx_achievement_unlock")

func _on_shift_ended(_payout: int, _performance: float) -> void:
	AudioManager.play_sfx("sfx_shift_end")

func _on_child_born(_child_id: String) -> void:
	AudioManager.play_sfx("sfx_birth_chime")

func _on_marriage_completed(_npc_id: String) -> void:
	AudioManager.play_sfx("sfx_marriage_chime")

func _on_dialogue_started(_npc_id: String) -> void:
	AudioManager.play_sfx("sfx_dialogue_blip")

func _on_item_acquired(_item_id: String, _qty: int) -> void:
	AudioManager.play_sfx("sfx_pickup")

func _on_player_died(_cause: String) -> void:
	AudioManager.play_sfx("sfx_death")

func _on_season_changed(_season: String) -> void:
	AudioManager.play_sfx("sfx_season_change")
