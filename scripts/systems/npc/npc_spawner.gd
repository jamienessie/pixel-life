extends Node

# Force class_name registration for Resource types used in this script
const _reg_npc_data := preload("res://resources/npc_data.gd")

const NPC_SCENE := preload("res://scenes/actors/npc.tscn")

var _npc_instances: Dictionary = {}

func spawn_npcs_for_zone(zone_id: String, zone_node: Node) -> void:
	var npc_ids := _get_npcs_for_zone(zone_id)
	_despawn_all()

	for npc_id in npc_ids:
		var data := _load_npc_data(npc_id)
		if data == null:
			continue
		var instance := NPC_SCENE.instantiate()
		var controller := instance as CharacterBody2D
		if controller == null:
			instance.queue_free()
			continue
		controller.setup(data)

		var ysort := zone_node.get_node_or_null("YSort")
		if ysort != null:
			ysort.add_child(instance)
		else:
			zone_node.add_child(instance)

		var spawn := zone_node.get_node_or_null("Spawns/spawn_default")
		if spawn != null:
			instance.global_position = spawn.global_position + Vector2(16, 0)

		_npc_instances[npc_id] = instance

func _despawn_all() -> void:
	for npc_id in _npc_instances:
		var instance: Node = _npc_instances[npc_id]
		if instance != null and is_instance_valid(instance):
			instance.queue_free()
	_npc_instances.clear()

const NPC_ROSTER: Array[String] = [
	"anna", "bryan", "cora", "mr_oak",
	"david", "elena", "farah", "gabe", "hana", "ivy",
]

func _get_npcs_for_zone(zone_id: String) -> Array[String]:
	var result: Array[String] = []
	for npc_id in NPC_ROSTER:
		var data := _load_npc_data(npc_id)
		if data == null:
			continue
		# Runtime override (e.g. spouse) wins over the NPC's static home_zone.
		var override := FamilyManager.get_npc_override(npc_id) if FamilyManager.has_npc_override(npc_id) else {}
		var effective_home: String = override.get("home_zone", data.home_zone) if override is Dictionary and not override.is_empty() else data.home_zone
		if effective_home == zone_id:
			result.append(npc_id)
	return result

func _load_npc_data(npc_id: String) -> Resource:
	return load("res://data/npcs/%s.tres" % npc_id)

func get_npc_instance(npc_id: String) -> Node2D:
	return _npc_instances.get(npc_id, null)

func get_all_instances() -> Array:
	var result: Array = []
	for npc_id in _npc_instances:
		result.append(_npc_instances[npc_id])
	return result
