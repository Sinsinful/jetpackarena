extends CharacterBody2D

signal exploded

# --- Movement ---
@export var speed: float = 140.0
@export var explode_distance: float = 15.0   # Explosion trigger radius
@export var acceleration: float = 6.0

# --- Death / Explosion ---
@export var death_effect_scene: PackedScene
@export var self_destruct_time: float = 10.0  # seconds before auto-explode

# --- References ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var detection: Area2D = $Detection
@onready var explosion_range: Area2D = $ExplosionRange
@onready var move_loop: AudioStreamPlayer2D = $Audio/MoveLoop
@onready var explosion_point: Marker2D = $ExplosionPoint

# --- Internal ---
var target: Node2D = null
var is_exploding := false
var self_destruct_timer: Timer = null

func _ready() -> void:
	# Connect detection signals
	detection.body_entered.connect(_on_detected)
	detection.body_exited.connect(_on_lost)
	explosion_range.body_entered.connect(_on_explosion_trigger)
	
	# Create timer but don't start yet
	self_destruct_timer = Timer.new()
	self_destruct_timer.wait_time = self_destruct_time
	self_destruct_timer.one_shot = true
	self_destruct_timer.autostart = false
	self_destruct_timer.timeout.connect(_explode)
	add_child(self_destruct_timer)

func _physics_process(delta: float) -> void:
	if not target or is_exploding:
		velocity = velocity.lerp(Vector2.ZERO, acceleration * delta)
		move_and_slide()
		return

	var dir := (target.global_position - global_position).normalized()
	velocity = velocity.lerp(dir * speed, acceleration * delta)
	move_and_slide()

func _on_detected(body: Node) -> void:
	if body.is_in_group("Player"):
		target = body
		if move_loop and not move_loop.playing:
			move_loop.play()
		if self_destruct_timer:
			self_destruct_timer.start()  # start countdown when drone detects player

func _on_lost(body: Node) -> void:
	if body == target:
		target = null
		if move_loop and move_loop.playing:
			move_loop.stop()

func _on_explosion_trigger(body: Node) -> void:
	if is_exploding:
		return
	if body.is_in_group("Player"):
		_explode()
		if body.has_method("die"):
			body.die()

func spawn_death_effect():
	if not death_effect_scene:
		return
	var effect := death_effect_scene.instantiate()
	get_tree().root.add_child(effect)
	effect.global_position = global_position
	var particle_node = effect.get_node("ExplosionParticles")
	if particle_node:
		particle_node.explode(global_position)

func _explode() -> void:
	if is_exploding:
		return
	is_exploding = true
	velocity = Vector2.ZERO

	if move_loop and move_loop.playing:
		move_loop.stop()
	
	emit_signal("exploded")
	spawn_death_effect()
	queue_free()
