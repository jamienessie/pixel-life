extends Node2D

# InteractablePrompt (RAI-44) — drop as a child of any interactable Area2D to
# show "[E] Interact" when the player is in range. Reads PROMPT_TEXT meta on
# the parent if set, otherwise uses a default.

const DEFAULT_PROMPT := "[E] Interact"
const DETECT_RADIUS := 28.0

@onready var _label: Label = $Label
@onready var _area: Area2D = $DetectArea

func _ready() -> void:
	_label.hide()
	var parent := get_parent()
	var prompt: String = DEFAULT_PROMPT
	if parent != null and parent.has_meta("prompt_text"):
		prompt = String(parent.get_meta("prompt_text"))
	_label.text = prompt
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_label.show()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_label.hide()
