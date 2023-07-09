@tool
@icon("res://assets/Icons/potion_02b.png")
class_name Pickup
extends Area2D

## The type of this particular pickup.
@export var item : Global.Pickups

# Texture assets/resources:
var ammo_texture = preload("res://assets/Icons/bullet.png")
var stamina_texture = preload("res://Assets/Icons/potion_02b.png")
var health_texture = preload("res://Assets/Icons/potion_02c.png")

func _process(_delta: float) -> void:
	# Allows us to change the icon in-editor:
	if Engine.is_editor_hint():
		update_pickup_texture()


func _ready() -> void:
	# Change the icon on game startup:
	if not Engine.is_editor_hint():
		update_pickup_texture()


func update_pickup_texture() -> void:
	match item:
		Global.Pickups.AMMO: $Sprite2D.set_texture(ammo_texture)
		Global.Pickups.STAMINA: $Sprite2D.set_texture(stamina_texture)
		Global.Pickups.HEALTH: $Sprite2D.set_texture(health_texture)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# Remove pickup from scene and add to player inventory
		body.add_pickup(item)
		get_tree().queue_delete(self)
