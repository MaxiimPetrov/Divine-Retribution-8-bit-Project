extends CharacterBody2D

@export var speed = 75
@export var gravity = 350

func _ready():
	velocity.y = -175

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity.x = speed
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
