extends CharacterBody2D

@onready var disappear_timer = $DisappearTimer
@onready var animation_player = $AnimationPlayer

var currently_moving_right = true
var currently_moving_left = false
var rng = RandomNumberGenerator.new()

func _ready():
	var random = rng.randi_range(0,1)
	disappear_timer.start()
	if random == 0:
		velocity.x = 30
	else:
		velocity.x = -30

func _physics_process(delta):
	handle_flicker_effect()
	if not is_on_floor():
		velocity.y = 20
		if currently_moving_right:
			velocity.x = move_toward(velocity.x, 30, 50 * delta)
			if velocity.x == 30:
				currently_moving_right = false
				currently_moving_left = true
		if currently_moving_left:
			velocity.x = move_toward(velocity.x, -30, 50 * delta)
			if velocity.x == -30:
				currently_moving_right = true
				currently_moving_left = false
	else:
		velocity.x = 0
		velocity.y = 0
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
	PlayerData.essence_value += 1
	queue_free()
