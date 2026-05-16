extends Node

## SceneRouter — owns the persistent UI CanvasLayer and player node.
## goto_zone(zone_id, spawn_marker): fade → free old zone → instance new → reparent player → fade in → emit zone_changed.

const ZONE_PATH := "res://scenes/world/%s.tscn"
const PLAYER_SCENE := "res://scenes/actors/player.tscn"
const FADE_SCENE := "res://scenes/effects/fade_transition.tscn"

var _current_zone: Node = null
var _ui_layer: CanvasLayer
var _player: CharacterBody2D = null
var _fade_rect: Control = null
var _is_transitioning := false
var _npc_spawner: Node = null
var _schedule_runner: Node = null
var _hud_node: Control = null
var _pause_menu: Control = null
var _inventory_menu: Control = null
var _dialogue_box: Control = null
var _relationship_menu: Control = null
var _career_menu: Control = null
var _death_screen: Control = null
var _succession_menu: Control = null
var _succession_controller: Node = null
var _debug_menu: Control = null
var _toast_widget: Control = null
var _build_buy_menu: Control = null
var _settings_menu: CanvasLayer = null
var _achievements_menu: CanvasLayer = null
var _touch_hud: CanvasLayer = null

signal zone_changed(zone_id: String)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_ui_layer()
	_setup_fade()
	_setup_hud()
	_setup_touch_hud()
	_setup_pause_menu()
	_setup_inventory_menu()
	_setup_dialogue_box()
	_setup_relationship_menu()
	_setup_career_menu()
	_setup_death_screen()
	_setup_succession_menu()
	_setup_succession_controller()
	_setup_debug_menu()
	_setup_toast_widget()
	_setup_build_buy_menu()
	_setup_settings_menu()
	_setup_achievements_menu()
	_setup_npc_system()
	_create_player()

func _setup_ui_layer() -> void:
	_ui_layer = CanvasLayer.new()
	_ui_layer.name = "PersistentUI"
	_ui_layer.layer = 100
	add_child(_ui_layer)

func _setup_fade() -> void:
	var fade_scene := load(FADE_SCENE)
	if fade_scene != null:
		_fade_rect = fade_scene.instantiate()
		_fade_rect.name = "FadeTransition"
		_ui_layer.add_child(_fade_rect)
	else:
		push_error("SceneRouter: failed to load fade scene")

func _create_player() -> void:
	var player_scene := load(PLAYER_SCENE)
	_player = player_scene.instantiate()
	_player.name = "Player"
	_player.add_to_group("player")

func goto_zone(zone_id: String, spawn_marker: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true

	var zone_path := ZONE_PATH % zone_id
	if not ResourceLoader.exists(zone_path):
		push_error("SceneRouter: zone scene not found: %s" % zone_path)
		_is_transitioning = false
		return

	await _fade_out(0.3)

	_detach_player()

	if _current_zone != null:
		_current_zone.queue_free()
		_current_zone = null

	var zone_scene := load(zone_path)
	_current_zone = zone_scene.instantiate()
	get_tree().root.add_child(_current_zone)

	var spawn_node: Marker2D = _current_zone.get_node_or_null("Spawns/%s" % spawn_marker)
	if spawn_node == null:
		spawn_node = _current_zone.get_node_or_null("Spawns/spawn_default")

	if spawn_node != null:
		_player.global_position = spawn_node.global_position
	else:
		_player.global_position = Vector2(240, 240)

	var ysort = _current_zone.get_node_or_null("YSort")
	if ysort != null:
		ysort.add_child(_player)
	else:
		_current_zone.add_child(_player)

	_sync_camera_limits(zone_id)
	_activate_player_camera()

	_spawn_npcs(zone_id)

	GameState.current_zone = zone_id

	await _fade_in(0.3)
	show_hud()

	_is_transitioning = false
	EventBus.zone_changed.emit(zone_id)

func _detach_player() -> void:
	if _player.get_parent() != null:
		_player.get_parent().remove_child(_player)

func _spawn_npcs(zone_id: String) -> void:
	if _npc_spawner != null and _current_zone != null:
		_npc_spawner.spawn_npcs_for_zone(zone_id, _current_zone)
		for instance in _npc_spawner.get_all_instances():
			var npc_ctrl = instance as Node2D
			if npc_ctrl != null and npc_ctrl.has_method("npc_id"):
				var id = npc_ctrl.npc_id
				if _schedule_runner != null and _schedule_runner.has_method("register_npc"):
					_schedule_runner.register_npc(id, npc_ctrl)

func _sync_camera_limits(zone_id: String) -> void:
	var zone_cam := _current_zone.get_node_or_null("ZoneCamera") as Camera2D
	var player_cam := _player.get_node_or_null("Camera2D") as Camera2D
	if zone_cam != null and player_cam != null:
		player_cam.limit_left = zone_cam.limit_left
		player_cam.limit_top = zone_cam.limit_top
		player_cam.limit_right = zone_cam.limit_right
		player_cam.limit_bottom = zone_cam.limit_bottom

func _activate_player_camera() -> void:
	var player_cam := _player.get_node_or_null("Camera2D") as Camera2D
	if player_cam != null:
		player_cam.make_current()

func _fade_out(duration: float) -> void:
	if _fade_rect != null and _fade_rect.has_method("fade_out"):
		await _fade_rect.fade_out(duration)

func _fade_in(duration: float) -> void:
	if _fade_rect != null and _fade_rect.has_method("fade_in"):
		await _fade_rect.fade_in(duration)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var keycode: int = event.physical_keycode
		# J → career menu
		if keycode == KEY_J:
			if _career_menu != null:
				_career_menu.toggle()
			get_viewport().set_input_as_handled()
		# R → relationship menu
		elif keycode == KEY_R:
			if _relationship_menu != null:
				_relationship_menu.toggle()
			get_viewport().set_input_as_handled()
		# F1 → debug menu
		elif keycode == KEY_F1:
			if _debug_menu != null:
				_debug_menu.toggle()
			get_viewport().set_input_as_handled()
		# B → build/buy menu
		elif keycode == KEY_B:
			if _build_buy_menu != null:
				_build_buy_menu.toggle()
			get_viewport().set_input_as_handled()
		# O → settings (Options) menu
		elif keycode == KEY_O:
			if _settings_menu != null:
				_settings_menu.toggle()
			get_viewport().set_input_as_handled()
		# A → achievements menu
		elif keycode == KEY_A:
			if _achievements_menu != null:
				_achievements_menu.toggle()
			get_viewport().set_input_as_handled()

func get_player() -> CharacterBody2D:
	return _player

func get_current_zone() -> Node:
	return _current_zone

func has_current_zone() -> bool:
	return _current_zone != null

func clear_zone() -> void:
	if _current_zone != null:
		_detach_player()
		_current_zone.queue_free()
		_current_zone = null
	hide_hud()
	GameState.current_zone = ""

func show_hud() -> void:
	if _hud_node != null:
		_hud_node.show()
	if _touch_hud != null:
		_touch_hud.show()

func hide_hud() -> void:
	if _hud_node != null:
		_hud_node.hide()
	if _touch_hud != null:
		_touch_hud.hide()
	if _pause_menu != null and _pause_menu.visible:
		_pause_menu.close()
	if _inventory_menu != null and _inventory_menu.visible:
		_inventory_menu.hide()

func _setup_hud() -> void:
	var hud_scene := preload("res://ui/hud/hud.tscn")
	_hud_node = hud_scene.instantiate()
	_hud_node.name = "HUD"
	_hud_node.hide()
	_ui_layer.add_child(_hud_node)

func _setup_touch_hud() -> void:
	if not (OS.has_feature("mobile") or OS.is_debug_build()):
		return
	var scene := load("res://ui/hud/touch_hud.tscn")
	if scene == null:
		return
	_touch_hud = scene.instantiate()
	if _touch_hud == null:
		return
	_touch_hud.name = "TouchHUD"
	_touch_hud.hide()
	add_child(_touch_hud)
	EventBus.dialogue_started.connect(_on_touch_hud_dialogue_started)
	EventBus.dialogue_ended.connect(_on_touch_hud_dialogue_ended)

func _on_touch_hud_dialogue_started(_npc_id: String) -> void:
	if _touch_hud != null:
		_touch_hud.hide()

func _on_touch_hud_dialogue_ended(_npc_id: String) -> void:
	if _touch_hud != null and _hud_node != null and _hud_node.visible:
		_touch_hud.show()

func _setup_pause_menu() -> void:
	var pause_scene := preload("res://ui/menus/pause_menu.tscn")
	_pause_menu = pause_scene.instantiate()
	_pause_menu.name = "PauseMenu"
	_pause_menu.hide()
	_ui_layer.add_child(_pause_menu)

func _setup_inventory_menu() -> void:
	var inv_scene := preload("res://ui/menus/inventory_menu.tscn")
	_inventory_menu = inv_scene.instantiate()
	_inventory_menu.name = "InventoryMenu"
	_inventory_menu.hide()
	_ui_layer.add_child(_inventory_menu)

func _setup_dialogue_box() -> void:
	var db_scene := preload("res://ui/menus/dialogue_box.tscn")
	_dialogue_box = db_scene.instantiate()
	if _dialogue_box == null:
		push_warning("SceneRouter: failed to instantiate dialogue_box")
		return
	_dialogue_box.name = "DialogueBox"
	_dialogue_box.hide()
	_ui_layer.add_child(_dialogue_box)

func _setup_relationship_menu() -> void:
	var rm_scene := preload("res://ui/menus/relationship_menu.tscn")
	_relationship_menu = rm_scene.instantiate()
	if _relationship_menu == null:
		push_warning("SceneRouter: failed to instantiate relationship_menu")
		return
	_relationship_menu.name = "RelationshipMenu"
	_relationship_menu.hide()
	_ui_layer.add_child(_relationship_menu)

func _setup_career_menu() -> void:
	var cm_scene := load("res://ui/menus/career_menu.tscn")
	if cm_scene == null:
		push_warning("SceneRouter: failed to load career_menu.tscn")
		return
	_career_menu = cm_scene.instantiate()
	if _career_menu == null:
		return
	_career_menu.name = "CareerMenu"
	_career_menu.hide()
	_ui_layer.add_child(_career_menu)

func get_career_menu() -> Control:
	return _career_menu

func get_relationship_menu() -> Control:
	return _relationship_menu

func _setup_death_screen() -> void:
	var scene := load("res://ui/menus/death_screen.tscn")
	if scene == null:
		return
	_death_screen = scene.instantiate()
	_death_screen.name = "DeathScreen"
	_death_screen.hide()
	_ui_layer.add_child(_death_screen)

func _setup_succession_menu() -> void:
	var scene := load("res://ui/menus/succession_menu.tscn")
	if scene == null:
		return
	_succession_menu = scene.instantiate()
	_succession_menu.name = "SuccessionMenu"
	_succession_menu.hide()
	_ui_layer.add_child(_succession_menu)

func _setup_debug_menu() -> void:
	var scene := load("res://ui/menus/debug_menu.tscn")
	if scene == null:
		return
	_debug_menu = scene.instantiate()
	_debug_menu.name = "DebugMenu"
	_debug_menu.hide()
	_ui_layer.add_child(_debug_menu)

func _setup_toast_widget() -> void:
	var scene := load("res://ui/hud/toast_widget.tscn")
	if scene == null:
		return
	_toast_widget = scene.instantiate()
	_toast_widget.name = "ToastWidget"
	_ui_layer.add_child(_toast_widget)

func _setup_build_buy_menu() -> void:
	var scene := load("res://ui/menus/build_buy_menu.tscn")
	if scene == null:
		return
	_build_buy_menu = scene.instantiate()
	_build_buy_menu.name = "BuildBuyMenu"
	_build_buy_menu.hide()
	_ui_layer.add_child(_build_buy_menu)

func _setup_settings_menu() -> void:
	var scene := load("res://ui/menus/settings_menu.tscn")
	if scene == null:
		return
	_settings_menu = scene.instantiate()
	_settings_menu.name = "SettingsMenu"
	add_child(_settings_menu)

func get_settings_menu() -> CanvasLayer:
	return _settings_menu

func _setup_achievements_menu() -> void:
	var scene := load("res://ui/menus/achievements_menu.tscn")
	if scene == null:
		return
	_achievements_menu = scene.instantiate()
	_achievements_menu.name = "AchievementsMenu"
	add_child(_achievements_menu)

func get_achievements_menu() -> CanvasLayer:
	return _achievements_menu

func _setup_succession_controller() -> void:
	var script = load("res://scripts/systems/succession_controller.gd")
	if script == null:
		return
	_succession_controller = script.new()
	_succession_controller.name = "SuccessionController"
	add_child(_succession_controller)
	_succession_controller.bind_ui(_death_screen, _succession_menu)

func _setup_npc_system() -> void:
	var spawner_script = load("res://scripts/systems/npc/npc_spawner.gd")
	if spawner_script != null and spawner_script.can_instantiate():
		_npc_spawner = spawner_script.new()
		_npc_spawner.name = "NPCSpawner"
		add_child(_npc_spawner)
	else:
		push_warning("SceneRouter: failed to load npc_spawner script")

	var runner_script = load("res://scripts/systems/npc/npc_schedule_runner.gd")
	if runner_script != null and runner_script.can_instantiate():
		_schedule_runner = runner_script.new()
		_schedule_runner.name = "NPCScheduleRunner"
		add_child(_schedule_runner)
	else:
		push_warning("SceneRouter: failed to load npc_schedule_runner script")


