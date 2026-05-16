extends Node2D

@export var zone_id: String = "town"

const TILE_SIZE := 16
const MAP_W := 30
const MAP_H := 30

const T_GRASS := Vector2i(0, 0)
const T_PATH := Vector2i(1, 0)
const T_ROAD := Vector2i(2, 0)
const T_WATER := Vector2i(3, 0)
const T_SIDEWALK := Vector2i(4, 0)
const T_WALL := Vector2i(0, 1)
const T_ROOF := Vector2i(1, 1)
const T_TREE_TRUNK := Vector2i(0, 2)
const T_TREE_CANOPY := Vector2i(1, 2)
const T_BENCH := Vector2i(3, 2)
const T_LAMP := Vector2i(4, 2)

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
	_paint_roofs()
	_configure_collision()

func _setup_tilesets() -> void:
	var tex_path := "res://assets/sprites/tilesets/town/town_tiles.png"
	var texture := load(tex_path)
	if texture == null:
		push_error("Failed to load texture: " + tex_path)
		return
	# Each tile coord that any layer paints must be registered with the atlas
	# via create_tile() first; otherwise set_cell() silently does nothing.
	var tile_coords: Array[Vector2i] = [
		T_GRASS, T_PATH, T_ROAD, T_WATER, T_SIDEWALK,
		T_WALL, T_ROOF,
		T_TREE_TRUNK, T_TREE_CANOPY, T_BENCH, T_LAMP,
	]
	for tm in [_ground, _decoration, _collision, _roof]:
		var ts := TileSet.new()
		ts.tile_size = Vector2i(16, 16)
		ts.add_physics_layer()
		var atlas := TileSetAtlasSource.new()
		atlas.texture = texture
		atlas.texture_region_size = Vector2i(16, 16)
		ts.add_source(atlas, 0)
		for coords in tile_coords:
			if not atlas.has_tile(coords):
				atlas.create_tile(coords)
		tm.tile_set = ts

func _paint_ground() -> void:
	for x in range(MAP_W):
		for y in range(MAP_H):
			_ground.set_cell(0, Vector2i(x, y), 0, T_GRASS, 0)
	# Main road (horizontal through center)
	for x in range(2, MAP_W - 2):
		_ground.set_cell(0, Vector2i(x, 14), 0, T_ROAD, 0)
		_ground.set_cell(0, Vector2i(x, 15), 0, T_ROAD, 0)
	# Vertical path
	for y in range(2, MAP_H - 2):
		_ground.set_cell(0, Vector2i(14, y), 0, T_PATH, 0)
		_ground.set_cell(0, Vector2i(15, y), 0, T_PATH, 0)

func _paint_collision_border() -> void:
	# Border walls around the entire map, with gaps for transitions
	for x in range(MAP_W):
		# Top edge
		_collision.set_cell(0, Vector2i(x, 0), 0, T_WALL, 0)
		# Bottom edge - gap for farm at x=14,15
		if not (x >= 14 and x <= 15):
			_collision.set_cell(0, Vector2i(x, MAP_H - 1), 0, T_WALL, 0)
	for y in range(MAP_H):
		# Left edge - gap for forest at y=14,15
		if not (y >= 14 and y <= 15):
			_collision.set_cell(0, Vector2i(0, y), 0, T_WALL, 0)
		# Right edge - gap for beach at y=14,15
		if not (y >= 14 and y <= 15):
			_collision.set_cell(0, Vector2i(MAP_W - 1, y), 0, T_WALL, 0)

func _paint_decorations() -> void:
	# Trees in corners
	_place_tree(3, 3)
	_place_tree(26, 3)
	_place_tree(3, 26)
	_place_tree(26, 26)
	# Benches near center
	_decoration.set_cell(0, Vector2i(12, 12), 0, T_BENCH, 0)
	_decoration.set_cell(0, Vector2i(17, 12), 0, T_BENCH, 0)
	# Lamps along road
	for x in range(4, MAP_W - 4, 5):
		_decoration.set_cell(0, Vector2i(x, 12), 0, T_LAMP, 0)
		_decoration.set_cell(0, Vector2i(x, 17), 0, T_LAMP, 0)

func _paint_roofs() -> void:
	# Building awnings (walk-behind)
	for x in range(5, 10):
		_roof.set_cell(0, Vector2i(x, 5), 0, T_ROOF, 0)
	for x in range(20, 25):
		_roof.set_cell(0, Vector2i(x, 5), 0, T_ROOF, 0)

func _place_tree(x: int, y: int) -> void:
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
	var solid_coords := [T_WALL]
	for coords in solid_coords:
		var data = atlas.get_tile_data(coords, 0)
		if data != null:
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, PackedVector2Array([
				Vector2(0, 0), Vector2(16, 0), Vector2(16, 16), Vector2(0, 16)
			]))
