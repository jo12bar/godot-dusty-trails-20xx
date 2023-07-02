extends CharacterBody2D

## Player movement speed.
@export var speed = 50

func _physics_process(delta: float) -> void:
	# Get player input, making sure left/right and up/down respectively cancel each other out
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# If action is digital (e.g. using a keyboard), normalize any diagonal input
	# (sorry speedrunners)
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	# Calculate overall movement for this physics update
	var movement = speed * direction * delta
	
	# Move player, while enforcing collisions
	move_and_collide(movement)
