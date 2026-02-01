extends Node

enum GameState {
	MENU,
	PLAYING,
	DEAD
}

var _is_transitioning := false
var state: GameState = GameState.MENU
var score: int = 0

func start_game():
	score = 0
	state = GameState.PLAYING
	get_tree().change_scene_to_file("res://Main.tscn")

func player_died():
	if _is_transitioning:
		return
	_is_transitioning = true	
	state = GameState.DEAD
	await get_tree().create_timer(2.0).timeout
	_is_transitioning = false
	get_tree().change_scene_to_file("res://Death_Screen.tscn")

func go_to_menu():
	state = GameState.MENU
	get_tree().change_scene_to_file("res://Start_Screen.tscn")
