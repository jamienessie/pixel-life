extends Control

@onready var continue_button: Button = $VBoxContainer/ContinueButton

func _ready() -> void:
	continue_button.visible = SaveManager.has_save()

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/character_creation.tscn")

func _on_continue_button_pressed() -> void:
	if SaveManager.load_slot():
		var zone := GameState.current_zone
		if zone == "":
			zone = "town"
		await SceneRouter.goto_zone(zone, "spawn_default")
		_restore_player_position()
		get_parent().remove_child(self)
		queue_free()
	else:
		get_tree().change_scene_to_file("res://scenes/main/character_creation.tscn")

func _restore_player_position() -> void:
	var player = SceneRouter.get_player()
	if player == null or GameState.active_character == null:
		return
	var profile = GameState.active_character
	if profile.get("last_position_x") != null:
		player.global_position = Vector2(profile.last_position_x, profile.last_position_y)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
