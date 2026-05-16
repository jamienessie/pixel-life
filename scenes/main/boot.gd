extends Node

func _ready() -> void:
	call_deferred("_change_to_main_menu")

func _change_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
