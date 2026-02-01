extends CharacterBody2D

signal died
signal fuel_increased

# Movement properties
@export var gravity: float = 600.0
@export var jetpack_force: float = 1200.0
@export var speed: float = 200.0
@export var death_screen_path: String = "res://Death_Screen.tscn"
@export var death_effect_scene: PackedScene

# Fuel
@export var max_fuel: float = 100.0
@export var fuel_drain_rate: float = 5.0
@export var low_fuel_threshold: float = 20.0
var fuel: float

# Tilt
@export var air_tilt_angle: float = 15.0
@export var tilt_smooth: float = 0.2

# References
@onready var sprite: Sprite2D = $Sprite2D
@onready var flame: GPUParticles2D = $Sprite2D/JetpackFlame
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var jet_tap: AudioStreamPlayer2D = $JetSound_Tap
@onready var jet_loop: AudioStreamPlayer2D = $JetSound_Loop
@onready var low_fuel_warning: AudioStreamPlayer2D = $LowFuelWarning

# Flame offset
var flame_base_x: float

func _ready() -> void:
	flame_base_x = flame.position.x
	fuel = max_fuel

func _physics_process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return
		
	if not visible:
		return

	var is_flying := Input.is_action_pressed("fly") and fuel > 0.0
	_drain_fuel(delta, is_flying)

	# Horizontal movement
	var input_dir: float = 0.0
	if Input.is_action_pressed("left"):
		input_dir -= 1.0
	if Input.is_action_pressed("right"):
		input_dir += 1.0
	velocity.x = input_dir * speed

	# Vertical movement
	velocity.y += gravity * delta
	if is_flying:
		velocity.y -= jetpack_force * delta

	move_and_slide()

	# Facing
	if input_dir != 0:
		sprite.flip_h = input_dir < 0

	# Flame
	flame.position.x = flame_base_x if not sprite.flip_h else -flame_base_x
	flame.scale.x = 1 if not sprite.flip_h else -1
	flame.emitting = is_flying

	# Jet sounds
	if Input.is_action_just_pressed("fly") and fuel > 0.0:
		if jet_tap and not jet_tap.playing:
			jet_tap.play()

	if is_flying:
		if jet_loop and not jet_loop.playing:
			jet_loop.play()
	else:
		if jet_loop and jet_loop.playing:
			jet_loop.stop()

	# Tilt
	var target_rotation := 0.0
	if not is_on_floor():
		target_rotation = input_dir * air_tilt_angle
	sprite.rotation_degrees += (target_rotation - sprite.rotation_degrees) * tilt_smooth

	# Low fuel warning
	if fuel <= low_fuel_threshold:
		if low_fuel_warning and not low_fuel_warning.playing:
			low_fuel_warning.play()
	else:
		if low_fuel_warning and low_fuel_warning.playing:
			low_fuel_warning.stop()

func _drain_fuel(delta: float, flying: bool) -> void:
	if not flying:
		return
	if fuel <= 0.0:
		fuel = 0.0
		return
	fuel -= fuel_drain_rate * delta
	fuel = clamp(fuel, 0.0, max_fuel)

# Called by Fuel pickup
func add_fuel(amount: float) -> void:
	var old_fuel := fuel
	fuel += amount
	fuel = clamp(fuel, 0.0, max_fuel)
	if fuel > old_fuel:
		emit_signal("fuel_increased")

func spawn_death_effect():
	var effect := death_effect_scene.instantiate()
	get_tree().root.add_child(effect)
	effect.global_position = global_position
	var particle_node = effect.get_node("ExplosionParticles")
	if particle_node:
		particle_node.explode(global_position)

func die() -> void:
	emit_signal("died")
	spawn_death_effect()
	call_deferred("_disable_and_hide_player")
	
	if GameManager.state != GameManager.GameState.PLAYING:
		return

	GameManager.player_died()

func _disable_and_hide_player() -> void:
	if collision_shape:
		collision_shape.disabled = true
	hide()
	set_physics_process(false)
