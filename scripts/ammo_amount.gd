extends ColorRect

@onready var value = $value


func update_ammo_pickups(ammo_pickups: int) -> void:
	value.text = str(ammo_pickups)
