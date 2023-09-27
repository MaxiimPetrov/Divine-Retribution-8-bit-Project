extends CharacterBody2D

@onready var stay_still_timer = $StayStillTimer
@onready var fade_in_effect = $AnimatedSprite2D/FadeInEffect
@onready var animation_player = $AnimatedSprite2D/AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var wait_after_pickup_timer = $WaitAfterPickupTimer
@onready var disable_player_movement_area = $DisablePlayerMovementArea

var stay_still_timer_started = false
var wait_after_pickup_timer_started = false

func _ready():
	velocity.x = 0
	velocity.y = 0
	animation_player.play("FlickerEffect")
	fade_in_effect.play("FadeIn")

func _physics_process(_delta):
	if not stay_still_timer_started:
		stay_still_timer.start()
		stay_still_timer_started = true
	if stay_still_timer_started and stay_still_timer.time_left == 0:
		velocity.y = 100
		animation_player.stop()
	if wait_after_pickup_timer_started:
		animated_sprite_2d.visible = false
	if wait_after_pickup_timer_started and wait_after_pickup_timer.time_left == 0:
		get_tree().change_scene_to_file("res://Source/UI and Screens/win_screen.tscn")
	move_and_slide()

func _on_detection_zone_area_entered(_area):
	SoundPlayer.play_victory_sound()
	PlayerData.health += 10
	disable_player_movement_area.get_node("CollisionShape2D").scale.x = 30
	disable_player_movement_area.get_node("CollisionShape2D").scale.y = 30
	if not wait_after_pickup_timer_started:
		wait_after_pickup_timer.start()
		wait_after_pickup_timer_started = true
	PlayerData.boss_orb_collected = true
