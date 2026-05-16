extends GutTest

var dm: Node
var bus: Node

func before_each() -> void:
	dm = get_node("/root/DialogueManager")
	bus = get_node("/root/EventBus")

func test_initial_state() -> void:
	assert_false(dm.is_active(), "dialogue not active initially")
	assert_eq(dm.get_current_npc(), "", "no current npc initially")

func test_start_dialogue() -> void:
	dm.start("anna", "anna_dialogue")
	assert_true(dm.is_active(), "dialogue active after start")
	assert_eq(dm.get_current_npc(), "anna", "current npc is anna")
	dm.end()
	assert_false(dm.is_active(), "dialogue ended after end")

func test_get_current_node_has_text_and_choices() -> void:
	dm.start("anna", "anna_dialogue")
	var node = dm.get_current_node()
	assert_true(node.has("text"), "current node has text")
	assert_gt(node.text.length(), 0, "node text is not empty")
	assert_true(node.has("choices"), "current node has choices")
	assert_gt(node.choices.size(), 0, "greet node has choices")
	assert_true(node.choices[0].has("text"), "choice 0 has text")
	assert_true(node.choices[0].has("next"), "choice 0 has next node id")
	dm.end()

func test_choose_advances_tree() -> void:
	dm.start("anna", "anna_dialogue")
	dm.choose(0)
	var node = dm.get_current_node()
	assert_true(node.text.find("hello") != -1 or node.text.find("Hello") != -1, "advanced to next node after choice")
	dm.end()

func test_choose_invalid_idx_ends() -> void:
	dm.start("anna", "anna_dialogue")
	dm.choose(999)
	assert_false(dm.is_active(), "dialogue ended after invalid choice index")

func test_end_clears_state() -> void:
	dm.start("anna", "anna_dialogue")
	dm.end()
	assert_false(dm.is_active(), "dialogue not active after end")
	assert_eq(dm.get_current_npc(), "", "current npc cleared after end")

func test_end_resumes_time() -> void:
	var was_paused = TimeManager.is_paused()
	dm.start("anna", "anna_dialogue")
	assert_true(TimeManager.is_paused(), "time paused during dialogue")
	dm.end()
	assert_false(TimeManager.is_paused(), "time resumed after dialogue")

func test_get_current_speaker_name() -> void:
	dm.start("anna", "anna_dialogue")
	var name = dm.get_current_speaker_name()
	assert_true(name.length() > 0, "speaker name is not empty")
	dm.end()

func test_start_emits_signal() -> void:
	watch_signals(bus)
	dm.start("anna", "anna_dialogue")
	assert_signal_emitted(bus, "dialogue_started", "dialogue_started signal fired")
	dm.end()

func test_end_emits_signal() -> void:
	watch_signals(bus)
	dm.start("anna", "anna_dialogue")
	dm.end()
	assert_signal_emitted(bus, "dialogue_ended", "dialogue_ended signal fired")
