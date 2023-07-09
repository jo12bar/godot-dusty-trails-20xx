extends ColorRect

@onready var value = $value


func update_health_pickups(health_pickups: int) -> void:
	value.text = str(health_pickups)
