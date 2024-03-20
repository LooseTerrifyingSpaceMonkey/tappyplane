extends CanvasLayer

signal start_game
signal advance_level(choice)
signal delete_level

@onready var title_screen = $TitleScreen
@onready var get_ready_screen = $GetReadyScreen
@onready var pause_screen = $PauseScreen
@onready var game_over_screen = $GameOverScreen
@onready var game_over_score_label = $GameOverScreen/Box/ScoreLabel
@onready var game_over_best_score_label = $GameOverScreen/Box/BestScoreLabel
@onready var game_over_level_label = $GameOverScreen/Box/LevelLabel
@onready var advance_selection_screen = $AdvanceSelectionScreen

@onready var counter_label = $GetReadyScreen/ColorRect/CenterAnchor/CounterLabel

@export var screen_transition_time = 0.5

var current_screen = null

func _ready():
	register_buttons()
	
	change_screen(title_screen)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("buttons")
	if buttons.size() > 0:
		for button in buttons:
			if button is ScreenButton:
				button.clicked.connect(_on_button_pressed)
	
func change_screen(new_screen):
	if current_screen:
		var disappear_tween = current_screen.disappear()
		await(disappear_tween.finished)
		current_screen.visible = false
	
	current_screen = new_screen
	
	if current_screen:
		var appear_tween = current_screen.appear()
		await(appear_tween.finished)
		get_tree().call_group("buttons", "set_disabled", false)
		
func _on_button_pressed(button: ScreenButton):
	match button.name:
		"TitlePlay":
			change_screen(null)
			await(get_tree().create_timer(screen_transition_time + 0.25).timeout)
			start_game.emit()
		"PauseRetry":
			change_screen(null)
			await(get_tree().create_timer(screen_transition_time + 0.25).timeout)
			get_tree().paused = false
			start_game.emit()
		"PauseBack":
			change_screen(title_screen)
			get_tree().paused = false
			delete_level.emit()
		"PauseClose":
			change_screen(null)
			await(get_tree().create_timer(screen_transition_time + 0.25).timeout)
			get_tree().paused = false
		"GameOverRetry":
			change_screen(null)
			await(get_tree().create_timer(screen_transition_time + 0.25).timeout)	
			start_game.emit()
		"GameOverBack":
			change_screen(title_screen)
			delete_level.emit()	
		"AdvanceFaster":
			change_screen(null)
			await(get_tree().create_timer(screen_transition_time + 0.25).timeout)
			advance_level.emit(1)
		"AdvanceSize":
			change_screen(null)
			await(get_tree().create_timer(screen_transition_time + 0.25).timeout)
			advance_level.emit(2)

func game_over(level, score, best_score):
	game_over_level_label.text = "Level: " + str(level)
	game_over_score_label.text = "Score: " + str(score)
	game_over_best_score_label.text = "Best Score: " + str(best_score)
	change_screen(game_over_screen)

func pause_game():
	change_screen(pause_screen)
	
func start_countdown():
	change_screen(get_ready_screen)
	await(get_tree().create_timer(screen_transition_time).timeout)
	counter_label.text = str(3)
	await(get_tree().create_timer(1).timeout)
	counter_label.text = str(2)
	await(get_tree().create_timer(1).timeout)
	counter_label.text = str(1)
	await(get_tree().create_timer(1).timeout)
	change_screen(null)
	await(get_tree().create_timer(screen_transition_time).timeout)	

func advance_level_screen():
	change_screen(advance_selection_screen)

func player_won(level, time, best_time):
	game_over_level_label.text = "Level: " + str(level)
	game_over_score_label.text = "Time: " + str(time)
	game_over_best_score_label.text = "Best Time: " + str(best_time)
	change_screen(game_over_screen)
