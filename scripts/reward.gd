extends Area2D

signal reward_collected(value)

@onready var sprite_node = $Sprite2D

var reward_value = 1

func set_texture(resource):
	sprite_node.set_texture(resource)
	
func set_reward_scale(_scale):
	set_scale(Vector2(_scale, _scale))
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	await(get_tree().create_timer(0.5).timeout)
	queue_free()

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	reward_collected.emit(reward_value)
	queue_free()
