extends CharacterBody2D
## The main script hosting logic behind the Player character.

## Fired whenever a change in the player's health level occurs.
##
## Will be fired right when the game starts in _ready() to give the initial
## current and max health values.
##
## Parameters (in order):
## @param health:     The player's current health.
## @param max_health: The player's current max health.
signal health_updated(health: float, max_health: float)

## Fired whenever a change in the player's stamina level occurs.
##
## Will be fired right when the game starts in _ready() to give the initial
## current and max stamina values.
##
## Parameters (in order):
## @param stamina:     The player's current stamina.
## @param max_stamina: The player's current max stamina.
signal stamina_updated(stamina: float, max_stamina: float)

@export_category("Movement Stats")
## Player movement speed.
@export var movement_speed = 50
## Player sprinting speed.
@export var sprint_speed = 100
@export var sprint_stamina_drain = 20 # stamina/sec

var speed = movement_speed

var cur_direction = Vector2(0, 1) ## Current direction that the player is facing
var animation: String = "idle_down" ## The player's current animation

var is_attacking = false ## true if the player is currently attacking something

# Health and stamina stats
@export_category("Combat Stats")
@export var health = 100
@export var max_health = 100
@export var regen_health = 1
@export var stamina = 100
@export var max_stamina = 100
@export var regen_stamina = 5


func _ready() -> void:
	# Send out initial health and stamina update signals
	health_updated.emit(health, max_health)
	stamina_updated.emit(stamina, max_stamina)


func _process(delta: float) -> void:
	var updated_health = min(health + regen_health * delta, max_health)
	var updated_stamina = min(stamina + regen_stamina * delta, max_stamina)

	if updated_health != health:
		health = updated_health
		health_updated.emit(health, max_health)

	if updated_stamina != stamina:
		stamina = updated_stamina
		stamina_updated.emit(stamina, max_stamina)


func _physics_process(delta: float) -> void:
	# Get player input, making sure left/right and up/down respectively cancel each other out
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# If action is digital (e.g. using a keyboard), normalize any diagonal input
	# (sorry speedrunners)
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()

	# Sprinting
	if Input.is_action_pressed("ui_sprint"):
		if stamina >= 0:
			speed = sprint_speed
			stamina = stamina - sprint_stamina_drain * delta
			stamina_updated.emit(stamina, max_stamina)
		else:
			speed = movement_speed
	elif Input.is_action_just_released("ui_sprint"):
		speed = movement_speed

	# Calculate overall movement for this physics update
	var movement = speed * direction * delta

	# Only move and animation if not attacking
	if !is_attacking:
		# Move player, while enforcing collisions
		move_and_collide(movement)
		# Play player animation
		player_animations(direction)

		# Check if all frames of the attack anumation have finished
		if is_attacking and !$AnimatedSprite2D.is_playing():
			is_attacking = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_attack"):

		# Play attacking/shooting animation
		is_attacking = true
		var attack_animation = "attack_" + animation_direction(cur_direction)
		$AnimatedSprite2D.play(attack_animation)



## Plays the player's animations.
##
## @param direction: The current direction the player is moving. Zero if the
## player is stationary.
func player_animations(movement_direction: Vector2) -> void:
	if movement_direction != Vector2.ZERO:
		cur_direction = movement_direction

		animation = "walk_" + animation_direction(cur_direction)
		$AnimatedSprite2D.play(animation)
	else:
		# play the idle animation if not moving
		animation = "idle_" + animation_direction(cur_direction)
		$AnimatedSprite2D.play(animation)

## Gets the direction of animation depending on the player's current direction.
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


func _on_animated_sprite_2d_animation_finished() -> void:
	is_attacking = false
