extends Control

func _ready() -> void:
	# The HUD overlay is display-only. If any child consumes input, taps on the
	# touch joystick / action buttons (which live on a CanvasLayer below this
	# one) will never reach them. Force every descendant to pass touches through.
	_make_ignore(self)

func _make_ignore(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_make_ignore(child)
