extends Node

# FxPlayer (RAI-43) — listens to EventBus and instances effect scenes at
# the right world location. Caps concurrent FX instances (8) to keep mobile
# render budget sane. Missing FX scenes silently no-op.

const MAX_CONCURRENT_FX := 8
const FX_PATH := "res://scenes/effects/%s.tscn"

# Event -> FX scene id mapping.
const FX_MAP := {
	"sleep":     "fx_sleep_z",
	"marriage":  "fx_marriage_hearts",
	"birth":     "fx_birth_sparkle",
	"level_up":  "fx_level_up",
	"money":     "fx_money_pop",
}

var _live_fx: Array[Node] = []

func _ready() -> void:
	EventBus.sleep_completed.connect(_on_sleep)
	EventBus.marriage_completed.connect(_on_marriage)
	EventBus.child_born.connect(_on_birth)
	EventBus.money_changed.connect(_on_money_changed)

func play_fx(fx_id: String, position: Vector2 = Vector2.ZERO, extra: Dictionary = {}) -> void:
	_prune_dead()
	if _live_fx.size() >= MAX_CONCURRENT_FX:
		return
	var path := FX_PATH % fx_id
	if not ResourceLoader.exists(path):
		return
	var scene: PackedScene = load(path)
	if scene == null:
		return
	var inst: Node = scene.instantiate()
	if inst is Node2D:
		(inst as Node2D).global_position = position
	# Pass extra params (e.g. money amount) via meta so the FX script can read them.
	for k in extra.keys():
		inst.set_meta(k, extra[k])
	get_tree().get_root().add_child(inst)
	_live_fx.append(inst)

func _prune_dead() -> void:
	var alive: Array[Node] = []
	for n in _live_fx:
		if is_instance_valid(n) and n.is_inside_tree():
			alive.append(n)
	_live_fx = alive

func _player_pos() -> Vector2:
	var p := SceneRouter.get_player()
	if p != null:
		return p.global_position
	return Vector2.ZERO

func _on_sleep() -> void:
	play_fx(FX_MAP.sleep, _player_pos())

func _on_marriage(_npc_id: String) -> void:
	play_fx(FX_MAP.marriage, _player_pos())

func _on_birth(_child_id: String) -> void:
	play_fx(FX_MAP.birth, _player_pos())

func _on_money_changed(_total: int, delta: int) -> void:
	if delta > 0:
		play_fx(FX_MAP.money, _player_pos() + Vector2(0, -16), {"delta": delta})

# Job promotion isn't on EventBus yet; JobManager calls this directly.
func play_level_up_at_player() -> void:
	play_fx(FX_MAP.level_up, _player_pos())
