extends Node2D

@export_file("*.tscn") var collectible: String

@onready var brazier = $"."
@onready var animated_sprite_2d = $AnimatedSprite2D

func _physics_process(_delta):
	if PlayerData.boss_orb_collected:
		animated_sprite_2d.stop()

func _on_hurtbox_area_entered(_area):
	SoundPlayer.play_whip_hit_sound()
	var death_effect = load("res://Source/Actors/Enemies/Effects/death_effect.tscn")
	var death_effect_instance = death_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(death_effect_instance)
	death_effect_instance.global_position = brazier.global_position
	call_deferred("spawn_item")
	queue_free()

func spawn_item():
	var spawn_collectible = load(collectible)
	var spawn_collectible_instance = spawn_collectible.instantiate()
	var world = get_tree().current_scene
	world.add_child(spawn_collectible_instance)
	spawn_collectible_instance.global_position = brazier.global_position
