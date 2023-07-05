extends Node2D


func _ready() -> void:
	$player.health_updated.connect($ui/health_bar.update_health)
	$player.stamina_updated.connect($ui/stamina_bar.update_stamina)
