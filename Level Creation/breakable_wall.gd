extends StaticBody2D

@onready var breakable_wall = $"."
@onready var sprite_2d = $Sprite2D

@export var will_spawn_item = false
@export_file("*.tscn") var collectible: String

func _on_hurtbox_area_entered(_area):
	if will_spawn_item:
		call_deferred("spawn_item")
	call_deferred("spawn_break_effect")
	queue_free()

func spawn_item():
	var world = get_tree().current_scene
	var spawn_collectible = load(collectible)
	var spawn_collectible_instance = spawn_collectible.instantiate()
	world.add_child(spawn_collectible_instance)
	spawn_collectible_instance.global_position = breakable_wall.global_position

func spawn_break_effect():
	var world = get_tree().current_scene
	var break_effect = load("res://Source/Actors/Enemies/Effects/wall_break_effect.tscn")
	var break_effect_instance = break_effect.instantiate()
	world.add_child(break_effect_instance)
	break_effect_instance.global_position.y = breakable_wall.global_position.y - 10
	break_effect_instance.global_position.x = breakable_wall.global_position.x
