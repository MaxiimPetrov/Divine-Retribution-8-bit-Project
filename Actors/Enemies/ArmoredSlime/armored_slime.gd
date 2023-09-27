extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ledge_check_left = $LedgeCheckLeft
@onready var ledge_check_right = $LedgeCheckRight
@onready var animation_player = $AnimationPlayer
@onready var armored_slime = $"."
@onready var ledge_checks_timer = $LedgeChecksTimer

@export var gravity = 220
@export var move_speed = -20

var direction = Vector2.RIGHT
var will_despawn = false
var ledges_found = 0
var ledge_checks_disabled_timer_started = false
var start_counting_ledges = false
var will_start_left = false
var velocity_updated = false

func _ready():
	animation_player.play("RESET")

func _physics_process(delta):
	if will_start_left and not velocity_updated:
		move_speed = 20
		velocity_updated = true
	if will_despawn:
		disable_ledge_checks()
	var found_ledge = not ledge_check_right.is_colliding() or not ledge_check_left.is_colliding()
	despawn(found_ledge)
	var found_wall = is_on_wall()
	handle_move_state_velocity(found_ledge, found_wall)
	apply_gravity(delta)
	animated_sprite_2d.play("Move")
	move_and_slide()

func apply_gravity(delta):
	velocity.y += gravity * delta

func handle_move_state_velocity(found_ledge, found_wall):
	if found_ledge or found_wall:
		direction *= -1
	velocity.x = move_speed * direction.x

func _on_hurtbox_area_entered(_area):
	SoundPlayer.play_whip_hit_sound()
	animation_player.play("BlinkWhite")

func despawn(found_ledge):
	if will_despawn:
		if found_ledge:
			if start_counting_ledges:
				ledges_found += 1
		if ledges_found == 1 or PlayerData.garglius_health <= 0:
			spawn_death_effect()
			queue_free()

func spawn_death_effect():
	var death_effect = load("res://Source/Actors/Enemies/Effects/death_effect.tscn")
	var death_effect_instance = death_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(death_effect_instance)
	death_effect_instance.global_position.x = armored_slime.global_position.x
	death_effect_instance.global_position.y = armored_slime.global_position.y - 5

func disable_ledge_checks():
	if not ledge_checks_disabled_timer_started:
			ledge_checks_timer.start()
			ledge_checks_disabled_timer_started = true
	if ledge_checks_disabled_timer_started and ledge_checks_timer.time_left == 0:
			start_counting_ledges = true
