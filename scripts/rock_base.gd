extends Area2D 

@onready var sprite_node = $Sprite2D
	
func _on_body_entered(body):
	if body is Player:
		print("Player encountered a rock. ")
		body.die()

func set_texture(resource):
	sprite_node.set_texture(resource)
	
func set_rock_scale(_scale):
	set_scale(Vector2(_scale, _scale))


func _on_visible_on_screen_notifier_2d_screen_exited():
	await(get_tree().create_timer(0.5).timeout)
	queue_free()
