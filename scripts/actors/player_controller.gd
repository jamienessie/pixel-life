extends CharacterBody2D

## Player controller — 4-directional movement with idle/walk animation.
## M2: basic walk + collide. M4+: zone transitions, interaction range.

const SPEED_WALK := 48.0
const SPEED_RUN := 80.0
const TILE_SIZE := 16
const INTERACT_RANGE := 32.0
const FOOTSTEP_INTERVAL_SEC := 0.32

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _current_direction := Vector2.DOWN
var _is_moving := false
var _footstep_timer := 0.0

func _ready() -> void:
	add_to_group("player")
	_setup_animations()
	_sprite.play("idle_down")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(InputActions.INTERACT):
		get_viewport().set_input_as_handled()
		if DialogueManager.is_active():
			return
		# Prefer NPC if one is in range; otherwise try generic interactables
		# (crop tiles, fishing spots, easels, beds, doors, etc.).
		if not _try_interact_npc():
			_try_interact_generic()

func _physics_process(_delta: float) -> void:
	if DialogueManager.is_active():
		_is_moving = false
		velocity = Vector2.ZERO
		_update_animation()
		return

	var input := Vector2.ZERO
	input.x = Input.get_axis(InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT)
	input.y = Input.get_axis(InputActions.MOVE_UP, InputActions.MOVE_DOWN)

	if input != Vector2.ZERO:
		input = input.normalized()
		_is_moving = true
		_track_direction(input)
	else:
		_is_moving = false

	var speed := SPEED_RUN if Input.is_action_pressed(InputActions.RUN) else SPEED_WALK
	velocity = input * speed
	move_and_slide()

	_update_animation()
	_tick_footsteps(_delta)

func _tick_footsteps(delta: float) -> void:
	if not _is_moving:
		_footstep_timer = 0.0
		return
	_footstep_timer -= delta
	if _footstep_timer <= 0.0:
		var interval := FOOTSTEP_INTERVAL_SEC * (0.7 if Input.is_action_pressed(InputActions.RUN) else 1.0)
		_footstep_timer = interval
		AudioManager.play_sfx("sfx_footstep_grass")

func _track_direction(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		_current_direction = Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	else:
		_current_direction = Vector2.DOWN if dir.y > 0 else Vector2.UP

func _update_animation() -> void:
	var facing := _direction_suffix()
	if _is_moving:
		var anim := "walk_" + facing
		if _sprite.animation != anim:
			_sprite.play(anim)
	else:
		var anim := "idle_" + facing
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

func _try_interact_npc() -> bool:
	var npcs := get_tree().get_nodes_in_group("npcs")
	var closest: Node2D = null
	var closest_dist := INTERACT_RANGE

	for npc in npcs:
		var npc_node := npc as Node2D
		if npc_node == null:
			continue
		var dist := global_position.distance_to(npc_node.global_position)
		if dist < closest_dist:
			closest = npc_node
			closest_dist = dist

	if closest != null and closest.has_method("interact"):
		var player_pos := global_position
		closest.interact(player_pos)
		return true
	return false

func _try_interact_generic() -> bool:
	var interactables := get_tree().get_nodes_in_group("interactable")
	var closest: Node2D = null
	var closest_dist := INTERACT_RANGE
	for node in interactables:
		var n := node as Node2D
		if n == null:
			continue
		var dist := global_position.distance_to(n.global_position)
		if dist < closest_dist:
			closest = n
			closest_dist = dist
	if closest != null and closest.has_method("interact"):
		closest.interact()
		return true
	return false

func _setup_animations() -> void:
	var frames := _sprite.sprite_frames
	if frames == null:
		frames = SpriteFrames.new()
		_sprite.sprite_frames = frames

	var texture = load("res://assets/sprites/characters/player_sprites.png")
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
