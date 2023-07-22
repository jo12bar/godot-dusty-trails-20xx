## Spawns arbitary enemies
extends Node2D

@export var tilemap: TileMap ## Reference to the current world TileMap

## Represents the area in which the spawner will spawn enemies.
@export var spawn_area = Rect2(50, 150, 700, 700)

## Maximum count of enemies that may be spawned.
@export var max_enemies: int = 20

## How many enemies should immediately be spawned when this scene is loaded
@export var existing_enemies = 5

@export var enemy_scene: PackedScene ## Enemy scene reference to spawn

var enemy_count = 0 ## Count of enemies currently spawned
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	# The spawners transform position should *always* be set to (0, 0), or else Weird Things(tm) happen
	self.transform.origin = Vector2(0, 0)
	self.position = Vector2(0, 0)

	# Create existing enemies on game start
	for i in range(existing_enemies):
		spawn_enemy()
	enemy_count = existing_enemies


## Check if a spawn location is valid.
##
## Specifically checks if the location has an existing tile on either layer 1 (grass)
## or layer 2 (sand) of a tileset, and if that cell has no collision.
##
## Parameters:
## - position: The location to check for spawnability.
##
## Returns:
## True if the given location is valid according to the tilemap.
func is_valid_spawn_position(pos: Vector2) -> bool:
	pos = tilemap.local_to_map(tilemap.to_local(pos))
	var map_layer_count = tilemap.get_layers_count()

	# Check all layers at this position for a tile. The only allowable layers
	# are 1 (grass) and 2 (sand).
	var tile_data: TileData = null
	for layer in map_layer_count:
		var new_tile_data = tilemap.get_cell_tile_data(layer, pos)
		if new_tile_data and (layer == 1 or layer == 2):
			tile_data = new_tile_data
		elif new_tile_data and (layer != 1 and layer != 2):
			return false

	# No tiles here at all? Not a valid spawn position.
	if not tile_data:
		return false

	# Check to make sure this tile doesn't have any collisions on physics layer 0
	if tile_data.get_collision_polygons_count(0) > 0:
		return false

	return true


## Spawn a single enemy
func spawn_enemy() -> void:
	var enemy := enemy_scene.instantiate() as Enemy
	add_child(enemy)

	enemy.enemy_death.connect(_on_enemy_death)

	# Only spawn enemies on valid locations
	var valid_location = false
	while !valid_location:
		enemy.position.x = spawn_area.position.x + rng.randf_range(0, spawn_area.size.x)
		enemy.position.y = spawn_area.position.y + rng.randf_range(0, spawn_area.size.y)
		valid_location = is_valid_spawn_position(enemy.position)

	# Spawn enemy with animation delay
	enemy.spawn()


func _on_timer_timeout() -> void:
	if enemy_count < max_enemies:
		spawn_enemy()
		enemy_count += 1


func _on_enemy_death() -> void:
	# If one of this spawner's enemies dies, keep track of that
	enemy_count -= 1
