extends Node2D


func _ready() -> void:
	# Connect player signals to ui functions
	$player.health_updated.connect($ui/health_bar.update_health)
	$player.stamina_updated.connect($ui/stamina_bar.update_stamina)
	$player.ammo_pickups_updated.connect($ui/ammo_amount.update_ammo_pickups)
	$player.health_pickups_updated.connect($ui/health_up_amount.update_health_pickups)
	$player.stamina_pickups_updated.connect($ui/stamina_up_amount.update_stamina_pickups)
