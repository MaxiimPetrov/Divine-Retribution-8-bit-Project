extends CharacterBody2D

enum {MOVE, HURT}

@onready var purple_slime_enemy = $"."
@onready var stats = $Stats
@onready var ledge_check_right = $LedgeCheckRight
@onready var ledge_check_left = $LedgeCheckLeft
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hurt_timer = $HurtTimer
@onready var player_detection_zone = $PlayerDetectionZone

@export var gravity = 220
@export var move_speed = 20
@export var hurt_speed = 2

var direction = Vector2.RIGHT
var state = MOVE

func _physics_process(delta):
	if PlayerData.garglius_health <= 0:
		spawn_death_effect()
		queue_free()
	var found_ledge = not ledge_check_right.is_colliding() or not ledge_check_left.is_colliding()
	var found_wall = is_on_wall()
	match state:
		MOVE:
			move_state(found_ledge, found_wall, delta)
		HURT:
			hurt_state(found_ledge, found_wall)

#|||||||||||||||||||||||||THE DIFFERENT STATES||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func move_state(found_ledge, found_wall, delta):
	apply_gravity(delta)
	animated_sprite_2d.play("Move")
	handle_move_state_velocity(found_ledge, found_wall)
	move_and_slide()

func hurt_state(found_ledge, found_wall):
	handle_hurt_state_velocity(found_ledge, found_wall)
	move_and_slide()
	animated_sprite_2d.play("Damaged")
	change_to_move_state()

#|||||||||||||||||||||||||CHANGE STATE FUNCTIONS||||||||||||||||||||||||||||||||||||||||||||||||||||||

func change_to_hurt_state():
	state = HURT

func change_to_move_state():
	if hurt_timer.time_left == 0:
		state = MOVE

#|||||||||||||||||||||||||HURTBOX/DEATH FUNCTIONS|||||||||||||||||||||||||||||||||||||||||||||||||||||

func _on_hurtbox_area_entered(area):
	SoundPlayer.play_whip_hit_sound()
	stats.health -= area.damage
	if stats.health > 0:
		var hit_effect = load("res://Source/Actors/Enemies/Effects/hit_effect.tscn")
		var hit_effect_instance = hit_effect.instantiate()
		var world = get_tree().current_scene
		world.add_child(hit_effect_instance)
		if animated_sprite_2d.flip_h == false:
			hit_effect_instance.global_position.x = purple_slime_enemy.global_position.x - 3
			hit_effect_instance.global_position.y = purple_slime_enemy.global_position.y - 8
		elif animated_sprite_2d.flip_h == true:
			hit_effect_instance.global_position.x = purple_slime_enemy.global_position.x + 3
			hit_effect_instance.global_position.y = purple_slime_enemy.global_position.y - 8
	handle_attack_state_flip_h(area)
	hurt_timer.start()
	change_to_hurt_state()

func _on_stats_no_health():
	spawn_death_effect()
	PlayerData.score += 100
	queue_free()

#|||||||||||||||||||||||||SUPPORTING FUNCTIONS||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func apply_gravity(delta):
	velocity.y += gravity * delta

func handle_attack_state_flip_h(_area):
	if player_detection_zone.can_see_player():
		if player_detection_zone.player.global_position.x > purple_slime_enemy.global_position.x:
			animated_sprite_2d.flip_h = true
		else:
			animated_sprite_2d.flip_h = false

func handle_hurt_state_velocity(found_ledge, found_wall):
	if found_ledge or found_wall:
		direction *= -1
	velocity.x = hurt_speed * direction.x

func handle_move_state_velocity(found_ledge, found_wall):
	if found_ledge or found_wall:
		direction *= -1
	velocity.x = move_speed * direction.x

func spawn_death_effect():
	var death_effect = load("res://Source/Actors/Enemies/Effects/death_effect.tscn")
	var death_effect_instance = death_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(death_effect_instance)
	death_effect_instance.global_position.x = purple_slime_enemy.global_position.x
	death_effect_instance.global_position.y = purple_slime_enemy.global_position.y - 5
