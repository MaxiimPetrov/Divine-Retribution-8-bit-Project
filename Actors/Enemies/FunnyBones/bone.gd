extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var player_detection_zone = $PlayerDetectionZone
@onready var bone = $"."

@export var speed = 75
@export var gravity = 400

func _ready():
	velocity.y = -250

func _physics_process(delta):
	handle_bone_velocity(delta)
	move_and_slide()

func handle_bone_velocity(delta):
	velocity.y += gravity * delta
	if player_detection_zone.can_see_player():
		if player_detection_zone.player.get_node("AnimatedSprite2D").flip_h == false:
			velocity.x = -speed
			animated_sprite_2d.flip_h = false
		else:
			velocity.x = speed
			animated_sprite_2d.flip_h = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_hitbox_area_entered(_area):
	queue_free()

func _on_hurtbox_area_entered(_area):
	SoundPlayer.play_whip_hit_sound()
	create_hit_effect()
	queue_free()

func create_hit_effect():
	var hit_effect = load("res://Source/Actors/Enemies/Effects/hit_effect.tscn")
	var hit_effect_instance = hit_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(hit_effect_instance)
	hit_effect_instance.global_position = bone.global_position
