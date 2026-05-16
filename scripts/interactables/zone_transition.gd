extends Area2D

## ZoneTransition — attached to Area2D nodes at zone boundaries.
## When the player body enters, triggers SceneRouter.goto_zone.

@export var target_zone: String = ""
@export var spawn_marker: String = "spawn_default"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and target_zone != "":
		SceneRouter.goto_zone(target_zone, spawn_marker)
