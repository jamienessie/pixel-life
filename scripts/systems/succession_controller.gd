extends Node

# SuccessionController — orchestrates death → save → death screen → succession menu → switch.
# Spawned by SceneRouter so it lives across zones.

const _reg_family_tree := preload("res://resources/family_tree.gd")

const _InheritanceRules := preload("res://scripts/systems/save/inheritance_rules.gd")
var _death_screen: Control = null
var _succession_menu: Control = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.player_died.connect(_on_player_died)

func bind_ui(death_screen: Control, succession_menu: Control) -> void:
	_death_screen = death_screen
	_succession_menu = succession_menu
	if _death_screen != null and _death_screen.has_signal("dismissed"):
		_death_screen.dismissed.connect(_on_death_screen_dismissed)
	if _succession_menu != null and _succession_menu.has_signal("heir_chosen"):
		_succession_menu.heir_chosen.connect(_on_heir_chosen)

func _on_player_died(cause: String) -> void:
	# SaveManager already auto-saved on this signal.
	TimeManager.pause_time()
	get_tree().paused = true
	if _death_screen != null:
		var deceased: CharacterProfile = GameState.active_character
		var name := deceased.character_name if deceased != null else "Unknown"
		var age := deceased.age if deceased != null else 0
		_death_screen.show_for(name, age, cause)
	else:
		_open_succession()

func _on_death_screen_dismissed() -> void:
	_open_succession()

func _open_succession() -> void:
	if GameState.family_tree == null:
		_game_over()
		return
	var deceased_id: String = GameState.active_character.id if GameState.active_character != null else ""
	var heirs: Array = GameState.family_tree.eligible_heirs(deceased_id)
	if heirs.is_empty():
		_game_over()
		return
	if _succession_menu != null:
		_succession_menu.show_heirs(heirs)
	else:
		# No UI bound — auto-pick eldest heir.
		_apply_succession(heirs[0].id)

func _on_heir_chosen(heir_id: String) -> void:
	_apply_succession(heir_id)

func _apply_succession(heir_id: String) -> void:
	var deceased: CharacterProfile = GameState.active_character
	var tree: FamilyTree = GameState.family_tree
	if deceased == null or tree == null:
		return

	# Run inheritance and apply.
	var inheritance_list: Array = _InheritanceRules.determine_heirs(deceased, tree)
	_apply_inheritance(deceased, inheritance_list, heir_id)

	# Reset systems that should NOT transfer.
	JobManager.quit()
	RelationshipManager.reset()

	# Switch active character.
	GameState.switch_active_character(heir_id)

	# Sync economy + transform to the heir's profile.
	EconomyManager.set_money(GameState.active_character.money)
	# Spawn the heir at the town default marker.
	get_tree().paused = false
	TimeManager.resume_time()
	SceneRouter.goto_zone("town", "spawn_default")

func _apply_inheritance(deceased: CharacterProfile, inheritance: Array, primary_heir_id: String) -> void:
	var tree: FamilyTree = GameState.family_tree
	var money_total: int = deceased.money
	# Distribute money based on percentage shares.
	for entry in inheritance:
		var member: CharacterProfile = tree.get_member_by_id(entry["character_id"])
		if member == null:
			continue
		match entry["inheritance_type"]:
			"money":
				var pct: float = float(entry["percentage"])
				member.money += int(round(money_total * pct / 100.0))
			"house":
				member.house_tier = max(member.house_tier, deceased.house_tier)
	deceased.money = 0
	# Primary heir always inherits the house if no rule assigned one.
	var heir: CharacterProfile = tree.get_member_by_id(primary_heir_id)
	if heir != null and heir.house_tier < deceased.house_tier:
		heir.house_tier = deceased.house_tier

func _game_over() -> void:
	get_tree().paused = false
	TimeManager.resume_time()
	# Wipe save and return to main menu.
	SaveManager.delete_save()
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
