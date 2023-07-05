extends ColorRect


@onready var value = $value


func update_stamina(stamina: float, max_stamina: float) -> void:
	value.size.x = 98 * stamina / max_stamina
