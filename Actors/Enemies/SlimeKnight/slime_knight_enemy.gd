extends CharacterBody2D

enum {MOVE, RANGED, MELEE}

@onready var slime_knight_enemy = $"."
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var player_detection_zone_far = $PlayerDetectionZoneFar
@onready var player_detection_zone_close = $PlayerDetectionZoneClose
@onready var switch_to_ranged_state_timer = $SwitchToRangedStateTimer
@onready var animation_player = $AnimatedSprite2D/AnimationPlayer
@onready var stats = $Stats
@onready var melee_timer = $MeleeTimer
@onready var hurtbox = $Hurtbox
@onready var axe_hitbox_pivot = $AxeHitboxPivot
@onready var hitbox = $AxeHitboxPivot/Hitbox
@onready var ledge_check_left = $LedgeCheckLeft
@onready var ledge_check_right = $LedgeCheckRight

@export var gravity = 500
@export var speed = 2

var state = MOVE
var switch_to_ranged_state_timer_started = false
var melee_timer_started = false

func _ready():
	slime_knight_enemy.global_position.y -= 1

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		RANGED:
			ranged_state()
		MELEE:
			melee_state()

#|||||||||||||||||||||||||THE DIFFERENT STATES||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func move_state(delta):
	var found_ledge = not ledge_check_left.is_colliding() or not ledge_check_right.is_colliding()
	melee_timer.stop()
	axe_hitbox_pivot.get_node("Hitbox/CollisionShape2D").disabled = true
	if velocity.x == 0:
		animated_sprite_2d.play("Idle")
	else:
		animated_sprite_2d.play("Walk")
	apply_gravity(delta)
	move_and_slide()
	if player_detection_zone_far.can_see_player() and not player_detection_zone_close.can_see_player():
		if not switch_to_ranged_state_timer_started:
			switch_to_ranged_state_timer.start()
			switch_to_ranged_state_timer_started = true
		if slime_knight_enemy.global_position.x > player_detection_zone_far.player.global_position.x:
			if found_ledge:
				velocity.x = 0
			else:
				velocity.x = -speed
			animated_sprite_2d.scale.x = 1
			animated_sprite_2d.position.x = 0
		else:
			if found_ledge:
				velocity.x = 0
			else:
				velocity.x = speed
			animated_sprite_2d.scale.x = -1
			animated_sprite_2d.position.x = 5
		if switch_to_ranged_state_timer.time_left == 0 and switch_to_ranged_state_timer_started == true:
			switch_to_ranged_state_timer.stop()
			switch_to_ranged_state_timer_started = false
			state = RANGED
	elif player_detection_zone_close.can_see_player():
		state = MELEE
	else:
		if switch_to_ranged_state_timer_started:
			switch_to_ranged_state_timer.stop()
			switch_to_ranged_state_timer_started = false
		velocity.x = 0
	move_and_slide()

func ranged_state():
	melee_timer.stop()
	axe_hitbox_pivot.get_node("Hitbox/CollisionShape2D").disabled = true
	if player_detection_zone_far.can_see_player():
		if slime_knight_enemy.global_position.x > player_detection_zone_far.player.global_position.x:
			animated_sprite_2d.scale.x = 1
			animated_sprite_2d.position.x = 0
		else:
			animated_sprite_2d.scale.x = -1
			animated_sprite_2d.position.x = 5
	animation_player.play("Ranged_Attack")

func melee_state():
	handle_axe_hitbox_pivot()
	if player_detection_zone_far.can_see_player():
		if slime_knight_enemy.global_position.x > player_detection_zone_far.player.global_position.x:
			animated_sprite_2d.scale.x = 1
			animated_sprite_2d.position.x = 0
		else:
			animated_sprite_2d.scale.x = -1
			animated_sprite_2d.position.x = 5
	
	if not melee_timer_started:
		melee_timer.start()
		melee_timer_started = true
	
	if melee_timer.time_left == 0 and melee_timer_started == true:
		animation_player.play("Melee_Attack")
	else:
		animated_sprite_2d.play("Idle")
		animated_sprite_2d.frame = 0

#|||||||||||||||||||||||||CHANGE STATE FUNCTIONS||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func ranged_attack_animation_finished():
	if player_detection_zone_close.can_see_player() and player_detection_zone_far.can_see_player():
		state = MELEE
	else:
		state = MOVE

func melee_attack_animation_finished():
	melee_timer_started = false
	if player_detection_zone_close.can_see_player():
		state = MELEE
	else:
		state = MOVE

#|||||||||||||||||||||||||HURTBOX/DEATH FUNCTIONS|||||||||||||||||||||||||||||||||||||||||||||||||||||

func _on_hurtbox_area_entered(area):
	SoundPlayer.play_whip_hit_sound()
	stats.health -= area.damage
	if stats.health > 0:
		var hit_effect = load("res://Source/Actors/Enemies/Effects/hit_effect.tscn")
		var hit_effect_instance = hit_effect.instantiate()
		var world = get_tree().current_scene
		world.add_child(hit_effect_instance)
		if animated_sprite_2d.scale.x == 1:
			hit_effect_instance.global_position.x = slime_knight_enemy.global_position.x + 3
			hit_effect_instance.global_position.y = slime_knight_enemy.global_position.y - 25
		elif animated_sprite_2d.scale.x == -1:
			hit_effect_instance.global_position.x = slime_knight_enemy.global_position.x - 3
			hit_effect_instance.global_position.y = slime_knight_enemy.global_position.y - 25

func _on_stats_no_health():
	var death_effect = load("res://Source/Actors/Enemies/Effects/death_effect.tscn")
	var death_effect_instance = death_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(death_effect_instance)
	death_effect_instance.global_position.x = slime_knight_enemy.global_position.x
	death_effect_instance.global_position.y = slime_knight_enemy.global_position.y - 15
	PlayerData.score += 200
	queue_free()

#|||||||||||||||||||||||||SUPPORTING FUNCTIONS||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func apply_gravity(delta):
	velocity.y += gravity * delta

func throw_knife():
	if animated_sprite_2d.scale.x == 1:
		var knife = load("res://Source/Actors/Enemies/SlimeKnight/throwing_knife_left.tscn")
		var knife_instance = knife.instantiate()
		var world = get_tree().current_scene
		world.add_child(knife_instance)
		knife_instance.global_position.x = slime_knight_enemy.global_position.x
		knife_instance.global_position.y = slime_knight_enemy.global_position.y - 25
	else:
		var knife = load("res://Source/Actors/Enemies/SlimeKnight/throwing_knife_right.tscn")
		var knife_instance = knife.instantiate()
		var world = get_tree().current_scene
		world.add_child(knife_instance)
		knife_instance.global_position.x = slime_knight_enemy.global_position.x
		knife_instance.global_position.y = slime_knight_enemy.global_position.y - 25

func handle_axe_hitbox_pivot():
	if animated_sprite_2d.scale.x == -1:
		axe_hitbox_pivot.rotation_degrees = 0
		hitbox.get_node("CollisionShape2D").position.x = 29
	else:
		axe_hitbox_pivot.rotation_degrees = 180
		hitbox.get_node("CollisionShape2D").position.x = 24
