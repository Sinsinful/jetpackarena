extends GPUParticles2D

@onready var explosion_sound: AudioStreamPlayer2D = get_parent().get_node("ExplosionSound")

func explode(position: Vector2):
	global_position = position
	restart()  # Starts emission

	# Play explosion sound
	if explosion_sound:
		explosion_sound.play()

	# Trigger camera shake
	var camera := get_viewport().get_camera_2d()
	if camera:
		camera.shake(20.0, 0.8)  # amount in pixels, duration in seconds

func _ready():
	finished.connect(_on_finished)

func _on_finished():
	queue_free()
