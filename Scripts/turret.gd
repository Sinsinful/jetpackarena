extends Node2D

@export var rotation_speed: float = 2.5
@export var fire_angle_threshold: float = 0.05
@export var fire_cooldown: float = 1.5
@export var sight_range: float = 400.0  # maximum distance turret can see
@export var activation_delay: float = 3.0  # seconds before turret becomes active

@onready var barrel_pivot: Node2D = $BarrelPivot
@onready var fire_point: Marker2D = $BarrelPivot/Barrel/FirePoint

var can_fire := true
var active := false
var player: Node2D

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	# Start activation timer
	_start_activation_timer()

func _process(delta):
	if not player:
		return
	if not active:
		return  # skip rotating/firing until active
	_rotate_barrel(delta)

# -------------------
# Activation
# -------------------
func _start_activation_timer():
	var timer = get_tree().create_timer(activation_delay)
	timer.timeout.connect(_on_activate)

func _on_activate():
	active = true

# -------------------
# Rotation & firing
# -------------------
func _rotate_barrel(delta):
	var direction: Vector2 = player.global_position - barrel_pivot.global_position
	var target_angle: float = direction.angle()
	var current_angle: float = barrel_pivot.global_rotation
	var angle_diff: float = wrapf(target_angle - current_angle, -PI, PI)

	if abs(angle_diff) > fire_angle_threshold:
		barrel_pivot.global_rotation += sign(angle_diff) * rotation_speed * delta
	else:
		barrel_pivot.global_rotation = target_angle
		_try_fire()

func _try_fire():
	if not can_fire:
		return
	
	# Check line of sight and range
	if not _has_line_of_sight():
		return
	
	can_fire = false
	
	if $Gunshot:
		$Gunshot.play()
	
	_fire_bullet()
	await get_tree().create_timer(fire_cooldown).timeout
	can_fire = true

func _has_line_of_sight() -> bool:
	var from_pos = fire_point.global_position
	var to_pos = player.global_position
	
	if from_pos.distance_to(to_pos) > sight_range:
		return false

	var space_state = get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(from_pos, to_pos)
	query.exclude = [barrel_pivot, self]
	query.collision_mask = 0xFFFFFFFF

	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return true

	var hit_collider = result["collider"]
	if hit_collider == player:
		return true

	return false

func _fire_bullet():
	var bullet_scene := preload("res://Enviorment/Bullet.tscn")
	var bullet = bullet_scene.instantiate()

	bullet.global_position = fire_point.global_position
	bullet.global_rotation = barrel_pivot.global_rotation

	get_tree().current_scene.add_child(bullet)
