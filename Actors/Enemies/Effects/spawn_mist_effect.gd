extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var animation_looped = 0
var will_end = true

func _ready():
	animated_sprite_2d.play("Effect")

func _on_animated_sprite_2d_animation_looped():
	if will_end:
		animation_looped += 1

func _physics_process(_delta):
	if will_end:
		if animation_looped == 2:
			queue_free()
