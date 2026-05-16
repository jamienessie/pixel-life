extends Area2D

# FishingSpot — interact opens the fishing minigame UI.

const FISHING_MINIGAME_SCENE := "res://ui/menus/fishing_minigame.tscn"

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("fishing_spot")
	var prompt_scene := load("res://scenes/ui/interactable_prompt.tscn")
	if prompt_scene != null:
		set_meta("prompt_text", "[E] Fish")
		add_child(prompt_scene.instantiate())

func interact() -> Dictionary:
	if InventoryManager.count("fishing_rod") <= 0:
		return {"ok": false, "reason": "no_rod"}
	var ui := preload("res://ui/menus/fishing_minigame.tscn").instantiate()
	# Mount under the persistent UI layer (SceneRouter owns it).
	var root := get_tree().get_root()
	root.add_child(ui)
	return {"ok": true}
