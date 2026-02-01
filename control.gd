extends Control

@export var score_rate: float = 1.0
@export var low_fuel_threshold: float = 20.0
@export var flash_speed: float = 0.25  # seconds per blink

var score: float = 0.0
var scoring_enabled: bool = true

@onready var score_label: Label = $ScoreLabel
@onready var fuel_bar: ProgressBar = $FuelBar

var player: Node2D

# Flashing state
var flash_timer: float = 0.0
var flash_state: bool = false

func _ready() -> void:
	score = 0.0
	scoring_enabled = true
	
	player = get_tree().get_first_node_in_group("Player")
	if player:
		player.connect("died", Callable(self, "_on_player_died"))
		fuel_bar.max_value = player.max_fuel
		fuel_bar.value = player.fuel

func _process(delta: float) -> void:
	# SCORE
	if scoring_enabled:
		score += score_rate * delta * 10
		score_label.text = "Score: " + str(int(score))
		GameManager.score = score
		
	# FUEL
	if player:
		fuel_bar.value = player.fuel

		# Low fuel flashing
		if player.fuel <= low_fuel_threshold:
			flash_timer -= delta
			if flash_timer <= 0.0:
				flash_timer = flash_speed
				flash_state = not flash_state
				fuel_bar.modulate = Color(1, 0, 0, 1) if flash_state else Color(1, 1, 1, 1)
		else:
			fuel_bar.modulate = Color(1, 1, 1, 1)  # reset to normal

func _on_player_died() -> void:
	scoring_enabled = false
