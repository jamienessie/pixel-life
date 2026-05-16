extends Control

signal dismissed

@onready var _title: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var _body: Label = $Panel/MarginContainer/VBoxContainer/BodyLabel
@onready var _continue_button: Button = $Panel/MarginContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_continue_button.pressed.connect(_on_continue)

func show_for(character_name: String, age: int, cause: String) -> void:
	_title.text = "In Memoriam: %s" % character_name
	_body.text = "Lived %d years.\nCause: %s.\nThe family carries on." % [age, cause]
	visible = true

func _on_continue() -> void:
	visible = false
	dismissed.emit()
