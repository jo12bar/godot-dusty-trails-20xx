## A cactus enemy.
class_name EnemyCactus
extends Enemy

# Health and stamina stats
@export_category("Combat Stats")
@export var health: float = 100
@export var max_health: float = 100
@export var health_regen: float = 1

## Enemy movement speed.
@export var speed: float = 50.0

@export var bullet_damage: float = 30       ## Damage that player bullets inflict
@export var bullet_reload_time: int = 1000  ## Milliseconds to reload after firing
@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
var bullet_fired_time = 0

## Things the enemy drops upon death.
@export var pickups_scene: PackedScene = preload("res://scenes/pickup.tscn")

## Current direction the enemy is moving.
var cur_direction: Vector2
## New direction that the enemy should be updated to move next game tick.
var new_direction: Vector2 = Vector2(0, 1)
var animation: String = "idle_down"
var is_attacking = false

var rng = RandomNumberGenerator.new()

## Timer count-down to redirect the enemy if collision events occur & the timer countdown reaches 0
var timer: int = 0
## Player scene reference
var player: Player


## Initialize enemy on startup
func _ready() -> void:
	player = get_tree().root.get_node("main/player")
	rng.randomize()

	# Reset modulate death animation so the enemy doesn't stay red
	var as2d := $AnimatedSprite2D as AnimatedSprite2D
	as2d.modulate = Color(1, 1, 1, 1)


func _process(delta: float) -> void:
	# Regen health
	health = min(health + health_regen * delta, max_health)


## Process the enemy's movement
func _physics_process(delta: float) -> void:
	var movement = speed * cur_direction * delta
	var collision = move_and_collide(movement)

	if collision != null and (not collision.get_collider() is Player):
		# If the enemy collides with other objects, turn it around and re-randomize
		# the timer countdown.
		cur_direction = cur_direction.rotated(rng.randf_range(PI/4.0, PI/2.0))
		timer = rng.randf_range(2.0, 5.0)
	else:
		# If they collide with either the player or nothing, trigger the timer's timeout()
		# so that they can chase/move towards the player.
		timer = 0

	# Play animations if not currently attacking
	if !is_attacking:
		enemy_animations(cur_direction)


## Spawn the enemy, playing its spawning animation and pausing it for a bit.
func spawn() -> void:
	$AnimatedSprite2D.animation = "spawn"
	$AnimatedSprite2D.play("spawn")
	is_attacking = true # creates animation delay


## Sync new_direction with the actual current movement direction (cur_direction).
## Called whenever the enemy moves or rotates.
func sync_new_direction() -> void:
	if cur_direction != Vector2.ZERO:
		new_direction = cur_direction.normalized()


## Triggered whenever the action Timer node expires.
func _on_timer_timeout() -> void:
	var vector_to_player = player.position - self.position
	var player_distance = vector_to_player.length()

	if player_distance <= 20:
		# If player is in attack radius, turn towards player for an attack.
		new_direction = vector_to_player.normalized()
		sync_new_direction()
		cur_direction = Vector2.ZERO # stop moving while attacking!
	elif player_distance <= 100 and timer == 0:
		# If player is within chase radius, and the enemy's action delay Timer
		# isn't running, then move towards the player to attack them.
		cur_direction = vector_to_player.normalized()
		sync_new_direction()
	elif timer == 0:
		# If the player is very far away, and the enemy's action delay Timer
		# isn't running, then randomly roam around.
		var move_roll = rng.randf()
		if move_roll < 0.05:
			# Enemy stops randomly
			cur_direction = Vector2.ZERO
		elif move_roll < 0.1:
			# Enemy moves randomly
			cur_direction = Vector2.DOWN.rotated(rng.randf() * 2.0 * PI)
		sync_new_direction()


## Plays the enemy's animations.
##
## @param direction: The current direction the enemy is moving. Zero if the
## enemy is stationary.
func enemy_animations(movement_direction: Vector2) -> void:
	if movement_direction != Vector2.ZERO:
		new_direction = movement_direction

		animation = "walk_" + animation_direction(new_direction)
		$AnimatedSprite2D.play(animation)
	else:
		# play the idle animation if not moving
		animation = "idle_" + animation_direction(new_direction)
		$AnimatedSprite2D.play(animation)


## Gets the direction of animation depending on the enemy's current direction.
##
## Will set $AnimatedSprite2D.flip_h to true or false depending on the input
## angle to handle flipping the animation horizontally.
func animation_direction(direction: Vector2) -> String:
	var angle = direction.angle()

	if angle <= deg_to_rad(-157.5) or angle > deg_to_rad(157.5):
		# facing left
		$AnimatedSprite2D.flip_h = true
		return "side"
	elif angle > deg_to_rad(-157.5) and angle <= deg_to_rad(-112.5):
		# facing up-left
		$AnimatedSprite2D.flip_h = true
		return "ne"
	elif angle > deg_to_rad(-112.5) and angle <= deg_to_rad(-67.5):
		# facing up
		return "up"
	elif angle > deg_to_rad(-67.5) and angle <= deg_to_rad(-22.5):
		# facing up-right
		$AnimatedSprite2D.flip_h = false
		return "ne"
	elif angle > deg_to_rad(-22.5) and angle <= deg_to_rad(22.5):
		# facing right
		$AnimatedSprite2D.flip_h = false
		return "side"
	elif angle > deg_to_rad(22.5) and angle <= deg_to_rad(67.5):
		# facing down-right
		$AnimatedSprite2D.flip_h = false
		return "se"
	elif angle > deg_to_rad(67.5) and angle <= deg_to_rad(112.5):
		# facing down
		return "down"
	elif angle > deg_to_rad(112.5) and angle <= deg_to_rad(157.5):
		# facing down-left
		$AnimatedSprite2D.flip_h = true
		return "se"

	return ""


## Resets our attacking state back to false.
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "spawn":
		$Timer.start()
		timer = 0

	# Once the death animation has been played, remove the enemy from the scene
	if $AnimatedSprite2D.animation == "death":
		get_tree().queue_delete(self)

	is_attacking = false


## Inflict damage on the enemy, decreasing its HP and possibly killing it.
func inflict_damage(damage: float) -> void:
	health -= damage
	if health > 0:
		# Play damage animation
		$AnimationPlayer.play("damage")
	else:
		# kill enemy
		$AnimatedSprite2D.play("death")
		$Timer.stop()
		cur_direction = Vector2.ZERO
		set_process(false) # stop health regen
		is_attacking = true # trigger animation finished signal
		# emit signal to let e.g. the spawners know
		enemy_death.emit()

		# 90% chance to drop loot
		if rng.randf() < 0.9:
			var pickup := pickups_scene.instantiate() as Pickup
			pickup.item = Global.Pickups[Global.Pickups.keys()[rng.randi() % Global.Pickups.size()]]
			get_tree().root.get_node("main").call_deferred("add_child", pickup)
			pickup.position = self.position
