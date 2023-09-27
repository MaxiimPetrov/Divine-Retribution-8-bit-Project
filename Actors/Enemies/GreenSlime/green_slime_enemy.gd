extends CharacterBody2D

enum {IDLE, JUMPING}

@onready var jumping_slime_enemy = $"."
@onready var player_detection_zone = $PlayerDetectionZone
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var switch_state_to_jumping_timer = $SwitchStateToJumpingTimer
@onready var switch_state_to_idle_timer = $SwitchStateToIdleTimer
@onready var stats = $Stats

@export var gravity = 240
@export var jump_velocity = -130
@export var speed = 80

var state = IDLE
var velocity_has_been_set = false
var switch_state_to_idle_timer_started = false
var switch_state_to_jumping_timer_started = false
var player_detection_zone_updated = false

func _physics_process(delta):
	if PlayerData.garglius_health <= 0:
		spawn_death_effect()
		queue_free()
	update_player_detection_zone()
	match state:
		IDLE:
			idle_state(delta)
		JUMPING:
			jumping_state(delta)

#|||||||||||||||||||||||||THE DIFFERENT STATES||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func idle_state(delta):
	apply_gravity(delta)
	animated_sprite_2d.play("Idle")
	velocity.x = 0
	velocity.y = 0
	
	start_switch_state_to_jumping_timer()
	
	switch_to_jumping_state()

func jumping_state(delta):
	hanlde_jumping_state_animations()
	apply_gravity(delta)
	
	determine_jumping_state_velocity()
	
	var was_in_air = not is_on_floor()
	var x_velocity_before_collision = velocity.x
	move_and_slide()
	var just_landed = was_in_air and is_on_floor()
	maintain_x_velocity_after_collision(x_velocity_before_collision)
	start_switch_state_to_idle_timer(just_landed)
	switch_to_idle_state()

#|||||||||||||||||||||||||CHANGE STATE FUNCTIONS||||||||||||||||||||||||||||||||||||||||||||||||||||||

func switch_to_jumping_state():
	if switch_state_to_jumping_timer.time_left == 0 and switch_state_to_jumping_timer_started:
		switch_state_to_jumping_timer_started = false
		state = JUMPING

func switch_to_idle_state():
	if switch_state_to_idle_timer.time_left == 0 and switch_state_to_idle_timer_started:
		velocity_has_been_set = false
		switch_state_to_idle_timer_started = false
		state = IDLE

#|||||||||||||||||||||||||HURTBOX/DEATH FUNCTIONS|||||||||||||||||||||||||||||||||||||||||||||||||||||

func _on_stats_no_health():
	spawn_death_effect()
	PlayerData.score += 150
	queue_free()

func _on_hurtbox_area_entered(area):
	SoundPlayer.play_whip_hit_sound()
	stats.health -= area.damage
	if stats.health > 0:
		var hit_effect = load("res://Source/Actors/Enemies/Effects/hit_effect.tscn")
		var hit_effect_instance = hit_effect.instantiate()
		var world = get_tree().current_scene
		world.add_child(hit_effect_instance)
		hit_effect_instance.global_position.x = jumping_slime_enemy.global_position.x - 3
		hit_effect_instance.global_position.y = jumping_slime_enemy.global_position.y - 8

#|||||||||||||||||||||||||SUPPORTING FUNCTIONS||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func apply_gravity(delta):
	velocity.y += gravity * delta

func start_switch_state_to_jumping_timer():
	if player_detection_zone.can_see_player() and not switch_state_to_jumping_timer_started:
		switch_state_to_jumping_timer.start()
		switch_state_to_jumping_timer_started = true

func start_switch_state_to_idle_timer(just_landed):
	if just_landed:
		switch_state_to_idle_timer.start()
		switch_state_to_idle_timer_started = true

func hanlde_jumping_state_animations():
	if is_on_floor():
		animated_sprite_2d.play("Idle")
		velocity.x = 0
	else:
		animated_sprite_2d.play("Jumping")

func determine_jumping_state_velocity():
	if player_detection_zone.can_see_player():
		if not velocity_has_been_set:
			if jumping_slime_enemy.global_position.x < player_detection_zone.player.global_position.x:
				velocity.x = speed
				velocity.y = jump_velocity
			else:
				velocity.x = -speed
				velocity.y = jump_velocity
			velocity_has_been_set = true

func maintain_x_velocity_after_collision(x_velocity_before_collision):
	if not is_on_floor():
		velocity.x = x_velocity_before_collision

func update_player_detection_zone():
	if player_detection_zone.can_see_player() and not player_detection_zone_updated:
		player_detection_zone.scale.x = 2.5
		player_detection_zone.scale.y = 2.5
		player_detection_zone_updated = true

func spawn_death_effect():
	var death_effect = load("res://Source/Actors/Enemies/Effects/death_effect.tscn")
	var death_effect_instance = death_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(death_effect_instance)
	death_effect_instance.global_position.x = jumping_slime_enemy.global_position.x
	death_effect_instance.global_position.y = jumping_slime_enemy.global_position.y - 5
