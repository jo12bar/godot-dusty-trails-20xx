extends ColorRect

@onready var value = $value


func update_stamina_pickups(stamina_pickups: int) -> void:
	value.text = str(stamina_pickups)
