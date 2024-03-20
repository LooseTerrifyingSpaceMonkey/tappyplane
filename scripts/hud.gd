extends Control

signal pause_game

@onready var score_label = $TopBar/ScoreLabel
@onready var level_label = $TopBar/LevelLabel
@onready var time_label = $TopBar/TimeLabel

@export var margin = 10

func _on_pause_button_pressed():
	print("Paused button pressed")
	pause_game.emit()
	
func set_score(new_score: int):
	score_label.text = "Score: " + str(new_score)

func set_level(new_level: int):
	level_label.text = "Level: " + str(new_level)

func set_time(new_time: float):
	time_label.time_elapsed = new_time
	time_label.text = "Time: " + str(snapped(new_time, 0.1))
