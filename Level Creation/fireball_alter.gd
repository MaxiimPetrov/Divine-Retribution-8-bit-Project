extends Node2D

@onready var fireball_alter = $"."
@onready var animated_sprite_2d = $AnimatedSprite2D

var destroyed = false

func _on_hurtbox_area_entered(_area):
	if not destroyed:
		SoundPlayer.play_whip_hit_sound()
		animated_sprite_2d.play("Broken")
		call_deferred("spawn_pickup")
		destroyed = true

func spawn_pickup():
	var flame_pickup = load("res://Source/Level Creation/flame_pickup.tscn")
	var flame_pickup_instance = flame_pickup.instantiate()
	var world = get_tree().current_scene
	world.add_child(flame_pickup_instance)
	flame_pickup_instance.global_position = fireball_alter.global_position
