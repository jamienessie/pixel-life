extends Control

signal heir_chosen(heir_id: String)

@onready var _list: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/ListContainer
@onready var _title: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_heirs(heirs: Array) -> void:
	visible = true
	for child in _list.get_children():
		child.queue_free()
	_title.text = "Choose Your Successor"
	for heir in heirs:
		var btn := Button.new()
		var age: int = heir.age if heir.get("age") != null else 0
		btn.text = "%s (age %d)" % [heir.character_name, age]
		btn.custom_minimum_size = Vector2(0, 32)
		var captured_id: String = heir.id
		btn.pressed.connect(func(): _choose(captured_id))
		_list.add_child(btn)

func _choose(heir_id: String) -> void:
	visible = false
	heir_chosen.emit(heir_id)
