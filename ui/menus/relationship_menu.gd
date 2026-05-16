extends Control

# Force class_name registration for Resource types used in this script
const _reg_npc_data := preload("res://resources/npc_data.gd")

const NPC_IDS := ["anna", "bryan", "cora"]

@onready var _list: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/ListContainer
@onready var _title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel

var _npc_labels: Dictionary = {}
var _is_open := false

func _ready() -> void:
	visible = false

func open() -> void:
	_is_open = true
	visible = true
	_refresh()

func close() -> void:
	_is_open = false
	visible = false

func toggle() -> void:
	if _is_open:
		close()
	else:
		open()

func _refresh() -> void:
	_build_list()

func _build_list() -> void:
	for child in _list.get_children():
		child.queue_free()
	_npc_labels.clear()

	for npc_id in NPC_IDS:
		var npc_data := _load_npc(npc_id)
		if npc_data == null:
			continue
		var rel_value := RelationshipManager.get_relationship_value(npc_id)
		var stage := RelationshipManager.get_stage(npc_id)

		var entry := HBoxContainer.new()
		entry.custom_minimum_size = Vector2(0, 28)
		entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label := Label.new()
		name_label.text = npc_data.npc_name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entry.add_child(name_label)

		var value_bar := ProgressBar.new()
		value_bar.custom_minimum_size = Vector2(120, 20)
		value_bar.min_value = -100.0
		value_bar.max_value = 100.0
		value_bar.value = rel_value
		value_bar.show_percentage = false
		entry.add_child(value_bar)

		var stage_label := Label.new()
		stage_label.text = stage.capitalize()
		stage_label.custom_minimum_size = Vector2(100, 0)
		entry.add_child(stage_label)

		_list.add_child(entry)

func _load_npc(npc_id: String) -> Resource:
	return load("res://data/npcs/%s.tres" % npc_id)

func is_open() -> bool:
	return _is_open
