extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var throwing_knife = $"."
@onready var enemy_detection_zone = $EnemyDetectionZone

@export var speed = -100

func _physics_process(_delta):
	knife_collided()
	handle_knife_velocity()
	move_and_slide()

func knife_collided():
	if is_on_wall() or is_on_floor():
		create_hit_effect()
		queue_free()

func create_hit_effect():
	var effect = load("res://Source/Actors/Enemies/Effects/hit_effect.tscn")
	var effect_instance = effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(effect_instance)
	effect_instance.global_position = throwing_knife.global_position

func handle_knife_velocity():
	if enemy_detection_zone.can_see_player():
			velocity.x = speed
			animated_sprite_2d.flip_h = false

func _on_hitbox_area_entered(_area):
	queue_free()

func _on_hurtbox_area_entered(_area):
	SoundPlayer.play_whip_hit_sound()
	create_hit_effect()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
