extends Node2D

@export var zone_id: String = "forest"

const TILE_SIZE := 16
const MAP_W := 24
const MAP_H := 24

const T_FLOOR := Vector2i(0, 0)
const T_PATH := Vector2i(1, 0)
const T_WATER := Vector2i(3, 0)
const T_TREE_TRUNK := Vector2i(0, 1)
const T_TREE_CANOPY := Vector2i(1, 1)
const T_PINE_TRUNK := Vector2i(2, 1)
const T_PINE_CANOPY := Vector2i(3, 1)
const T_ROCK := Vector2i(5, 1)
const T_BUSH := Vector2i(0, 2)
const T_MUSHROOM := Vector2i(1, 2)
const T_LOG := Vector2i(4, 2)
const T_CAMPFIRE := Vector2i(5, 2)
const T_BRIDGE := Vector2i(0, 3)

var _ground: TileMap
var _decoration: TileMap
var _collision: TileMap
var _roof: TileMap

func _ready() -> void:
	_ground = $TileMapLayers/Ground
	_decoration = $TileMapLayers/Decoration
	_collision = $TileMapLayers/Collision
	_roof = $TileMapLayers/Roof

	_setup_tilesets()
	_paint_ground()
	_paint_collision_border()
	_paint_decorations()
	_configure_collision()

func _setup_tilesets() -> void:
	var tex_path := "res://assets/sprites/tilesets/forest/forest_tiles.png"
	var texture := load(tex_path)
	if texture == null:
		push_error("Failed to load texture: " + tex_path)
		return
	for tm in [_ground, _decoration, _collision, _roof]:
		var ts := TileSet.new()
		ts.tile_size = Vector2i(16, 16)
		var atlas := TileSetAtlasSource.new()
		atlas.texture = texture
		atlas.texture_region_size = Vector2i(16, 16)
		ts.add_source(atlas)
		tm.tile_set = ts

func _paint_ground() -> void:
	for x in range(MAP_W):
		for y in range(MAP_H):
			_ground.set_cell(0, Vector2i(x, y), 0, T_FLOOR, 0)
	# Winding path
	for i in range(2, 22):
		_ground.set_cell(0, Vector2i(i, 11 + (i % 3) - 1), 0, T_PATH, 0)
		_ground.set_cell(0, Vector2i(i, 12 + (i % 3) - 1), 0, T_PATH, 0)
	# Stream
	for y in range(3, 20):
		_ground.set_cell(0, Vector2i(18, y), 0, T_WATER, 0)
	# Bridge over stream
	_ground.set_cell(0, Vector2i(18, 11), 0, T_BRIDGE, 0)
	_ground.set_cell(0, Vector2i(18, 12), 0, T_BRIDGE, 0)

func _paint_collision_border() -> void:
	for x in range(MAP_W):
		_collision.set_cell(0, Vector2i(x, 0), 0, T_TREE_TRUNK, 0)
		_collision.set_cell(0, Vector2i(x, MAP_H - 1), 0, T_TREE_TRUNK, 0)
	for y in range(MAP_H):
		_collision.set_cell(0, Vector2i(0, y), 0, T_TREE_TRUNK, 0)
		# Right edge - gap for town at y=9,10
		if not (y >= 9 and y <= 10):
			_collision.set_cell(0, Vector2i(MAP_W - 1, y), 0, T_TREE_TRUNK, 0)

func _paint_decorations() -> void:
	# Trees scattered
	_place_tree(3, 3, false)
	_place_tree(7, 4, true)
	_place_tree(5, 8, false)
	_place_tree(10, 5, true)
	_place_tree(14, 7, false)
	_place_tree(8, 16, true)
	_place_tree(12, 18, false)
	_place_tree(20, 6, true)
	_place_tree(20, 18, false)
	# Rocks
	_decoration.set_cell(0, Vector2i(6, 14), 0, T_ROCK, 0)
	_decoration.set_cell(0, Vector2i(15, 15), 0, T_ROCK, 0)
	# Mushrooms
	_decoration.set_cell(0, Vector2i(4, 10), 0, T_MUSHROOM, 0)
	_decoration.set_cell(0, Vector2i(9, 9), 0, T_MUSHROOM, 0)
	# Campfire clearing
	_decoration.set_cell(0, Vector2i(14, 14), 0, T_CAMPFIRE, 0)
	_decoration.set_cell(0, Vector2i(13, 13), 0, T_LOG, 0)
	_decoration.set_cell(0, Vector2i(15, 13), 0, T_LOG, 0)

func _place_tree(x: int, y: int, is_pine: bool) -> void:
	if is_pine:
		_decoration.set_cell(0, Vector2i(x, y), 0, T_PINE_TRUNK, 0)
		_decoration.set_cell(0, Vector2i(x, y - 1), 0, T_PINE_CANOPY, 0)
	else:
		_decoration.set_cell(0, Vector2i(x, y), 0, T_TREE_TRUNK, 0)
		_decoration.set_cell(0, Vector2i(x, y - 1), 0, T_TREE_CANOPY, 0)

func _configure_collision() -> void:
	var ts := _collision.tile_set
	if ts == null:
		return
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 0)
	var atlas := ts.get_source(0) as TileSetAtlasSource
	if atlas == null:
		return
	var solid_coords := [T_TREE_TRUNK]
	for coords in solid_coords:
		var data = atlas.get_tile_data(coords, 0)
		if data != null:
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, PackedVector2Array([
				Vector2(0, 0), Vector2(16, 0), Vector2(16, 16), Vector2(0, 16)
			]))
