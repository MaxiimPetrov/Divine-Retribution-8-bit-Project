extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var disappear_timer = $DisappearTimer

func _ready():
	disappear_timer.start()

func _physics_process(_delta):
	handle_flicker_effect()
	velocity.y = 200
	move_and_slide()

func handle_flicker_effect():
	if disappear_timer.time_left < 5 and disappear_timer.time_left > 2:
		animation_player.play("FlickerEffect(slow)")
	if disappear_timer.time_left < 2:
		animation_player.play("FlickerEffect(fast)")
	if disappear_timer.time_left == 0:
		queue_free()

func _on_detection_zone_area_entered(_area):
	SoundPlayer.play_essence_pickup_sound()
	PlayerData.essence_value += 3
	queue_free()
