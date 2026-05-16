extends Node2D

# fx_self_free — kicks particle emission, frees itself after a fixed lifetime.

@export var lifetime: float = 1.2

func _ready() -> void:
	for child in get_children():
		if child is CPUParticles2D:
			child.emitting = true
		elif child is GPUParticles2D:
			child.emitting = true
	await get_tree().create_timer(lifetime).timeout
	queue_free()
