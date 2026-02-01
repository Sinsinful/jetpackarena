extends Area2D

signal collected(amount: float)

@export var fuel_amount: float = 50.0
@export var pulse_scale: float = 2.3
@export var pulse_time: float = 0.5

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var picked_up := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if picked_up:
		return
	if not body.is_in_group("Player"):
		return

	picked_up = true

	# Disable collision safely (VERY IMPORTANT)
	collision.set_deferred("disabled", true)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	if body.has_method("add_fuel"):
		body.add_fuel(fuel_amount)

	emit_signal("collected", fuel_amount)

	# Run visual AFTER physics step
	call_deferred("_play_pickup_fx")

func _play_pickup_fx() -> void:
	sprite.visible = true
	sprite.z_index = 1000

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		sprite,
		"scale",
		sprite.scale * pulse_scale,
		pulse_time
	)

	tween.parallel().tween_property(
		sprite,
		"modulate:a",
		0.0,
		pulse_time
	)

	tween.finished.connect(queue_free)
