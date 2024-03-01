extends Node2D

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

@onready var rock_parent = $RockParent
@onready var cloud_parent = $CloudParent
@onready var reward_parent = $RewardParent

@export var level_size = 10

@export var off_screen_amount = 10.0

var player: Player = null
var viewport_size

var start_level_x = 0

func setup(_player: Player):
	if _player:
		player = _player

func _ready():
	viewport_size = get_viewport_rect().size
	
	start_level_x = viewport_size.x / 2.0
	

func create_rock_up(location: Vector2, phase: int = 1, scale: float = 1.0):
	var rock_up = rock_up_scene.instantiate()
	rock_up.global_position = location
	rock_parent.add_child(rock_up)
	rock_up.set_texture(rock_up_textures_by_phase[phase])
	rock_up.set_scale(Vector2(scale, scale))
	
func create_rock_down(location: Vector2, phase: int = 1, scale: float = 1.0):
	var rock_down = rock_down_scene.instantiate()
	rock_down.global_position = location
	rock_parent.add_child(rock_down)
	rock_down.set_texture(rock_down_textures_by_phase[phase])
	rock_down.set_scale(Vector2(scale, scale))
	
func create_cloud(location: Vector2, size: int = 1, scale: float = 1.0):
	var cloud = cloud_scene.instantiate()
	cloud.global_position = location
	cloud_parent.add_child(cloud)
	cloud.set_texturee(cloud_textures[size])
	cloud.set_scale(Vector2(scale, scale))
	
func create_reward(location: Vector2, value: int = 1, scale: float = 1.0):
	var reward = reward_scene.instantiate()
	reward.global_position = location
	reward_parent.add_child(reward)
	reward.set_texture(reward_textures_by_value[value])
	reward.set_scale(Vector2(scale, scale))
	
func generate_next_node(start_x: float, phase: int = 1):
	var max_y_position = 0
	var min_y_position = viewport_size.y
	
	var rock_up_location: Vector2
	var rock_down_location: Vector2
	var cloud_location: Vector2
	var reward_locaton: Vector2
	
	create_rock_up(Vector2(start_x, viewport_size.y))
