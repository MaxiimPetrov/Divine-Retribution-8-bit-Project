extends CharacterBody2D

enum {RANDOM, RUN}

@onready var funny_bones = $"."
@onready var wait_to_move_timer = $Timers/WaitToMoveTimer
@onready var moving_timer = $Timers/MovingTimer
@onready var close_player_detection_zone = $ClosePlayerDetectionZone
@onready var halfway_player_detection_zone = $HalfwayPlayerDetectionZone
@onready var far_player_detection_zone = $FarPlayerDetectionZone
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var throw_bone_halfway_timer = $Timers/ThrowBoneHalfwayTimer
@onready var throw_bone_close_timer = $Timers/ThrowBoneCloseTimer
@onready var stats = $Stats
@onready var ledge_check_left = $LedgeCheckLeft
@onready var ledge_check_right = $LedgeCheckRight
@onready var throw_bone_far_timer = $Timers/ThrowBoneFarTimer

@export var gravity = 1000
@export var speed = 50
@export var will_throw_far = true
@export var will_throw_mid = true

var rng = RandomNumberGenerator.new()
var wait_to_move_timer_started = false
var moving_timer_started = false
var random_velocity_has_been_set = false
var throw_bone_halfway_timer_started = false
var throw_bone_close_timer_started = false
var throw_bone_far_timer_started = false
var state = RANDOM

func _ready():
	funny_bones.global_position.y -= 1

func _physics_process(delta):
	handle_flip_h()
	if PlayerData.garglius_health <= 0:
		spawn_death_effect()
		queue_free()
	match state:
		RANDOM:
			random_state(delta)
		RUN:
			run_state(delta)

#|||||||||||||||||||||||||THE DIFFERENT STATES||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func random_state(delta):
	var found_ledge = not ledge_check_right.is_colliding() or not ledge_check_left.is_colliding()
	var random = rng.randi_range(0,1)
	
	if found_ledge:
		if not close_player_detection_zone.can_see_player():
			if not ledge_check_left.is_colliding():
				velocity.x = 1
			if not ledge_check_right.is_colliding():
				velocity.x = -1
		else:
			switch_to_run_state()
	else:
		if not close_player_detection_zone.can_see_player():
			handle_random_move_velocity(random)
		else:
			switch_to_run_state()
	if halfway_player_detection_zone.can_see_player():
		if will_throw_mid:
			throw_bones_halfway()
	elif far_player_detection_zone.can_see_player():
		if will_throw_far:
			throw_bones_far()
	apply_gravity(delta)
	
	move_and_slide()

func run_state(delta):
	var found_ledge = not ledge_check_right.is_colliding() or not ledge_check_left.is_colliding()
	apply_gravity(delta)
	throw_bones_close()
	if found_ledge:
		if close_player_detection_zone.can_see_player():
			if not ledge_check_left.is_colliding():
				velocity.x = 1
			if not ledge_check_right.is_colliding():
				velocity.x = -1
	else:
		handle_run_move_velocity()
	
	if not close_player_detection_zone.can_see_player():
		switch_to_random_state()
	move_and_slide()

#|||||||||||||||||||||||||SWITCH STATE FUNCTIONS||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func switch_to_random_state():
	random_velocity_has_been_set = false
	wait_to_move_timer_started = false
	moving_timer_started = false
	state = RANDOM

func switch_to_run_state():
	random_velocity_has_been_set = false
	wait_to_move_timer_started = false
	moving_timer_started = false
	state = RUN

#|||||||||||||||||||||||||SUPPORTING FUNCTIONS||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func throw_bones_halfway():
	if halfway_player_detection_zone.can_see_player():
		if not throw_bone_halfway_timer_started:
			throw_bone_halfway_timer.start()
			throw_bone_halfway_timer_started = true
		
		if throw_bone_halfway_timer.time_left == 0 and throw_bone_halfway_timer_started == true:
			var spawn_bone = load("res://Source/Actors/Enemies/FunnyBones/bone.tscn")
			var spawn_bone_instance = spawn_bone.instantiate()
			var world = get_tree().current_scene
			world.add_child(spawn_bone_instance)
			spawn_bone_instance.global_position = funny_bones.global_position
			throw_bone_halfway_timer_started = false

func throw_bones_close():
	if close_player_detection_zone.can_see_player():
		if not throw_bone_close_timer_started:
			throw_bone_close_timer.start()
			throw_bone_close_timer_started = true
		
		if throw_bone_close_timer.time_left == 0 and throw_bone_close_timer_started == true:
			var spawn_bone = load("res://Source/Actors/Enemies/FunnyBones/bone.tscn")
			var spawn_bone_instance = spawn_bone.instantiate()
			var world = get_tree().current_scene
			world.add_child(spawn_bone_instance)
			spawn_bone_instance.global_position = funny_bones.global_position
			spawn_bone_instance.speed = speed / 1.5
			throw_bone_close_timer_started = false

func throw_bones_far():
	if far_player_detection_zone.can_see_player():
		if not throw_bone_far_timer_started:
			throw_bone_far_timer.start()
			throw_bone_far_timer_started = true
		
		if throw_bone_far_timer.time_left == 0 and throw_bone_far_timer_started == true:
			var spawn_bone = load("res://Source/Actors/Enemies/FunnyBones/bone.tscn")
			var spawn_bone_instance = spawn_bone.instantiate()
			var world = get_tree().current_scene
			world.add_child(spawn_bone_instance)
			spawn_bone_instance.global_position = funny_bones.global_position
			spawn_bone_instance.speed = speed * 2
			throw_bone_far_timer_started = false

func apply_gravity(delta):
	velocity.y += gravity * delta

func handle_random_move_velocity(random):
	if not wait_to_move_timer_started:
		wait_to_move_timer.start()
		wait_to_move_timer_started = true
	
	if wait_to_move_timer.time_left == 0 and wait_to_move_timer_started == true:
		if not moving_timer_started:
			moving_timer.start()
			moving_timer_started = true
	
		if moving_timer.time_left != 0 and moving_timer_started == true:
			if halfway_player_detection_zone.can_see_player():
				if random == 0 and not random_velocity_has_been_set:
					velocity.x = speed
					random_velocity_has_been_set = true
				elif random == 1 and not random_velocity_has_been_set:
					velocity.x = -speed
					random_velocity_has_been_set = true
			else:
				if far_player_detection_zone.can_see_player():
					if funny_bones.global_position.x > far_player_detection_zone.player.global_position.x:
						velocity.x = -speed
					else:
						velocity.x = speed
	
		if moving_timer.time_left == 0 and moving_timer_started == true:
			velocity.x = 0
			random_velocity_has_been_set = false
			wait_to_move_timer_started = false
			moving_timer_started = false

func handle_run_move_velocity():
	if not wait_to_move_timer_started:
		wait_to_move_timer.start()
		wait_to_move_timer_started = true
	
	if wait_to_move_timer.time_left == 0 and wait_to_move_timer_started == true:
		if not moving_timer_started:
			moving_timer.start()
			moving_timer_started = true
	
	if moving_timer.time_left != 0 and moving_timer_started == true and far_player_detection_zone.can_see_player():
		if funny_bones.global_position.x > far_player_detection_zone.player.global_position.x:
			velocity.x = speed
		else:
			velocity.x = -speed
	
	if moving_timer.time_left == 0 and moving_timer_started == true:
		velocity.x = 0
		random_velocity_has_been_set = false
		wait_to_move_timer_started = false
		moving_timer_started = false

func handle_flip_h():
	if far_player_detection_zone.can_see_player():
		if funny_bones.global_position.x > far_player_detection_zone.player.global_position.x:
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.flip_h = true

func _on_hurtbox_area_entered(area):
	SoundPlayer.play_whip_hit_sound()
	stats.health -= area.damage

func _on_stats_no_health():
	spawn_death_effect()
	PlayerData.score += 200
	queue_free()

func spawn_death_effect():
	var death_effect = load("res://Source/Actors/Enemies/Effects/death_effect.tscn")
	var death_effect_instance = death_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(death_effect_instance)
	death_effect_instance.global_position.x = funny_bones.global_position.x
	death_effect_instance.global_position.y = funny_bones.global_position.y - 20
