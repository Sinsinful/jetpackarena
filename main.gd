extends Node2D

@onready var fuel_pickup_sound: AudioStreamPlayer2D = $FuelPickupSound

func _on_FuelPickup_collected(amount: float) -> void:
	if fuel_pickup_sound:
		fuel_pickup_sound.play()
