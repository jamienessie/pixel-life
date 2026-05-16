extends Control

const COLS := 6
const ROWS := 4

@onready var _grid: GridContainer = $Panel/MarginContainer/GridContainer

var _slot_buttons: Array = []
var _is_open := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_grid()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(InputActions.MENU):
		get_viewport().set_input_as_handled()
		if not SceneRouter.has_current_zone():
			return
		toggle()


func toggle() -> void:
	if _is_open:
		close()
	else:
		open()


func open() -> void:
	_is_open = true
	visible = true
	refresh()


func close() -> void:
	_is_open = false
	visible = false


func refresh() -> void:
	var total_slots = COLS * ROWS
	for i in range(total_slots):
		var slot_data = InventoryManager.get_slot(i)
		var btn: Button = _slot_buttons[i]
		var label: Label = btn.get_node("Label")
		var icon_rect: ColorRect = btn.get_node("IconRect")

		if slot_data != null and slot_data is Dictionary:
			var item_data = _load_item(slot_data["id"])
			var display_name = slot_data["id"]
			if item_data != null:
				display_name = item_data.name
			var qty = slot_data.get("quantity", 1)
			label.text = display_name if qty <= 1 else "%s x%d" % [display_name, qty]
			var cat = item_data.category if item_data != null else "misc"
			icon_rect.color = _category_color(cat)
		else:
			label.text = ""
			icon_rect.color = Color(0.15, 0.15, 0.15, 0.3)


func _load_item(item_id: String):
	return InventoryManager.load_item_data(item_id)


func _build_grid() -> void:
	for i in range(COLS * ROWS):
		var btn := Button.new()
		btn.name = "Slot_%d" % i
		btn.custom_minimum_size = Vector2(80, 56)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		var icon_rect := ColorRect.new()
		icon_rect.name = "IconRect"
		icon_rect.custom_minimum_size = Vector2(24, 24)
		icon_rect.size = Vector2(24, 24)
		icon_rect.position = Vector2(4, 4)
		icon_rect.mouse_filter = Control.MOUSE_FILTER_PASS
		btn.add_child(icon_rect)

		var label := Label.new()
		label.name = "Label"
		label.position = Vector2(4, 30)
		label.size = Vector2(72, 24)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		label.add_theme_font_size_override("font_size", 9)
		label.mouse_filter = Control.MOUSE_FILTER_PASS
		btn.add_child(label)

		var idx := i
		btn.pressed.connect(_on_slot_pressed.bind(idx))

		_grid.add_child(btn)
		_slot_buttons.append(btn)


func _on_slot_pressed(idx: int) -> void:
	var slot_data = InventoryManager.get_slot(idx)
	if slot_data != null and slot_data is Dictionary:
		InventoryManager.remove(slot_data["id"], 1)
		refresh()


func _category_color(category: String) -> Color:
	match category:
		"tool": return Color(0.6, 0.35, 0.15)
		"crop": return Color(0.15, 0.7, 0.15)
		"seeds": return Color(0.55, 0.75, 0.15)
		"foraged": return Color(0.35, 0.55, 0.25)
		"material": return Color(0.45, 0.45, 0.45)
		"fish": return Color(0.15, 0.35, 0.75)
		"cooked": return Color(0.75, 0.55, 0.15)
		_: return Color(0.25, 0.25, 0.7)
