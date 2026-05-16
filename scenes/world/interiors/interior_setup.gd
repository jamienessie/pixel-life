extends Node2D

@export var zone_id: String = "interior_tier1"
@export var map_w: int = 12
@export var map_h: int = 10

const T_FLOOR := Vector2i(0, 0)
const T_WALL := Vector2i(0, 1)
const T_WINDOW := Vector2i(2, 1)
const T_DOOR := Vector2i(3, 1)
const T_BED := Vector2i(0, 2)
const T_TABLE := Vector2i(1, 2)
const T_CHAIR := Vector2i(2, 2)
const T_LAMP := Vector2i(0, 3)

@onready var _ground: TileMapLayer = $TileMapLayers/Ground
@onready var _decoration: TileMapLayer = $TileMapLayers/Decoration
@onready var _collision: TileMapLayer = $TileMapLayers/Collision
@onready var _roof: TileMapLayer = $TileMapLayers/Roof

func _ready() -> void:
	_paint_floor()
	_paint_walls()
	_paint_furniture()

func _paint_floor() -> void:
	for x in range(1, map_w - 1):
		for y in range(1, map_h - 1):
			_ground.set_cell(Vector2i(x, y), 0, T_FLOOR, 0)

func _paint_walls() -> void:
	for x in range(map_w):
		_collision.set_cell(Vector2i(x, 0), 0, T_WALL, 0)
		_collision.set_cell(Vector2i(x, map_h - 1), 0, T_WALL, 0)
	for y in range(map_h):
		_collision.set_cell(Vector2i(0, y), 0, T_WALL, 0)
		_collision.set_cell(Vector2i(map_w - 1, y), 0, T_WALL, 0)
	var door_x := int(map_w / 2)
	_collision.set_cell(Vector2i(door_x, map_h - 1), 0, T_DOOR, 0)
	_collision.set_cell(Vector2i(door_x - 1, map_h - 1), 0, T_DOOR, 0)
	_collision.set_cell(Vector2i(3, 0), 0, T_WINDOW, 0)
	_collision.set_cell(Vector2i(map_w - 4, 0), 0, T_WINDOW, 0)

func _paint_furniture() -> void:
	_decoration.set_cell(Vector2i(2, 2), 0, T_BED, 0)
	_decoration.set_cell(Vector2i(2, 3), 0, T_BED, 0)
	_decoration.set_cell(Vector2i(6, 4), 0, T_TABLE, 0)
	_decoration.set_cell(Vector2i(5, 5), 0, T_CHAIR, 0)
	_decoration.set_cell(Vector2i(7, 5), 0, T_CHAIR, 0)
	_decoration.set_cell(Vector2i(9, 2), 0, T_LAMP, 0)
