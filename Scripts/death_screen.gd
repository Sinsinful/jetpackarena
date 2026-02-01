extends Control

@export var start_scene_path: String = "res://Start_Screen.tscn"
@onready var score_label: Label = $ScoreLabel
var final_score: int = 0  # this will be set by Main when player dies

func _ready():
	score_label.text = "Score: " + str(GameManager.score)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fly"):
		advance()

func _on_button_pressed() -> void:
	advance()

func advance() -> void:
	$Button_sound.play()
	$Button.visible = false
	GameManager.go_to_menu()
