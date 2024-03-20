extends Node

@onready var game = $Game
@onready var screens = $Screens

@export var game_over_screen_delay = 0.75

var game_in_progress = false

func _ready():

	screens.start_game.connect(_on_screens_start_game)
	screens.delete_level.connect(_on_screens_delete_game)
	screens.advance_level.connect(_on_screens_advance_level)
	
	game.pause_game.connect(_on_game_pause_game)
	game.player_died.connect(_on_game_player_died)
	game.advance_level.connect(_on_game_advance_level)
	game.player_won.connect(_on_game_player_won)

func _on_screens_start_game():
	game_in_progress = true
	#await screens.start_countdown()
	game.new_game()
	
func _on_screens_delete_game():
	game_in_progress = false
	game.reset_game()
	
func _on_screens_advance_level(choice):
	match choice:
		1: 
			game.new_game(game.level + 1, 0, game.time, game.player_speed_increment, true, false)
		2: 
			game.new_game(game.level + 1, 0, game.time, 0.0, false, false)

func _on_game_pause_game():
	get_tree().paused = true
	print("Main pause game pressed.")
	screens.pause_game()
	
func _on_game_player_died(level, score, best_score):
	game_in_progress = false
	await(get_tree().create_timer(game_over_screen_delay).timeout)
	screens.game_over(level, score, best_score)
	
func _on_game_advance_level():
	get_tree().paused = true
	screens.advance_level_screen()

func _on_game_player_won(level, time, best_time):
	game_in_progress = false
	get_tree().paused = true
	screens.player_won(level, time, best_time)
