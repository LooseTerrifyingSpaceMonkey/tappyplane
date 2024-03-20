extends Node2D

signal reward_collected(value)

var rock_up_scene = preload("res://scenes/rock_up.tscn")
var rock_down_scene = preload("res://scenes/rock_down.tscn")
var cloud_scene = preload("res://scenes/cloud.tscn")
var reward_scene = preload("res://scenes/reward.tscn")

var rock_up_textures_by_phase = {
	1: load("res://assets/PNG/rock.png"), 
	2: load("res://assets/PNG/rockGrass.png"), 
	3: load("res://assets/PNG/rockSnow.png"),
	4: load("res://assets/PNG/rockIce.png")
}

var rock_down_textures_by_phase = {
	1: load("res://assets/PNG/rockDown.png"), 
	2: load("res://assets/PNG/rockGrassDown.png"), 
	3: load("res://assets/PNG/rockSnowDown.png"),
	4: load("res://assets/PNG/rockIceDown.png")
}

var cloud_textures = {
	1: load("res://assets/PNG/puffSmall.png"),
	2: load("res://assets/PNG/puffLarge.png")
}

var reward_textures_by_value = {
	1: load("res://assets/PNG/starBronze.png"),
	2: load("res://assets/PNG/starSilver.png"),
	3: load("res://assets/PNG/starGold.png")
}

var options_map = {
	1: ["rock_up", "rock_down", "reward_1", "reward_2", "reward_3","rock_up", "rock_down", "rock_up", "rock_down"], 
	2: ["rock_up", "rock_down", "reward_1", "reward_2", "reward_3","rock_up", "rock_down", "rock_up", "rock_down", "rock_up", "rock_down"],
	3: ["rock_up", "rock_down", "reward_1", "reward_2", "reward_3","rock_up", "rock_down", "rock_up", "rock_down", "rock_up", "rock_down", "rock_up", "rock_down"],
	4: ["rock_up", "rock_down", "reward_1", "reward_2", "reward_3","rock_up", "rock_down", "rock_up", "rock_down", "rock_up", "rock_down", "rock_up", "rock_down"],
}

@onready var rock_parent = $RockParent
@onready var cloud_parent = $CloudParent
@onready var reward_parent = $RewardParent

@export var off_screen_amount = 10.0

var player: Player = null
var viewport_size

var start_level_x = 0

var rock_scale = 1.0
var reward_scale = 1.0

func setup(_player: Player):
	if _player:
		player = _player

func _ready():
	viewport_size = get_viewport_rect().size
	
	start_level_x = viewport_size.x / 2.0
	

func create_rock_up(location: Vector2, phase: int = 1, scale: float = 0.8):
	var rock_up = rock_up_scene.instantiate()
	rock_up.global_position = location
	rock_parent.add_child(rock_up)
	rock_up.set_texture(rock_up_textures_by_phase[phase])
	rock_up.set_rock_scale(scale)
	rock_up.set_scale(Vector2(scale, scale))
	
func create_rock_down(location: Vector2, phase: int = 1, scale: float = 0.8):
	var rock_down = rock_down_scene.instantiate()
	rock_down.global_position = location
	rock_parent.add_child(rock_down)
	rock_down.set_texture(rock_down_textures_by_phase[phase])
	rock_down.set_rock_scale(scale)
	rock_down.set_scale(Vector2(scale, scale))
	
func create_cloud(location: Vector2, size: int = 1, scale: float = 1.0):
	var cloud = cloud_scene.instantiate()
	cloud.global_position = location
	cloud_parent.add_child(cloud)
	cloud.set_texture(cloud_textures[size])
	cloud.set_scale(Vector2(scale, scale))
	
func create_reward(location: Vector2, value: int = 1, scale: float = 1.0):
	var reward = reward_scene.instantiate()
	reward.global_position = location
	reward_parent.add_child(reward)
	reward.set_texture(reward_textures_by_value[value])
	reward.reward_value = value
	reward.set_reward_scale(scale)
	reward.reward_collected.connect(_on_reward_reward_collected)
	reward.set_scale(Vector2(scale, scale))
	
func generate_next_node(start_x: float, phase: int = 1):
	var max_y_position = 85
	var min_y_position = viewport_size.y
	
	var reward_1_pos = viewport_size.y * 0.1
	var reward_2_pos = viewport_size.y * 0.2
	var reward_3_pos = viewport_size.y * 0.3
	
	#var rock_up_location: Vector2
	#var rock_down_location: Vector2
	#var cloud_location: Vector2
	#var reward_locaton: Vector2
	
	var selection_number = randi() % options_map[phase].size()
	#print("Selection_number: " + str(selection_number) + " Selection.size(): " + str(options_map[phase].size()))
	var selection = options_map[phase][selection_number]
	match selection:
		"rock_up":
			create_rock_up(Vector2(start_x, min_y_position), phase, rock_scale)
		"rock_down":
			create_rock_down(Vector2(start_x, max_y_position), phase, rock_scale)
		"reward_1":
			create_reward(Vector2(start_x, (min_y_position / 2.0) + (reward_1_pos if randi() % 2 else - reward_1_pos)), 1, reward_scale)
		"reward_2":
			create_reward(Vector2(start_x,(min_y_position / 2.0) + (reward_2_pos if randi() % 2 else - reward_2_pos)), 2, reward_scale)
		"reward_3":
			create_reward(Vector2(start_x, (min_y_position / 2.0) + (reward_3_pos if randi() % 2 else - reward_3_pos)), 3, reward_scale)

func reset_level():
	start_level_x = 0
	for rock in rock_parent.get_children():
		rock.queue_free()
	
	for reward in reward_parent.get_children():
		reward.queue_free()
		
		
func _on_reward_reward_collected(value: int):
	reward_collected.emit(value)
