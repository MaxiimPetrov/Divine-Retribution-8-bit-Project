extends CharacterBody2D

@onready var armored_bear_enemy = $"."
@onready var player_detection_zone = $PlayerDetectionZone
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var stats = $Stats
@onready var despawn_timer = $DespawnTimer

@export var speed = 125
@export var gravity = 10000

var velocity_has_been_set = false
var will_despawn = true
var despawn_timer_started = false

func _physics_process(delta):
	despawn()
	running(delta)

func running(delta):
	animated_sprite_2d.play("Running")
	apply_gravity(delta)
	if player_detection_zone.can_see_player() and not velocity_has_been_set:
		velocity_has_been_set = true
		if player_detection_zone.player.global_position.x > armored_bear_enemy.global_position.x:
			animated_sprite_2d.flip_h = false
			velocity.x = speed
		else:
			velocity.x = -speed
			animated_sprite_2d.flip_h = true
	move_and_slide()

func apply_gravity(delta):
	velocity.y += gravity * delta

func _on_stats_no_health():
	var death_effect = load("res://Source/Actors/Enemies/Effects/death_effect.tscn")
	var death_effect_instance = death_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(death_effect_instance)
	death_effect_instance.global_position = armored_bear_enemy.global_position
	PlayerData.score += 200
	queue_free()

func _on_hurtbox_area_entered(area):
	SoundPlayer.play_whip_hit_sound()
	stats.health -= area.damage
	if stats.health > 0:
		var hit_effect = load("res://Source/Actors/Enemies/Effects/hit_effect.tscn")
		var hit_effect_instance = hit_effect.instantiate()
		var world = get_tree().current_scene
		world.add_child(hit_effect_instance)
		hit_effect_instance.global_position.x = armored_bear_enemy.global_position.x - 10
		hit_effect_instance.global_position.y = armored_bear_enemy.global_position.y -10

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func despawn():
	if not despawn_timer_started:
		despawn_timer.start()
		despawn_timer_started = true
	if despawn_timer_started and despawn_timer.time_left == 0:
		if will_despawn:
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered():
	will_despawn = false
