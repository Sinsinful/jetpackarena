extends Node

@export var drone_scene: PackedScene = preload("res://Enviorment/drone.tscn")
@export var spawn_interval: float = 5.0
@export var max_drones: int = 2

@onready var spawn_points := [
	$SpawnPoint01,
	$SpawnPoint02
]

var scene_active: bool = true
var active_drones: Array[Node2D] = []

@onready var spawn_timer: Timer = Timer.new()

func _ready() -> void:
	# Filter null spawn points (missing nodes)
	spawn_points = spawn_points.filter(func(p): return p != null)
	if spawn_points.is_empty():
		push_error("NO VALID SPAWN POINTS! Check scene nodes.")
	
	add_child(spawn_timer)
	spawn_timer.one_shot = false
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_drone)
	spawn_timer.start()

func _spawn_drone() -> void:
	if not scene_active:
		return

	# CRITICAL: Clean stale/freed refs (prevents size() >= max forever)
	active_drones = active_drones.filter(func(d): return is_instance_valid(d))
	
	if active_drones.size() >= max_drones:
		return

	# Pick valid spawn point (retry if null)
	var spawn_point: Node2D = null
	for i in 5:  # Max 5 tries, unlikely all null
		spawn_point = spawn_points.pick_random()
		if spawn_point != null:
			break
	if spawn_point == null:
		push_error("All spawn points null/invalid! Skipping spawn.")
		return

	var drone: Node2D = drone_scene.instantiate()
	add_child(drone)
	drone.global_position = spawn_point.global_position
	active_drones.append(drone)

	# Safer signal connect (bound method, no lambda capture issues)
	if drone.has_signal("exploded"):
		drone.exploded.connect(_on_drone_exploded.bind(drone))
	else:
		push_warning("Drone missing 'exploded' signal!")

func _on_drone_exploded(drone: Node2D) -> void:
	active_drones.erase(drone)

func stop_spawning() -> void:
	scene_active = false
	spawn_timer.stop()
	# Optional: clean on stop
	active_drones.clear()
