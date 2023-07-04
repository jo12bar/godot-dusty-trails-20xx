extends CharacterBody2D

## Player movement speed.
@export var movement_speed = 50

## Player sprinting speed.
@export var sprint_speed = 100

var speed = movement_speed

var cur_direction = Vector2(0, 1) ## Current direction that the player is facing
var animation: String = "idle_down" ## The player's current animation

var is_attacking = false ## true if the player is currently attacking something


func _physics_process(delta: float) -> void:
	# Get player input, making sure left/right and up/down respectively cancel each other out
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# If action is digital (e.g. using a keyboard), normalize any diagonal input
	# (sorry speedrunners)
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	if Input.is_action_pressed("ui_sprint"):
		speed = sprint_speed
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
