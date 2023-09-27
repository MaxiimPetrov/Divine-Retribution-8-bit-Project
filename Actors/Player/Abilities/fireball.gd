extends CharacterBody2D

@onready var player_detection_zone = $PlayerDetectionZone
@onready var fireball = $"."
@onready var animated_sprite_2d = $AnimatedSprite2D

@export var speed = 200

func _physics_process(_delta):
	handle_fireball_velocity()
	fireball_collided()
	move_and_slide()

func fireball_collided():
	if is_on_wall() or is_on_floor():
		create_hit_effect()
		queue_free()

func _on_hitbox_area_entered(_area):
	create_hit_effect()
	queue_free()

func create_hit_effect():
	var fireball_hit_effect = load("res://Source/Actors/Player/Abilities/fireball_hit_effect.tscn")
	var instance_fireball_hit_effect = fireball_hit_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(instance_fireball_hit_effect)
	if animated_sprite_2d.flip_h == true:
		instance_fireball_hit_effect.get_node("AnimatedSprite2D").flip_h = true
	else:
		instance_fireball_hit_effect.get_node("AnimatedSprite2D").flip_h = false
	instance_fireball_hit_effect.global_position = fireball.global_position

func handle_fireball_velocity():
	if player_detection_zone.can_see_player():
		if player_detection_zone.player.get_node("AnimatedSprite2D").flip_h == false:
			velocity.x = speed
			animated_sprite_2d.flip_h = false
		else:
			velocity.x = -speed
			animated_sprite_2d.flip_h = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
