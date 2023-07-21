## A cactus enemy.
class_name EnemyCactus
extends CharacterBody2D

## Enemy movement speed.
@export var speed: float = 50.0

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
