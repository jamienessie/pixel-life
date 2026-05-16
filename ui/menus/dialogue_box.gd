extends Control

@onready var _speaker_label: Label = $Panel/MarginContainer/VBoxContainer/SpeakerLabel
@onready var _text_label: Label = $Panel/MarginContainer/VBoxContainer/TextLabel
@onready var _choices_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ChoicesContainer
@onready var _continue_hint: Label = $Panel/MarginContainer/VBoxContainer/ContinueHint

var _choice_buttons: Array = []

func _ready() -> void:
	visible = false
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(_npc_id: String) -> void:
	show()
	_refresh()

func _on_dialogue_ended(_npc_id: String) -> void:
	hide()

func _refresh() -> void:
	if not DialogueManager.is_active():
		hide()
		return

	var node_data = DialogueManager.get_current_node()
	var speaker = DialogueManager.get_current_speaker_name()
	_speaker_label.text = speaker
	_text_label.text = node_data.get("text", "")
	_populate_choices(node_data.get("choices", []))

func _populate_choices(choices: Array) -> void:
	for btn in _choice_buttons:
		btn.queue_free()
	_choice_buttons.clear()

	if choices.is_empty():
		_continue_hint.show()
		return

	_continue_hint.hide()

	for i in range(choices.size()):
		var choice = choices[i]
		var btn := Button.new()
		btn.text = choice.get("text", "")
		btn.custom_minimum_size = Vector2(400, 30)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var idx := i
		btn.pressed.connect(_on_choice_selected.bind(idx))
		_choices_container.add_child(btn)
		_choice_buttons.append(btn)

func _on_choice_selected(idx: int) -> void:
	DialogueManager.choose(idx)
	_refresh()

func _input(event: InputEvent) -> void:
	if not visible or not DialogueManager.is_active():
		return
	if event.is_action_pressed(InputActions.INTERACT) or event.is_action_pressed(InputActions.MENU):
		get_viewport().set_input_as_handled()
		if _choice_buttons.is_empty():
			DialogueManager.end()
		elif _choice_buttons.size() == 1:
			DialogueManager.choose(0)
			_refresh()
