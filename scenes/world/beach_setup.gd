extends Node2D

@export var zone_id: String = "beach"

const TILE_SIZE := 16
const MAP_W := 24
const MAP_H := 24

const T_SAND := Vector2i(0, 0)
const T_WET_SAND := Vector2i(1, 0)
const T_SHALLOW := Vector2i(2, 0)
const T_DEEP := Vector2i(3, 0)
const T_PATH := Vector2i(4, 0)
const T_PALM_TRUNK := Vector2i(0, 1)
const T_PALM_CANOPY := Vector2i(1, 1)
const T_DOCK := Vector2i(2, 1)
const T_ROCK := Vector2i(4, 1)
const T_CRAB := Vector2i(0, 2)
const T_UMBRELLA := Vector2i(2, 2)
const T_CAMPFIRE := Vector2i(4, 2)
const T_DRIFTWOOD := Vector2i(5, 2)

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
	var tex_path := "res://assets/sprites/tilesets/beach/beach_tiles.png"
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
			_ground.set_cell(0, Vector2i(x, y), 0, T_SAND, 0)
	# Ocean on the right side
	for x in range(18, MAP_W):
		for y in range(MAP_H):
			if x == 18:
				_ground.set_cell(0, Vector2i(x, y), 0, T_WET_SAND, 0)
			elif x < 21:
				_ground.set_cell(0, Vector2i(x, y), 0, T_SHALLOW, 0)
			else:
				_ground.set_cell(0, Vector2i(x, y), 0, T_DEEP, 0)
	# Path from town
	for y in range(2, MAP_H - 2):
		_ground.set_cell(0, Vector2i(2, y), 0, T_PATH, 0)
	# Dock extending into water
	for x in range(18, 22):
		_ground.set_cell(0, Vector2i(x, 11), 0, T_DOCK, 0)
		_ground.set_cell(0, Vector2i(x, 12), 0, T_DOCK, 0)

func _paint_collision_border() -> void:
	# Top, bottom, left borders (open to ocean on right)
	for x in range(MAP_W - 1):
		_collision.set_cell(0, Vector2i(x, 0), 0, T_ROCK, 0)
		_collision.set_cell(0, Vector2i(x, MAP_H - 1), 0, T_ROCK, 0)
	for y in range(MAP_H):
		# Left edge - gap for town at y=9,10
		if not (y >= 9 and y <= 10):
			_collision.set_cell(0, Vector2i(0, y), 0, T_ROCK, 0)
	# Water edge at bottom (no walkable gap)
	for y in range(MAP_H - 4, MAP_H):
		for x in range(2, MAP_W - 2):
			_collision.set_cell(0, Vector2i(x, y), 0, T_ROCK, 0)

func _paint_decorations() -> void:
	# Palm trees
	_place_palm(5, 4)
	_place_palm(8, 6)
	_place_palm(6, 16)
	_place_palm(12, 5)
	# Umbrellas
	_decoration.set_cell(0, Vector2i(10, 8), 0, T_UMBRELLA, 0)
	_decoration.set_cell(0, Vector2i(14, 8), 0, T_UMBRELLA, 0)
	# Crabs
	_decoration.set_cell(0, Vector2i(16, 14), 0, T_CRAB, 0)
	_decoration.set_cell(0, Vector2i(17, 10), 0, T_CRAB, 0)
	# Campfire
	_decoration.set_cell(0, Vector2i(10, 16), 0, T_CAMPFIRE, 0)
	# Driftwood
	_decoration.set_cell(0, Vector2i(15, 17), 0, T_DRIFTWOOD, 0)

func _place_palm(x: int, y: int) -> void:
	_decoration.set_cell(0, Vector2i(x, y), 0, T_PALM_TRUNK, 0)
	_decoration.set_cell(0, Vector2i(x, y - 1), 0, T_PALM_CANOPY, 0)

func _configure_collision() -> void:
	var ts := _collision.tile_set
	if ts == null:
		return
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 0)
	var atlas := ts.get_source(0) as TileSetAtlasSource
	if atlas == null:
		return
	var solid_coords := [T_ROCK]
	for coords in solid_coords:
		var data = atlas.get_tile_data(coords, 0)
		if data != null:
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, PackedVector2Array([
				Vector2(0, 0), Vector2(16, 0), Vector2(16, 16), Vector2(0, 16)
			]))
