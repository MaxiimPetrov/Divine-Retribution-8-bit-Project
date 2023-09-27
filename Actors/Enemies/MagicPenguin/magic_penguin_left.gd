extends CharacterBody2D

@onready var stats = $Stats
@onready var magic_penguin_left = $"."

@export var maximum_speed = 120
@export var acceleration = 200
@export var speed = 45

var currently_moving_up = true
var currently_moving_down = false
var was_on_screen = false
var rng = RandomNumberGenerator.new()

func _ready():
	var random = rng.randi_range(0,1)
	if random == 0:
		velocity.y = maximum_speed
	else:
		velocity.y = -maximum_speed

func _physics_process(delta):
	if PlayerData.garglius_health <= 0:
		spawn_death_effect()
		queue_free()
	velocity.x = -speed
	if currently_moving_up:
		velocity.y = move_toward(velocity.y, -maximum_speed, acceleration * delta)
		if velocity.y == -maximum_speed:
			currently_moving_up = false
			currently_moving_down = true
	if currently_moving_down:
		velocity.y = move_toward(velocity.y, maximum_speed, acceleration * delta)
		if velocity.y == maximum_speed:
			currently_moving_up = true
			currently_moving_down = false
			
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_entered():
	was_on_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	if was_on_screen:
		queue_free()

func _on_hurtbox_area_entered(area):
	SoundPlayer.play_whip_hit_sound()
	stats.health -= area.damage

func _on_stats_no_health():
	spawn_death_effect()
	PlayerData.score += 100
	queue_free()

func spawn_death_effect():
	var death_effect = load("res://Source/Actors/Enemies/Effects/death_effect.tscn")
	var death_effect_instance = death_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(death_effect_instance)
	death_effect_instance.global_position = magic_penguin_left.global_position
