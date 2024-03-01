extends Area2D 

@onready var sprite_node = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_body_entered(body):
	if body is Player:
		print("Player encountered a rock. ")
		body.die()

func set_texture(resource):
	sprite_node.set_texture(resource)
	
func set_rock_scale(_scale):
	set_scale(Vector2(_scale, _scale))


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
