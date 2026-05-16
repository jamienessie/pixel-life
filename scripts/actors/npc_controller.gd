extends CharacterBody2D

# Force class_name registration for Resource types used in this script
const _reg_npc_data := preload("res://resources/npc_data.gd")

const SPEED_WALK := 32.0
const TILE_SIZE := 16

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _interaction_area: Area2D = $InteractionArea

var npc_id: String = ""
var npc_data: Resource = null
var _current_direction := Vector2.DOWN
var _is_moving := false
var _target_position: Vector2 = Vector2.ZERO
var _has_target := false

func setup(data: Resource) -> void:
	npc_id = data.id
	npc_data = data
	add_to_group("npcs")
	name = "NPC_%s" % data.id
	_setup_animations()

func _ready() -> void:
	if _sprite == null:
		_sprite = $AnimatedSprite2D
	if _interaction_area == null:
		_interaction_area = $InteractionArea

func _physics_process(_delta: float) -> void:
	if _has_target:
		_move_towards_target()
	else:
		_is_moving = false
	_update_animation()

func _move_towards_target() -> void:
	var dir := (_target_position - global_position)
	var dist := dir.length()
	if dist < 2.0:
		_has_target = false
		_is_moving = false
		velocity = Vector2.ZERO
		return
	dir = dir.normalized()
	_is_moving = true
	_track_direction(dir)
	velocity = dir * SPEED_WALK
	move_and_slide()

func set_target(pos: Vector2) -> void:
	_target_position = pos
	_has_target = true

func face_towards(target_pos: Vector2) -> void:
	var dir := (target_pos - global_position)
	if dir.length() < 0.1:
		return
	dir = dir.normalized()
	_track_direction(dir)

func interact(player_pos: Vector2) -> void:
	face_towards(player_pos)
	if npc_data == null:
		return
	DialogueManager.start(npc_id, npc_data.dialogue_id)

func _track_direction(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		_current_direction = Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	else:
		_current_direction = Vector2.DOWN if dir.y > 0 else Vector2.UP

func _update_animation() -> void:
	if _sprite == null or _sprite.sprite_frames == null:
		return
	var facing := _direction_suffix()
	var anim := ("walk_" if _is_moving else "idle_") + facing
	if not _sprite.sprite_frames.has_animation(anim):
		return
	if _sprite.animation != anim:
		_sprite.play(anim)

func _direction_suffix() -> String:
	if _current_direction == Vector2.UP:
		return "up"
	elif _current_direction == Vector2.DOWN:
		return "down"
	elif _current_direction == Vector2.LEFT:
		return "left"
	return "right"

func _setup_animations() -> void:
	var frames := _sprite.sprite_frames
	if frames == null:
		frames = SpriteFrames.new()
		_sprite.sprite_frames = frames

	var npc_id_lower := npc_id.to_lower()
	var path := "res://assets/sprites/characters/%s_sprites.png" % npc_id_lower
	var texture = load(path)
	if texture == null:
		path = "res://assets/sprites/characters/player_sprites.png"
		texture = load(path)
	if texture == null:
		return

	var directions: Array[String] = ["down", "up", "left", "right"]
	for i in range(directions.size()):
		var dir = directions[i]
		var row = i
		frames.add_animation("idle_" + dir)
		frames.add_animation("walk_" + dir)
		for frame_idx in range(3):
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(frame_idx * TILE_SIZE, row * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			frames.add_frame("idle_" + dir, atlas, 0.2)
			frames.add_frame("walk_" + dir, atlas, 0.15)
