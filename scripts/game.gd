extends Node2D

signal player_died(level, score, high_score)
signal pause_game
signal advance_level
signal player_won(level, time, best_time)

var player_scene = preload("res://scenes/player.tscn")
var camera_scene = preload("res://scenes/game_camera.tscn")

@onready var level_generator = $LevelGenerator
@onready var ground_sprite = $GroundSprite
@onready var parallax1 = $ParallaxBackground/ParallaxLayer1
@onready var generator_area = $GeneratorArea
@onready var hud = $UILayer/HUD
@onready var time_label = $UILayer/HUD/TopBar/TimeLabel

@export var level_spawn_rate: int = 200
@export var next_level_score: int = 10
@export var player_speed_increment: int = 25
@export var rock_size_increment: float = 0.1
@export var last_level:int = 4

var viewport_size: Vector2
var player: Player = null
var player_spawn_position: Vector2
var resource_last_spawn_position: float

var camera: GameCamera = null

var level: int = 1
var score: int = 0
var high_score: int = 0
var time: float = 0.0
var best_time: float = 0.0

var player_speed_increase_value: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_size = get_viewport_rect().size
	player_spawn_position = Vector2(10, viewport_size.y / 2.0)
	
	ground_sprite.global_position = Vector2(viewport_size.x / 2.0, viewport_size.y)
	setup_parallax_layer(parallax1)
	
	hud.visible = false
	hud.set_score(score)
	hud.set_level(level)
	hud.set_time(time)
	hud.pause_game.connect(_on_hud_pause_game)
	ground_sprite.visible = false
	
	generator_area.global_position.x = viewport_size.x
	
	level_generator.reward_collected.connect(_on_level_generator_reward_collected)
	#load_score()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("pause"):
		pause_game.emit()
	elif Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	#print("Overlapping bodies: " + str(generator_area.get_overlapping_bodies().size()))
	#print("Resource Last Spawn: " + str(resource_last_spawn_position + level_spawn_rate))
	#print("Generator Area: " + str(generator_area.global_position.x))
	var level_spawn_distance = level_spawn_rate - ((level - 1) * 25)
	if player and generator_area.get_overlapping_bodies().size() == 0 and resource_last_spawn_position + level_spawn_distance < generator_area.global_position.x:
		#print("Dynamically creating an obstacle")
		level_generator.generate_next_node(resource_last_spawn_position + level_spawn_rate, level)
		resource_last_spawn_position += level_spawn_rate
		
	if player:
		generator_area.global_position.x = max(viewport_size.x, player.global_position.x + viewport_size.x)
		
	if score >= next_level_score:
		print("Player advancing to next level: " + str(level))
		if level == last_level:
			hud.visible = false
			time = time_label.time_elapsed
			if time > best_time:
				best_time = time
			player_won.emit(level, time, best_time)
		else:
			time = time_label.time_elapsed
			advance_level.emit()

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

func reset_game():
	ground_sprite.visible = false
	hud.visible = false
	level_generator.reset_level()
	
	if player:
		player.queue_free()
		player = null
		level_generator.player = null
		
	if camera:
		camera.queue_free()
		camera = null 
		
	generator_area.global_position.x = viewport_size.x
	get_tree().paused = false
	
func reset_advancements():
	player_speed_increase_value = 0
	level_generator.rock_scale = 0.8
	
func new_game(_level: int = 1, _score: int = 0, _time:float = 0.0, _player_speed_increment: int = 0, _rock_size_increment: bool = false, reset_advancements = true):
	reset_game()
	if reset_advancements:
		reset_advancements()
	
	#Reset to the first level
	level = _level
	score = _score
	time = _time
	
	hud.set_score(score)
	hud.set_level(level)
	hud.set_time(time)
	
	resource_last_spawn_position = viewport_size.x / 2.0
	
	#Setup the player and add to game scene
	player = player_scene.instantiate()
	player.global_position = player_spawn_position
	player.game_over_signal.connect(_on_player_game_over)
	player_speed_increase_value += _player_speed_increment
	
	player.forward_speed += player_speed_increase_value
	print("Player forward speed: " + str(player.forward_speed) + " Increase Value: " + str(player_speed_increase_value))
	add_child(player)
	
	#Setup the game camera
	camera = camera_scene.instantiate()
	camera.setup_camera(player)
	add_child(camera)
	
	if _rock_size_increment:
		level_generator.rock_scale += rock_size_increment
	
	#Generate the assets that need to display on the screen at the start of the game. 
	while resource_last_spawn_position < viewport_size.x:
		level_generator.generate_next_node(resource_last_spawn_position, level)
		resource_last_spawn_position += level_spawn_rate
	
	if player:
		level_generator.setup(player)
		
	hud.visible = true
	ground_sprite.visible = true


func _on_player_game_over():
	hud.visible = false
	if score > high_score:
		high_score = score
		
	player_died.emit(level, score, high_score)
	
func _on_hud_pause_game():
	print("Game pause pressed")
	pause_game.emit()

func _on_level_generator_reward_collected(value):
	score += value
	hud.set_score(score)
