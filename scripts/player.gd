class_name Player
extends CharacterBody2D

signal game_over_signal

@onready var animation_player = $AnimationPlayer

@export var gravity = 15.0
@export var max_gravity = 1000
@export var tap_lift = -300
@export var forward_speed = 180

var top_of_screen_y_value = 20
var alive = true
var viewport_size

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = forward_speed
	
	viewport_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if alive:
		velocity.y += gravity
		velocity.y = minf(velocity.y, max_gravity)

		if Input.is_action_just_pressed("lift"):
			velocity.y = tap_lift

		global_position.y = maxf(top_of_screen_y_value, global_position.y)
		
		if global_position.y > viewport_size.y:
			die()
			
		move_and_slide()

func die():
	print("Player died")
	if alive:
		alive = false
		animation_player.play("death")
		game_over_signal.emit()
