class_name GameCamera
extends Camera2D

var player: Player = null
var viewport_size

func setup_camera(_player: Player):
	if _player:
		player = _player

func _ready():
	viewport_size = get_viewport_rect().size
	global_position.y = viewport_size.y / 2.0
	
	limit_left = 0
	limit_bottom = viewport_size.y
	limit_top = 0

func _physics_process(delta):
	if player:
		global_position.x = player.global_position.x + (viewport_size.x / 4.0)
