## A bullet fired by (usually) the player or (sometimes) other things.
extends Area2D

@export var tilemap: TileMap ## Reference to the current world TileMap
var speed = 80.0             ## The bullet's speed
var direction: Vector2       ## The bullet's current direction
var damage: int              ## How much damage this bullet deals


func _ready() -> void:
	# If a tilemap reference isn't set, try to load the root tilemap
	if not tilemap:
		tilemap = get_tree().root.get_node("main/Map")


func _process(delta: float) -> void:
	# Update the bullet's position at a temporally-constant speed
	position += speed * delta * direction


func _on_body_entered(body: Node2D) -> void:
	# Ignore collisions with the player
	if body is Player:
		return

	# Ignore collisions with water
	if body is TileMap:
		# water is on layer 0
		if tilemap.get_cell_tile_data(
			0,
			tilemap.local_to_map(tilemap.to_local(self.global_position))
		):
			return

	# If bullets hit an enemy, damage them
	if body.name.find("enemy") >= 0:
		# TODO: damage enemy
		pass

	direction = Vector2.ZERO
	$AnimatedSprite2D.play("impact")


func _on_animated_sprite_2d_animation_finished() -> void:
	# If the impact animation just finished, this bullet should cease to exist
	if $AnimatedSprite2D.animation == "impact":
		get_tree().queue_delete(self)


func _on_timer_timeout() -> void:
	# Self-destruct if the bullet doesn't hit anything in time
	$AnimatedSprite2D.play("impact")
