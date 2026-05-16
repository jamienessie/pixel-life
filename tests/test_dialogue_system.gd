extends SceneTree

# GDScript unit tests for DialogueManager dialogue traversal.
# Run: godot --path <project> --headless --script tests/test_dialogue_system.gd

var dm: Node
var bus: Node

func _initialize() -> void:
	await self.process_frame

	dm = get_root().get_node("DialogueManager")
	bus = get_root().get_node("EventBus")

	print("=== DialogueManager Unit Tests ===")

	_test_initial_state()
	_test_start_dialogue()
	_test_get_current_node_greet()
	_test_choose_advances_tree()
	_test_choose_farewell_ends()
	_test_choose_invalid_idx_ends()
	_test_end_clears_state()

	print("\n✓ All DialogueManager tests passed!")
	quit(0)

func _test_initial_state() -> void:
	assert(dm.is_active() == false, "dialogue not active initially")
	assert(dm.get_current_npc() == "", "no current npc initially")
	print("  _test_initial_state ✓")

func _test_start_dialogue() -> void:
	dm.start("anna", "anna_dialogue")
	assert(dm.is_active(), "dialogue active after start")
	assert(dm.get_current_npc() == "anna", "current npc is anna")
	assert(dm.get_current_speaker_name() == "Anna", "speaker name is Anna")
	dm.end()
	print("  _test_start_dialogue ✓")

func _test_get_current_node_greet() -> void:
	dm.start("anna", "anna_dialogue")
	var node = dm.get_current_node()
	assert(node.has("text"), "current node has text")
	assert(node.text.length() > 0, "node text is not empty")
	assert(node.has("choices"), "current node has choices")
	var choices = node.choices
	assert(choices.size() > 0, "greet node has choices")
	assert(choices[0].has("text"), "choice 0 has text")
	assert(choices[0].has("next"), "choice 0 has next node id")
	dm.end()
	print("  _test_get_current_node_greet ✓")

func _test_choose_advances_tree() -> void:
	dm.start("anna", "anna_dialogue")
	# First choice is "Just saying hello!" which goes to "hello_reply"
	dm.choose(0)
	var node = dm.get_current_node()
	assert(node.text.find("hello") != -1 or node.text.find("Hello") != -1, "advanced to hello_reply node")
	dm.end()
	print("  _test_choose_advances_tree ✓")

func _test_choose_farewell_ends() -> void:
	dm.start("anna", "anna_dialogue")
	# Last choice is "Goodbye!" which goes to "farewell"
	var node = dm.get_current_node()
	var choices = node.choices
	var farewell_idx = -1
	for i in range(choices.size()):
		if choices[i].next == "farewell":
			farewell_idx = i
			break
	if farewell_idx >= 0:
		dm.choose(farewell_idx)
		assert(dm.is_active() == false, "dialogue ended after farewell")
	else:
		print("  SKIP: no farewell choice in greet node")
	dm.end()
	print("  _test_choose_farewell_ends ✓")

func _test_choose_invalid_idx_ends() -> void:
	dm.start("anna", "anna_dialogue")
	dm.choose(999)
	assert(dm.is_active() == false, "dialogue ended after invalid choice index")
	print("  _test_choose_invalid_idx_ends ✓")

func _test_end_clears_state() -> void:
	dm.start("anna", "anna_dialogue")
	dm.end()
	assert(dm.is_active() == false, "dialogue not active after end")
	assert(dm.get_current_npc() == "", "current npc cleared after end")
	print("  _test_end_clears_state ✓")
