class_name Reward
extends Area2D

var reward_value = 1



func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
