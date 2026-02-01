extends Camera2D

@export var target: Node2D   # Assign your Player in the inspector

# Locked horizontal position
var locked_x: float

# Shake variables
var shake_amount: float = 0.0
var shake_timer: float = 0.0
var shake_offset: Vector2 = Vector2.ZERO

func _ready():
	if is_instance_valid(target):
		locked_x = target.global_position.x
	else:
		locked_x = global_position.x

func _process(delta):
	# --- Base camera position (never affected by shake) ---
	var base_pos := global_position

	if is_instance_valid(target):
		base_pos = Vector2(
			locked_x,                    # LOCK X
			target.global_position.y     # FOLLOW Y
		)

	# --- Shake logic (purely additive) ---
	if shake_timer > 0.0:
		shake_timer -= delta
		shake_offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
	else:
		shake_offset = Vector2.ZERO

	# --- Final camera position ---
	global_position = base_pos + shake_offset

# Call this to trigger camera shake
func shake(amount: float, duration: float) -> void:
	shake_amount = amount
	shake_timer = duration
