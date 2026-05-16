extends Node

# Force class_name registration for Resource types used in this script
const _reg_dialogue_data := preload("res://resources/dialogue_data.gd")
const _reg_npc_data := preload("res://resources/npc_data.gd")

var _active := false
var _current_npc := ""
var _current_dialogue_id := ""
var _current_node_id := ""
var _dialogue_data: DialogueData = null

func start(npc_id: String, dialogue_id: String) -> void:
	_active = true
	_current_npc = npc_id
	_current_dialogue_id = dialogue_id
	_current_node_id = "greet"
	TimeManager.pause_time()
	EventBus.dialogue_started.emit(npc_id)
	_load_dialogue(dialogue_id)

func _load_dialogue(dialogue_id: String) -> void:
	var path := "res://data/dialogue/%s.tres" % dialogue_id
	_dialogue_data = load(path)

func get_current_node() -> Dictionary:
	if _dialogue_data == null:
		return {"text": "...", "choices": []}
	var raw = _dialogue_data.nodes.get(_current_node_id, {"text": "...", "choices": []})
	# Filter choices by relationship_stage_required (RAI-46).
	var filtered_choices := []
	var current_stage := RelationshipManager.get_stage(_current_npc) if _current_npc != "" else ""
	for choice in raw.get("choices", []):
		var req: String = choice.get("relationship_stage_required", "")
		if req == "" or _stage_at_least(current_stage, req):
			filtered_choices.append(choice)
	return {"text": raw.get("text", "..."), "choices": filtered_choices}

func _stage_at_least(have: String, need: String) -> bool:
	const ORDER := ["stranger", "acquaintance", "friend", "close_friend", "dating", "engaged", "married"]
	var ih := ORDER.find(have)
	var ineed := ORDER.find(need)
	if ineed < 0:
		return true
	return ih >= ineed

func choose(choice_idx: int) -> void:
	if _dialogue_data == null:
		return
	# Use the same filtered list the player just saw.
	var filtered = get_current_node().get("choices", [])
	if choice_idx < 0 or choice_idx >= filtered.size():
		end()
		return
	var choice = filtered[choice_idx]
	# Optional side-effect dispatched to a system (e.g. "school.attend").
	var action: String = choice.get("action", "")
	if action != "":
		_handle_action(action)
	var next = choice.get("next", "")
	if next == "" or next == "farewell":
		end()
		return
	_current_node_id = next

func _handle_action(action: String) -> void:
	# Format: "<system>.<method>" or "<system>.<method>:<arg>"
	var parts := action.split(":")
	var key := parts[0]
	var arg: String = parts[1] if parts.size() > 1 else ""
	var kp := key.split(".")
	if kp.size() != 2:
		return
	var system_name := kp[0]
	var method_name := kp[1]
	var system_node := get_node_or_null("/root/" + _capitalize_system(system_name))
	if system_node == null:
		return
	if not system_node.has_method(method_name):
		return
	if arg == "":
		system_node.call(method_name)
	else:
		system_node.call(method_name, arg)

func _capitalize_system(s: String) -> String:
	# "school" -> "SchoolSystem"; "library" -> "LibrarySystem".
	# Match autoload registration: SchoolSystem, LibrarySystem.
	return s.capitalize() + "System"

func end() -> void:
	_active = false
	TimeManager.resume_time()
	EventBus.dialogue_ended.emit(_current_npc)
	_current_npc = ""
	_current_dialogue_id = ""
	_current_node_id = ""
	_dialogue_data = null

func is_active() -> bool:
	return _active

func get_current_npc() -> String:
	return _current_npc

func get_current_speaker_name() -> String:
	var npc := _load_npc_data(_current_npc)
	if npc != null:
		return npc.npc_name
	return _current_npc

func _load_npc_data(npc_id: String) -> Resource:
	var path := "res://data/npcs/%s.tres" % npc_id
	return load(path)
