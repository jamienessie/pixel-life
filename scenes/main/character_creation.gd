extends Control

@onready var vbox: VBoxContainer = $VBoxContainer
@onready var placeholder: Label = $PlaceholderLabel

func _on_start_button_pressed() -> void:
	GameState.start_new_game()
	hide()
	await SceneRouter.goto_zone("town", "spawn_default")
	get_parent().remove_child(self)
	queue_free()
