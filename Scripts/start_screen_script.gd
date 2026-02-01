extends Control

@export var main_scene_path: String = "res://Main.tscn"

func _process(delta: float) -> void:
	# If the player presses the "fly" action, start the game
	if Input.is_action_just_pressed("fly"):
		start_game()

func _on_button_pressed() -> void:
	start_game()
	
func start_game() -> void:
	$Button_sound.play()
	$Button.visible = false
	GameManager.start_game()
	
