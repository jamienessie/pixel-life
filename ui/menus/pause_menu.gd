extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(InputActions.PAUSE):
		get_viewport().set_input_as_handled()
		if not SceneRouter.has_current_zone():
			return
		if visible:
			close()
		else:
			open()

func open() -> void:
	GameState.pause()
	visible = true

func close() -> void:
	visible = false
	GameState.resume()

func _show_pause() -> void:
	open()

func _on_resume_button_pressed() -> void:
	close()

func _on_quit_button_pressed() -> void:
	GameState.resume()
	SceneRouter.clear_zone()
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
