extends Node2D

@export var zone_id: String = "farm"

const TILE_SIZE := 16
const MAP_W := 24
const MAP_H := 24

const T_GRASS := Vector2i(0, 0)
const T_TILLED := Vector2i(1, 0)
const T_PATH := Vector2i(3, 0)
const T_WATER := Vector2i(4, 0)
const T_FENCE := Vector2i(0, 1)
const T_BARN_WALL := Vector2i(3, 1)
const T_BARN_ROOF := Vector2i(4, 1)
const T_CROP1 := Vector2i(0, 2)
const T_HAYBALE := Vector2i(5, 2)
const T_WELL := Vector2i(0, 3)

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
	var tex_path := "res://assets/sprites/tilesets/farm/farm_tiles.png"
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
			_ground.set_cell(0, Vector2i(x, y), 0, T_GRASS, 0)
	# Farm paths
	for x in range(2, MAP_W - 2):
		_ground.set_cell(0, Vector2i(x, 11), 0, T_PATH, 0)
	for y in range(2, MAP_H - 2):
		_ground.set_cell(0, Vector2i(11, y), 0, T_PATH, 0)
	# Tilled soil plots
	for x in range(3, 8):
		for y in range(3, 7):
			_ground.set_cell(0, Vector2i(x, y), 0, T_TILLED, 0)
	for x in range(14, 19):
		for y in range(3, 7):
			_ground.set_cell(0, Vector2i(x, y), 0, T_TILLED, 0)
	# Pond
	for x in range(18, 22):
		for y in range(16, 20):
			_ground.set_cell(0, Vector2i(x, y), 0, T_WATER, 0)

func _paint_collision_border() -> void:
	for x in range(MAP_W):
		# Top edge - gap for town at x=9,10
		if not (x >= 9 and x <= 10):
			_collision.set_cell(0, Vector2i(x, 0), 0, T_FENCE, 0)
		_collision.set_cell(0, Vector2i(x, MAP_H - 1), 0, T_FENCE, 0)
	for y in range(MAP_H):
		_collision.set_cell(0, Vector2i(0, y), 0, T_FENCE, 0)
		_collision.set_cell(0, Vector2i(MAP_W - 1, y), 0, T_FENCE, 0)

func _paint_decorations() -> void:
	_decoration.set_cell(0, Vector2i(4, 16), 0, T_WELL, 0)
	_decoration.set_cell(0, Vector2i(6, 16), 0, T_HAYBALE, 0)
	_decoration.set_cell(0, Vector2i(7, 16), 0, T_HAYBALE, 0)
	# Crops
	for x in range(4, 7):
		_decoration.set_cell(0, Vector2i(x, 4), 0, T_CROP1, 0)

func _paint_roofs() -> void:
	# Barn roof
	for x in range(4, 9):
		_roof.set_cell(0, Vector2i(x, 15), 0, T_BARN_ROOF, 0)

func _configure_collision() -> void:
	var ts := _collision.tile_set
	if ts == null:
		return
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 0)
	var atlas := ts.get_source(0) as TileSetAtlasSource
	if atlas == null:
		return
	var solid_coords := [T_FENCE]
	for coords in solid_coords:
		var data = atlas.get_tile_data(coords, 0)
		if data != null:
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, PackedVector2Array([
				Vector2(0, 0), Vector2(16, 0), Vector2(16, 16), Vector2(0, 16)
			]))
