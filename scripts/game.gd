extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var camera_scene = preload("res://scenes/game_camera.tscn")

@onready var level_generator = $LevelGenerator
@onready var parallax1 = $ParallaxBackground/ParallaxLayer1
@onready var generator_area = $GeneratorArea

@export var level_spawn_rate = 200

var viewport_size: Vector2
var player: Player = null
var player_spawn_position: Vector2
var resource_last_spawn_position: float

var camera: GameCamera = null

var level: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_size = get_viewport_rect().size
	player_spawn_position = Vector2(10, viewport_size.y / 2.0)
	
	setup_parallax_layer(parallax1)

	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
	elif Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	print("Overlapping bodies: " + str(generator_area.get_overlapping_bodies().size()))
	print("Resource Last Spawn: " + str(resource_last_spawn_position + level_spawn_rate))
	print("Generator Area: " + str(generator_area.global_position.x))
	if generator_area.get_overlapping_bodies().size() == 0 and resource_last_spawn_position + level_spawn_rate < generator_area.global_position.x:
		print("Dynamically creating an obstacle")
		level_generator.generate_next_node(resource_last_spawn_position + level_spawn_rate, level)
		resource_last_spawn_position += level_spawn_rate
		
	generator_area.global_position.x = max(viewport_size.x, player.global_position.x + viewport_size.x)

func get_parallax_sprite_scale(parallax_sprite: Sprite2D):
	var parallax_texture = parallax_sprite.get_texture()
	var parallax_texture_width = parallax_texture.get_width()
	var scale = viewport_size.x / parallax_texture_width
	var result = Vector2(scale, scale)
	return result
	
func setup_parallax_layer(parallax_layer: ParallaxLayer):
	var parallax_sprite = parallax_layer.find_child("Sprite2D")
	if parallax_sprite:
		parallax_sprite.scale = get_parallax_sprite_scale(parallax_sprite)
		var my = parallax_sprite.scale.x * parallax_sprite.get_texture().get_height()
		parallax_layer.motion_mirroring.x = my

func new_game():
	#Setup the player and add to game scene
	player = player_scene.instantiate()
	player.global_position = player_spawn_position
	add_child(player)
	
	#Setup the game camera
	camera = camera_scene.instantiate()
	camera.setup_camera(player)
	add_child(camera)
	
	#Reset to the first level
	level = 1
	resource_last_spawn_position = viewport_size.x / 2.0
	
	#Generate the assets that need to display on the screen at the start of the game. 
	while resource_last_spawn_position < viewport_size.x:
		level_generator.generate_next_node(resource_last_spawn_position, level)
		resource_last_spawn_position += level_spawn_rate
	
	if player:
		level_generator.setup(player)
