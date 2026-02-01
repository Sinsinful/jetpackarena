extends Node

@export var fuel_scene: PackedScene = preload("res://Enviorment/fuel.tscn")
@export var spawn_interval: float = 10.0

@onready var spawn_points := [
	$SpawnPoint01,
	$SpawnPoint02,
	$SpawnPoint03,
	$SpawnPoint04
]

var current_fuel: Node = null
var scene_active := true

func _ready():
	_start_spawn_timer()

func stop_spawning():
	scene_active = false

func _start_spawn_timer():
	if not scene_active:
		return
	if current_fuel:
		return
	if not is_inside_tree():
		return

	var timer := get_tree().create_timer(spawn_interval)
	timer.timeout.connect(_spawn_fuel)

func _spawn_fuel():
	if not scene_active or current_fuel:
		return
	if not is_inside_tree():
		return

	var spawn_point = spawn_points[randi() % spawn_points.size()]
	current_fuel = fuel_scene.instantiate()
	current_fuel.global_position = spawn_point.global_position

	get_tree().current_scene.add_child(current_fuel)
	current_fuel.collected.connect(_on_fuel_collected)
	
	#Main listens (for sound / score / UI)
	var main := get_tree().current_scene
	if main.has_method("_on_FuelPickup_collected"):
		current_fuel.collected.connect(main._on_FuelPickup_collected)

func _on_fuel_collected(amount: float) -> void:
	current_fuel = null
	_start_spawn_timer()
