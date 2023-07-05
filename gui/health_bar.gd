extends ColorRect


@onready var value = $value


func update_health(health: float, max_health: float) -> void:
	value.size.x = 98 * health / max_health
