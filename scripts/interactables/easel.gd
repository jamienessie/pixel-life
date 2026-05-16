extends Area2D

# Easel (RAI-38) — interact opens painting minigame, produces a painting item.

const PAINTING_IDS: Array[String] = [
	"painting_landscape",
	"painting_portrait",
	"painting_abstract",
	"painting_seascape",
	"painting_still_life",
]

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("easel")
	var prompt_scene := load("res://scenes/ui/interactable_prompt.tscn")
	if prompt_scene != null:
		set_meta("prompt_text", "[E] Paint")
		add_child(prompt_scene.instantiate())

func interact() -> Dictionary:
	var ui := preload("res://ui/menus/painting_minigame.tscn").instantiate()
	get_tree().get_root().add_child(ui)
	return {"ok": true}

static func random_painting_id() -> String:
	var idx := randi() % PAINTING_IDS.size()
	return PAINTING_IDS[idx]
