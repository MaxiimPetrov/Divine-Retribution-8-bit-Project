extends CharacterBody2D

enum {MOVE, FELL, ATTACK, FIREBALL, CROUCH, STAIRS, HURT_STANDING, HURT_CROUCHED, HURT_STAIRS, DEAD}

@onready var player = $"."
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimatedSprite2D/AnimationPlayer
@onready var falling_duration_timer = $Timers/FallingDurationTimer
@onready var stagger_on_floor_timer = $Timers/StaggerOnFloorTimer
@onready var hurt_timer = $Timers/HurtTimer
@onready var hurt_timer_on_stairs = $Timers/HurtTimerOnStairs
@onready var standing_hurtbox = $StandingHurtbox
@onready var crouched_hurtbox = $CrouchedHurtbox
@onready var attack_hitbox_pivot = $AttackHitboxPivot
@onready var whip_hitbox = $AttackHitboxPivot/WhipHitbox
@onready var remote_transform_2d = $RemoteTransform2D
@onready var dead_timer = $Timers/DeadTimer
@onready var effects_player = $AnimatedSprite2D/EffectsPlayer
@onready var i_frames_timer = $Timers/iFramesTimer
@onready var disable_movement_area = $DisableMovementArea

@export var gravity = 600.0
@export var minimum_y_velocity = 350.0
@export var speed = 50
@export var jump_velocity = -220

var i_frames_timer_started = false
var dead_timer_started = false
var falling_duration_timer_started = false  
var hurt_timer_started = false
var whip_animation_playing = false
var fireball_animation_playing = false
var fireball_has_been_shot = false
var previous_facing_direction = ""
var previous_facing_direction_has_been_set = false
var was_in_hurt_state = false
var movement_disabled_animations_will_pause = false
var state = MOVE

func _ready():
	velocity.y = minimum_y_velocity
	animated_sprite_2d.play("Idle")

func _physics_process(delta):
	var input_axis = Input.get_axis("Left", "Right")
	var is_on_stairs_check = get_floor_normal()
	handle_i_frames(is_on_stairs_check)
	if PlayerData.player_movement_disabled == true:
		disable_player_movement()
	else:
		match state:
			MOVE:
				move_state(delta, input_axis, is_on_stairs_check)
			FELL:
				fell_state()
			ATTACK:
				attack_state(delta, is_on_stairs_check)
			FIREBALL:
				fireball_state(delta, is_on_stairs_check)
			STAIRS:
				stair_state(input_axis, is_on_stairs_check)
			CROUCH:
				crouch_state(input_axis)
			HURT_STANDING:
				hurt_standing_state(delta)
			HURT_CROUCHED:
				hurt_crouched_state(delta)
			HURT_STAIRS:
				hurt_stairs_state()
			DEAD:
				dead_state()

#|||||||||||||||||||||||||THE DIFFERENT STATES||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func move_state(delta, input_axis, is_on_stairs_check):
	animated_sprite_2d.position.x = 0
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	apply_gravity(delta)
	velocity.y = min(velocity.y, minimum_y_velocity)   
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	handle_movement(input_axis, is_on_stairs_check)
	handle_move_state_animations(input_axis)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	var x_velocity_before_collision = velocity.x
	var y_velocity_before_collision = velocity.y
	var was_in_air = not is_on_floor()    
	move_and_slide()
	var just_landed = was_in_air and is_on_floor()
	var is_on_stairs_check_after_frame = get_floor_normal()
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	change_to_crouch_state()
	change_to_stair_state(is_on_stairs_check, is_on_stairs_check_after_frame)
	change_to_attack_state()
	change_to_special_attack_state()
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	change_to_fell_state(just_landed, y_velocity_before_collision)
	start_falling_duration_timer()
	reset_timer(just_landed)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	maintain_x_velocity_after_collision(x_velocity_before_collision) 
	maintain_y_velocity_after_collision(y_velocity_before_collision, is_on_stairs_check)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func fell_state():
	standing_hurtbox.get_node("CollisionShape2D").disabled = true
	crouched_hurtbox.get_node("CollisionShape2D").disabled = false
	animation_player.stop()               #To ensure if player is attacking while falling on the ground from a high distance (changing to the fell state), the animation player does not overide the fall state, otherwise the last frame of the animation will tell the state to go back to move state.
	animated_sprite_2d.position.x = 0     #To ensure the position change in the attack state is overiden (the sprite does not teleport)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	velocity.x = 0
	animated_sprite_2d.play("Jump")       #Jump animation doubles as the fell animation
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	if stagger_on_floor_timer.time_left == 0:
		falling_duration_timer_started = false
		if Input.is_action_pressed("Down"):
			standing_hurtbox.get_node("CollisionShape2D").disabled = true
			crouched_hurtbox.get_node("CollisionShape2D").disabled = false
			state = CROUCH
		else:
			standing_hurtbox.get_node("CollisionShape2D").disabled = false
			crouched_hurtbox.get_node("CollisionShape2D").disabled = true
			state = MOVE

func crouch_state(input_axis):
	animated_sprite_2d.position.x = 0           #To shift sprite back into place
	animated_sprite_2d.position.y = -16
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	animated_sprite_2d.play("Crouch")
	handle_flip_h(input_axis)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	handle_crouch_mechanics()
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	change_to_attack_state()
	change_to_special_attack_state()

func stair_state(input_axis, is_on_stairs_check):
	if not is_on_floor():                  #TO FIX BUG WHERE SOMETIMES GAME THINKS PLATFORM IS A STAIR AND MAKES VELOCITY SUPER HIGH, CAUSING THE PLAYER TO STAGGER ON FLOOR WHEN NOT NEEDED
		state = MOVE
		falling_duration_timer_started = false
	else:
		velocity.y = 0
		previous_facing_direction_has_been_set = false
		animated_sprite_2d.position.x = 0
		animated_sprite_2d.position.y = -16        
		#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		velocity.x = speed * 0.7 * input_axis       #To ensure player is slower on stairs                            
		#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		handle_flip_h(input_axis)
		handle_stair_animations_before_move_and_slide()
		#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		var y_global_position_before_fame = player.global_position.y
		move_and_slide()
		var y_global_position_after_fame = player.global_position.y
		#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		handle_stair_animations_after_move_and_slide(y_global_position_before_fame, y_global_position_after_fame, is_on_stairs_check)
		#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		change_to_attack_state()
		change_to_special_attack_state()
		if is_on_stairs_check.y == -1:               #Changes to the move state
			state = MOVE

func attack_state(delta, is_on_stairs_check):
	apply_gravity(delta)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	if is_on_floor():
		velocity.x = 0
		velocity.y = 0
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	handle_whip_hitbox_rotation()
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	handle_attack_animations(is_on_stairs_check)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	var y_velocity_before_collision = velocity.y
	var x_velocity_before_collision = velocity.x
	var was_in_air = not is_on_floor()    
	move_and_slide()
	var just_landed = was_in_air and is_on_floor()
	maintain_x_velocity_after_collision(x_velocity_before_collision) 
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	change_to_fell_state(just_landed, y_velocity_before_collision)
	start_falling_duration_timer()
	reset_timer(just_landed)

func hurt_standing_state(delta):
	play_hurt_blinking_effect()
	animated_sprite_2d.position.y = -16
	animated_sprite_2d.position.x = 0
	disable_hurtboxes()
	apply_gravity(delta)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	animated_sprite_2d.play("Hurt (Standing)")
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	var was_in_air = not is_on_floor()    
	move_and_slide()
	var just_landed = was_in_air and is_on_floor()
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	start_hurt_timer(just_landed)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	if is_on_floor():
		animated_sprite_2d.play("Crouch")
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	change_out_of_hurt_state()

func hurt_crouched_state(delta):
	play_hurt_blinking_effect()
	animated_sprite_2d.position.y = -16
	animated_sprite_2d.position.x = 0
	disable_hurtboxes()
	apply_gravity(delta)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	animated_sprite_2d.play("Hurt (Crouched)")
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	var was_in_air = not is_on_floor()    
	move_and_slide()
	var just_landed = was_in_air and is_on_floor()
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	start_hurt_timer(just_landed)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	if is_on_floor():
		animated_sprite_2d.play("Crouch")
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	change_out_of_hurt_state()

func hurt_stairs_state():
	play_hurt_blinking_effect()
	animated_sprite_2d.position.y = -16
	animated_sprite_2d.position.x = 0
	disable_hurtboxes()
	handle_hurt_stairs_animations()
	if hurt_timer_on_stairs.time_left == 0:
		falling_duration_timer.stop()
		if PlayerData.health <= 0:
			state = DEAD
		else:
			was_in_hurt_state = true
			state = STAIRS

func fireball_state(delta, is_on_stairs_check):
	apply_gravity(delta)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	if is_on_floor():
		velocity.x = 0
		velocity.y = 0
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	handle_fireball_animations(is_on_stairs_check)
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	var x_velocity_before_collision = velocity.x   
	move_and_slide()
	maintain_x_velocity_after_collision(x_velocity_before_collision) 
	#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func dead_state():
	SoundPlayer.stop_bg_stage_music()
	SoundPlayer.stop_boss_music()
	stop_hurt_blinking_effect()
	animated_sprite_2d.play("Dead")
	animated_sprite_2d.position.y = -7
	if not dead_timer_started:
		SoundPlayer.play_death_sound()
		dead_timer.start()
		dead_timer_started = true
	if dead_timer.time_left == 0:
		PlayerData.player_lives -= 1
		if PlayerData.player_lives >= 1:
			get_tree().change_scene_to_file("res://Source/UI and Screens/retry_screen.tscn")
		else:
			get_tree().change_scene_to_file("res://Source/UI and Screens/game_over_screen.tscn")
		queue_free()

#|||||||||||||||||||||||||CHANGE STATE FUNCTIONS||||||||||||||||||||||||||||||||||||||||||||||||||||||

func change_to_fell_state(just_landed, y_velocity_before_collision):
	if just_landed and falling_duration_timer.time_left == 0 and y_velocity_before_collision > minimum_y_velocity - 50:
		stagger_on_floor_timer.start()
		state = FELL

func change_to_crouch_state():
	if Input.is_action_pressed("Down") and is_on_floor():
		state = CROUCH

func change_to_stair_state(is_on_stairs_check, is_on_stairs_check_after_frame):
	if is_on_stairs_check.y != -1 and is_on_stairs_check.y != 0 and is_on_stairs_check_after_frame.y != -1 and is_on_stairs_check_after_frame.y != 0 and is_on_floor():
		state = STAIRS

func change_to_attack_state():
	if Input.is_action_just_pressed("Attack"):
		state = ATTACK

func change_to_hurt_state_standing(is_on_stairs_check):
	if is_on_stairs_check.y != -1 and is_on_stairs_check.y != 0:
		velocity.x = 0
		velocity.y = 0
		hurt_timer_on_stairs.start()
		state = HURT_STAIRS
	else:
		if animated_sprite_2d.flip_h == false:
			velocity.x = -85
			velocity.y = -160
		else:
			velocity.x = 85
			velocity.y = -160
		state = HURT_STANDING

func change_to_hurt_state_crouched():
	if animated_sprite_2d.flip_h == false:
		velocity.x = -65
		velocity.y = -125
	else:
		velocity.x = 65
		velocity.y = -125
	state = HURT_CROUCHED

func change_to_special_attack_state():
	if PlayerData.essence_value > 0:
		if Input.is_action_pressed("Up") and Input.is_action_just_pressed("Attack") and PlayerData.ability_active == true:
			PlayerData.essence_value -= 1
			state = FIREBALL

func change_out_of_hurt_state():
	falling_duration_timer.stop()
	falling_duration_timer_started = false
	if hurt_timer.time_left == 0 and hurt_timer_started:
		falling_duration_timer.stop()
		was_in_hurt_state = true
		if PlayerData.health <= 0:
			state = DEAD
		elif Input.is_action_just_pressed("Down"):
			hurt_timer_started = false
			state = CROUCH
		else:
			hurt_timer_started = false
			state = MOVE

#|||||||||||||||||||||||||HURTBOX|||||||||||||||||||||||||||||||||||||||||||||||||||||

func _on_standing_hurtbox_area_entered(area):
	SoundPlayer.play_player_hurt_sound()
	var is_on_stairs_check = get_floor_normal()
	PlayerData.health -= area.damage
	create_hit_effect()
	change_to_hurt_state_standing(is_on_stairs_check)

func _on_crouched_hurtbox_area_entered(area):
	SoundPlayer.play_player_hurt_sound()
	PlayerData.health -= area.damage
	create_hit_effect()
	change_to_hurt_state_crouched()

func _on_death_zone_detector_area_entered(_area):
	PlayerData.health = 0
	state = DEAD

func _on_disable_movement_area_area_entered(_area):
	if not movement_disabled_animations_will_pause:
		SoundPlayer.play_player_hurt_sound()
	if state != MOVE and not movement_disabled_animations_will_pause:
		animated_sprite_2d.position.x = 0
	PlayerData.player_movement_disabled = true

func _on_disable_movement_area_area_exited(_area):
	call_deferred("trigger_player_hurtbox_after_disabled")
	movement_disabled_animations_will_pause = true
	PlayerData.player_movement_disabled = false

#|||||||||||||||||||||||||SUPPORTING FUNCTIONS||||||||||||||||||||||||||||||||||||||||||||||||||||||||

#ATTACK FUNCTIONS

func handle_whip_hitbox_rotation():
	if animated_sprite_2d.flip_h == true:
		attack_hitbox_pivot.rotation_degrees = 180
	else:
		attack_hitbox_pivot.rotation = 0

func handle_attack_animations(is_on_stairs_check):
	if not animation_player.is_playing() and not whip_animation_playing and Input.is_action_pressed("Down") and is_on_floor() and is_on_stairs_check.y == -1:
		whip_animation_playing = true
		animated_sprite_2d.position.y = -8
		if animated_sprite_2d.flip_h == true:
			animated_sprite_2d.position.x = -12
		elif animated_sprite_2d.flip_h == false:
			animated_sprite_2d.position.x = 12
		animation_player.play("Attack (Crouched)")
	elif is_on_stairs_check.y != -1 and is_on_stairs_check.y != 0 and not animation_player.is_playing() and not whip_animation_playing:
		if animated_sprite_2d.animation == "Stairs DOWN":
			if animated_sprite_2d.flip_h == true:
				animated_sprite_2d.position.x = -12
				animated_sprite_2d.position.y = -14
				animation_player.play("Attack (Stairs DOWN)")
			else:
				animated_sprite_2d.position.x = 10 
				animated_sprite_2d.position.y = -14
				animation_player.play("Attack (Stairs DOWN)")
		elif animated_sprite_2d.animation == "Stairs UP":
			if animated_sprite_2d.flip_h == true:
				animated_sprite_2d.position.x = -10  
				animated_sprite_2d.position.y = -14
				animation_player.play("Attack (Stairs UP)")
			else:
				animated_sprite_2d.position.x = 10
				animated_sprite_2d.position.y = -14
				animation_player.play("Attack (Stairs UP)")
	elif not animation_player.is_playing() and not whip_animation_playing:
		if animated_sprite_2d.flip_h == true:
			animated_sprite_2d.position.x = -10
		elif animated_sprite_2d.flip_h == false:
			animated_sprite_2d.position.x = 10
		animation_player.play("Attack (Standing)")

func standing_attack_animation_finished():
	whip_animation_playing = false
	var is_on_stairs_check = get_floor_normal() 
	if state == HURT_STANDING:
		state = HURT_STANDING
	elif is_on_stairs_check.y != -1 and is_on_stairs_check.y != 0:
		state = STAIRS
	else:
		state = MOVE

func crouched_attack_animation_finished():
	whip_animation_playing = false
	if state == HURT_CROUCHED:
		state = HURT_CROUCHED
	else:
		state = CROUCH

func stair_attack_animation_finished():
	whip_animation_playing = false
	if state == HURT_STAIRS:
		state = HURT_STAIRS
	else:
		state = STAIRS

#FIREBALL FUNCTIONS

func handle_fireball_animations(is_on_stairs_check):
	if not animation_player.is_playing() and not fireball_animation_playing and Input.is_action_pressed("Down") and is_on_floor():
		fireball_animation_playing = true
		animated_sprite_2d.position.y = -8
		if animated_sprite_2d.flip_h == true:
			animated_sprite_2d.position.x = -12
		elif animated_sprite_2d.flip_h == false:
			animated_sprite_2d.position.x = 12
		animation_player.play("Fireball (Crouched)")
	
	elif is_on_stairs_check.y != -1 and is_on_stairs_check.y != 0 and not animation_player.is_playing() and not fireball_animation_playing:
		fireball_animation_playing = true
		if animated_sprite_2d.animation == "Stairs DOWN":
			if animated_sprite_2d.flip_h == true:
				animated_sprite_2d.position.x = -11
				animated_sprite_2d.position.y = -14
				animation_player.play("Fireball (Stairs DOWN)")
			else:
				animated_sprite_2d.position.x = 11 
				animated_sprite_2d.position.y = -14
				animation_player.play("Fireball (Stairs DOWN)")
		elif animated_sprite_2d.animation == "Stairs UP":
			if animated_sprite_2d.flip_h == true:
				animated_sprite_2d.position.x = -11 
				animated_sprite_2d.position.y = -14
				animation_player.play("Fireball (Stairs UP)")
			else:
				animated_sprite_2d.position.x = 11
				animated_sprite_2d.position.y = -14
				animation_player.play("Fireball (Stairs UP)")
	
	elif not animation_player.is_playing() and not fireball_animation_playing:
		fireball_animation_playing = true
		if animated_sprite_2d.flip_h == true:
			animated_sprite_2d.position.x = -10
		elif animated_sprite_2d.flip_h == false:
			animated_sprite_2d.position.x = 10
		animation_player.play("Fireball (Standing)")

func shoot_fireball_standing():
	if not fireball_has_been_shot:
		fireball_has_been_shot = true
		var fireball = load("res://Source/Actors/Player/Abilities/fireball.tscn")
		var fireball_instance = fireball.instantiate()
		var world = get_tree().current_scene
		world.add_child(fireball_instance)
		if animated_sprite_2d.flip_h == true:
			fireball_instance.global_position.x = player.global_position.x - 14
			fireball_instance.global_position.y = player.global_position.y - 16
		else:
			fireball_instance.global_position.x = player.global_position.x + 14
			fireball_instance.global_position.y = player.global_position.y - 16

func shoot_fireball_crouched():
	if not fireball_has_been_shot:
		fireball_has_been_shot = true
		var fireball = load("res://Source/Actors/Player/Abilities/fireball.tscn")
		var fireball_instance = fireball.instantiate()
		var world = get_tree().current_scene
		world.add_child(fireball_instance)
		if animated_sprite_2d.flip_h == true:
			fireball_instance.global_position.x = player.global_position.x - 13
			fireball_instance.global_position.y = player.global_position.y - 8
		else:
			fireball_instance.global_position.x = player.global_position.x + 13
			fireball_instance.global_position.y = player.global_position.y - 8

func shoot_fireball_stairs_up():
	if not fireball_has_been_shot:
		fireball_has_been_shot = true
		var fireball = load("res://Source/Actors/Player/Abilities/fireball.tscn")
		var fireball_instance = fireball.instantiate()
		var world = get_tree().current_scene
		world.add_child(fireball_instance)
		if animated_sprite_2d.flip_h == true:
			fireball_instance.global_position.x = player.global_position.x - 11
			fireball_instance.global_position.y = player.global_position.y - 14
		else:
			fireball_instance.global_position.x = player.global_position.x + 11
			fireball_instance.global_position.y = player.global_position.y - 14

func shoot_fireball_stairs_down():
	if not fireball_has_been_shot:
		fireball_has_been_shot = true
		var fireball = load("res://Source/Actors/Player/Abilities/fireball.tscn")
		var fireball_instance = fireball.instantiate()
		var world = get_tree().current_scene
		world.add_child(fireball_instance)
		if animated_sprite_2d.flip_h == true:
			fireball_instance.global_position.x = player.global_position.x - 11
			fireball_instance.global_position.y = player.global_position.y - 14
		else:
			fireball_instance.global_position.x = player.global_position.x + 11
			fireball_instance.global_position.y = player.global_position.y - 14

func create_fireball_cast_effect_standing():
	var fireball_effect = load("res://Source/Actors/Player/Abilities/fireball_hit_effect.tscn")
	var fireball_effect_instance = fireball_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(fireball_effect_instance)
	if animated_sprite_2d.flip_h == true:
		fireball_effect_instance.get_node("AnimatedSprite2D").flip_h = true
		fireball_effect_instance.global_position.x = player.global_position.x - 14
		fireball_effect_instance.global_position.y = player.global_position.y - 16
	else:
		fireball_effect_instance.get_node("AnimatedSprite2D").flip_h = false
		fireball_effect_instance.global_position.x = player.global_position.x + 14
		fireball_effect_instance.global_position.y = player.global_position.y - 16

func create_fireball_cast_effect_crouched():
	var fireball_effect = load("res://Source/Actors/Player/Abilities/fireball_hit_effect.tscn")
	var fireball_effect_instance = fireball_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(fireball_effect_instance)
	if animated_sprite_2d.flip_h == true:
		fireball_effect_instance.get_node("AnimatedSprite2D").flip_h = true
		fireball_effect_instance.global_position.x = player.global_position.x - 13
		fireball_effect_instance.global_position.y = player.global_position.y - 8
	else:
		fireball_effect_instance.get_node("AnimatedSprite2D").flip_h = false
		fireball_effect_instance.global_position.x = player.global_position.x + 13
		fireball_effect_instance.global_position.y = player.global_position.y - 8

func create_fireball_cast_effect_stairs_up():
	var fireball_effect = load("res://Source/Actors/Player/Abilities/fireball_hit_effect.tscn")
	var fireball_effect_instance = fireball_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(fireball_effect_instance)
	if animated_sprite_2d.flip_h == true:
		fireball_effect_instance.get_node("AnimatedSprite2D").flip_h = true
		fireball_effect_instance.global_position.x = player.global_position.x - 11
		fireball_effect_instance.global_position.y = player.global_position.y - 14
	else:
		fireball_effect_instance.get_node("AnimatedSprite2D").flip_h = false
		fireball_effect_instance.global_position.x = player.global_position.x + 11
		fireball_effect_instance.global_position.y = player.global_position.y - 14

func create_fireball_cast_effect_stairs_down():
	var fireball_effect = load("res://Source/Actors/Player/Abilities/fireball_hit_effect.tscn")
	var fireball_effect_instance = fireball_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(fireball_effect_instance)
	if animated_sprite_2d.flip_h == true:
		fireball_effect_instance.get_node("AnimatedSprite2D").flip_h = true
		fireball_effect_instance.global_position.x = player.global_position.x - 11
		fireball_effect_instance.global_position.y = player.global_position.y - 14
	else:
		fireball_effect_instance.get_node("AnimatedSprite2D").flip_h = false
		fireball_effect_instance.global_position.x = player.global_position.x + 11
		fireball_effect_instance.global_position.y = player.global_position.y - 14

func standing_fireball_animation_finished():
	fireball_animation_playing = false
	fireball_has_been_shot = false
	var is_on_stairs_check = get_floor_normal() 
	if state == HURT_STANDING:
		state = HURT_STANDING
	elif is_on_stairs_check.y != -1 and is_on_stairs_check.y != 0:
		state = STAIRS
	else:
		state = MOVE

func crouched_fireball_animation_finished():
	fireball_has_been_shot = false
	fireball_animation_playing = false
	if state == HURT_CROUCHED:
		state = HURT_CROUCHED
	else:
		state = CROUCH

func stair_fireball_animation_finished():
	fireball_has_been_shot = false
	fireball_animation_playing = false
	if state == HURT_STAIRS:
		state = HURT_STAIRS
	else:
		state = STAIRS

#OTHER FUNCTIONS

func connect_camera(camera):
	var camera_path = camera.get_path()
	remote_transform_2d.remote_path = camera_path

func apply_gravity(delta):
	velocity.y = move_toward(velocity.y, minimum_y_velocity, gravity * delta)

func handle_movement(input_axis, is_on_stairs_check):
	if is_on_floor():
		velocity.x = speed * input_axis
		if is_on_stairs_check.y == -1:
			velocity.y = minimum_y_velocity
		if Input.is_action_just_pressed("Jump"):
			velocity.y = jump_velocity
			velocity.x = speed * input_axis
	else:
		if velocity.y == minimum_y_velocity and not Input.is_action_just_released("Jump"):
			velocity.x = 0

func handle_move_state_animations(input_axis):
	if Input.is_action_pressed("Down") and is_on_floor():      #To ensure that when leaving hurt crouched state, animation does not glitch out
		animated_sprite_2d.play("Crouch")
	elif velocity.x != 0 and is_on_floor():
		animated_sprite_2d.play("Walk")
		animated_sprite_2d.flip_h = input_axis < 0
	elif not is_on_floor() and velocity.y < 25:
		animated_sprite_2d.play("Jump")
	elif not is_on_floor() and velocity.y > 25:
		animated_sprite_2d.play("Idle")
	else:
		animated_sprite_2d.play("Idle")

func start_falling_duration_timer():
	if not is_on_floor() and not falling_duration_timer_started:
		falling_duration_timer.start()
		falling_duration_timer_started = true

func reset_timer(just_landed):
	if just_landed:
		falling_duration_timer.stop()
		falling_duration_timer_started = false

func maintain_x_velocity_after_collision(x_velocity_before_collision):
#	if not is_on_floor():
	velocity.x = x_velocity_before_collision

func maintain_y_velocity_after_collision(y_velocity_before_collision, is_on_stairs_check):
	if is_on_stairs_check.y != -1 and is_on_stairs_check.y != 0:
		state = STAIRS
	elif is_on_stairs_check.y == -1:
		velocity.y = y_velocity_before_collision

func handle_flip_h(input_axis):
	if input_axis > 0:
		animated_sprite_2d.flip_h = false
	elif input_axis < 0:
		animated_sprite_2d.flip_h = true

func handle_crouch_mechanics():
	if Input.is_action_pressed("Down") and not i_frames_timer_started:
		standing_hurtbox.get_node("CollisionShape2D").disabled = true
		crouched_hurtbox.get_node("CollisionShape2D").disabled = false
		velocity.x = 0
		velocity.y = 0
	elif not i_frames_timer_started:
		standing_hurtbox.get_node("CollisionShape2D").disabled = false
		crouched_hurtbox.get_node("CollisionShape2D").disabled = true
		state = MOVE

func handle_stair_animations_before_move_and_slide():
	if previous_facing_direction != "":
		if previous_facing_direction == "stairs_up_right":
			animated_sprite_2d.play("Stairs UP")
		elif previous_facing_direction == "stairs_down_left":
			animated_sprite_2d.play("Stairs DOWN")
		elif previous_facing_direction == "stairs_up_left":
			animated_sprite_2d.play("Stairs UP")
		elif previous_facing_direction == "stairs_down_right":
			animated_sprite_2d.play("Stairs DOWN")
	else:
		animated_sprite_2d.play("Stairs UP")

func handle_stair_animations_after_move_and_slide(y_global_position_before_fame, y_global_position_after_fame, is_on_stairs_check):
	if is_on_stairs_check.y != -1 and is_on_stairs_check.y != 0:
		if y_global_position_before_fame > y_global_position_after_fame and Input.is_action_pressed("Right"):
			animated_sprite_2d.play("Stairs UP")
			previous_facing_direction = "stairs_up_right"
		if y_global_position_before_fame > y_global_position_after_fame and Input.is_action_pressed("Left") and not previous_facing_direction == "stairs_down_left":
			animated_sprite_2d.play("Stairs UP")
			previous_facing_direction = "stairs_up_left"
		if y_global_position_before_fame < y_global_position_after_fame and Input.is_action_pressed("Left") and not previous_facing_direction == "stairs_up_left":
			animated_sprite_2d.play("Stairs DOWN")
			previous_facing_direction = "stairs_down_left"
		if y_global_position_before_fame < y_global_position_after_fame and Input.is_action_pressed("Right"):
			animated_sprite_2d.play("Stairs DOWN")
			previous_facing_direction = "stairs_down_right"
		if y_global_position_before_fame == y_global_position_after_fame:
			animated_sprite_2d.pause()

func start_hurt_timer(just_landed):
	if is_on_floor() and not hurt_timer_started and just_landed:
		velocity.x = 0
		velocity.y = 0
		hurt_timer_started = true
		hurt_timer.start()

func disable_hurtboxes():
	standing_hurtbox.get_node("CollisionShape2D").disabled = true
	crouched_hurtbox.get_node("CollisionShape2D").disabled = true

func store_stair_direction_prediction():
	if previous_facing_direction == "stairs_up_right" and not previous_facing_direction_has_been_set:
		previous_facing_direction = "stairs_down_right"
		previous_facing_direction_has_been_set = true
	if previous_facing_direction == "stairs_down_left" and not previous_facing_direction_has_been_set:
		previous_facing_direction = "stairs_up_right"
		previous_facing_direction_has_been_set = true
	if previous_facing_direction == "stairs_up_left" and not previous_facing_direction_has_been_set:
		previous_facing_direction = "stairs_down_left"
		previous_facing_direction_has_been_set = true
	if previous_facing_direction == "stairs_down_right" and not previous_facing_direction_has_been_set:
		previous_facing_direction = "stairs_up_left"
		previous_facing_direction_has_been_set = true

func create_hit_effect():
	var hit_effect = load("res://Source/Actors/Enemies/Effects/hit_effect.tscn")
	var hit_effect_instance = hit_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(hit_effect_instance)
	if animated_sprite_2d.flip_h == false:
		hit_effect_instance.global_position.x = player.global_position.x + 5
		hit_effect_instance.global_position.y = player.global_position.y - 30
	else:
		hit_effect_instance.global_position.x = player.global_position.x - 5
		hit_effect_instance.global_position.y = player.global_position.y - 30

func handle_hurt_stairs_animations():
	if previous_facing_direction == "stairs_up_left" or previous_facing_direction == "stairs_up_right":
		animated_sprite_2d.play("Stairs UP (Hurt)")
	else:
		animated_sprite_2d.play("Stairs DOWN (HURT)")

func play_hurt_blinking_effect():
	effects_player.play("HurtBlinkingEffect")

func stop_hurt_blinking_effect():
	effects_player.play("RESET")

func handle_i_frames(is_on_stairs_check):
	if state != DEAD:
		if was_in_hurt_state:
			if not i_frames_timer_started:
				i_frames_timer.start()
				i_frames_timer_started = true
		if i_frames_timer.time_left == 0 and i_frames_timer_started:
			stop_hurt_blinking_effect()
			if is_on_stairs_check.y != -1 and is_on_stairs_check.y != 0:
				standing_hurtbox.get_node("CollisionShape2D").disabled = false
				crouched_hurtbox.get_node("CollisionShape2D").disabled = true
			elif Input.is_action_just_pressed("Down"):
				standing_hurtbox.get_node("CollisionShape2D").disabled = true
				crouched_hurtbox.get_node("CollisionShape2D").disabled = false
			else:
				standing_hurtbox.get_node("CollisionShape2D").disabled = false
				crouched_hurtbox.get_node("CollisionShape2D").disabled = true
			i_frames_timer_started = false
			was_in_hurt_state = false
	if not i_frames_timer_started:
		if not is_on_floor():
			if velocity.y < 0:
				if state == MOVE:
					standing_hurtbox.get_node("CollisionShape2D").disabled = true
					crouched_hurtbox.get_node("CollisionShape2D").disabled = false
				elif state == ATTACK or state == FIREBALL:
					standing_hurtbox.get_node("CollisionShape2D").disabled = false
					crouched_hurtbox.get_node("CollisionShape2D").disabled = true
			else:
				standing_hurtbox.get_node("CollisionShape2D").disabled = false
				crouched_hurtbox.get_node("CollisionShape2D").disabled = true

func disable_player_movement():
	velocity.x = 0
	velocity.y = 0
	if movement_disabled_animations_will_pause:
		animated_sprite_2d.pause()
		animation_player.pause()
		effects_player.pause()
	else:
		animated_sprite_2d.play("Crouch")
	standing_hurtbox.get_node("CollisionShape2D").disabled = true
	crouched_hurtbox.get_node("CollisionShape2D").disabled = true

func trigger_player_hurtbox_after_disabled():
	standing_hurtbox.get_node("CollisionShape2D").disabled = false
	crouched_hurtbox.get_node("CollisionShape2D").disabled = true

func _on_block_detector_area_entered(_area):
	SoundPlayer.play_block_destroyed_sound()

func play_whip_sound_effect():
	if state == ATTACK:
		SoundPlayer.play_whip_sound()

func play_fireball_sound_effect():
	if state == FIREBALL:
		SoundPlayer.play_fireball_cast_sound()
