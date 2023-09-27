extends CharacterBody2D

enum {SLEEPING, IDLE, CHOOSE, CHASE, SIDETOSIDE, PROJECTILES, SPAWNADDS, CHANGEFROMCHASE, CHANGEFROMSIDE, CHANGEFROMSUMMON, DEATH}

@onready var garglius = $"."
@onready var sleeping_timer = $Timers/SleepingTimer
@onready var player_detection_zone = $PlayerDetectionZone
@onready var idle_timer = $Timers/IdleTimer
@onready var chase_timer = $Timers/ChaseTimer
@onready var awake_detection_zone = $AwakeDetectionZone
@onready var projectiles_timer = $Timers/ProjectilesTimer
@onready var projectiles_windup_timer = $Timers/ProjectilesWindupTimer
@onready var change_out_of_adds_state_timer = $Timers/ChangeOutOfAddsStateTimer
@onready var stats = $Stats
@onready var mist_effect_timer = $Timers/MistEffectTimer
@onready var animated_body = $AnimatedBody
@onready var animated_wings = $AnimatedWings
@onready var animated_effects = $AnimatedEffects
@onready var chase_wait_timer = $Timers/ChaseWaitTimer
@onready var side_to_side_wait_timer = $Timers/SideToSideWaitTimer
@onready var animation_player = $AnimationPlayer
@onready var hurtbox = $Hurtbox
@onready var disable_player_movement_area = $DisablePlayerMovementArea
@onready var hitbox = $Hitbox
@onready var slime_mist_effect_timer = $Timers/SlimeMistEffectTimer

@export var speed = 100

var state = SLEEPING
var starting_position = Vector2.ZERO
var sleeping_timer_started = false
var idle_timer_started = false
var chase_timer_started = false
var on_starting_position = false
var rng = RandomNumberGenerator.new()
var previously_chosen_attack_num = null
var halfway_slime_spawned = false
var slime_mist_effect_timer_started = false
#CHASE VARIABLES
var player_position_received = false
var on_player_position = false
var times_chased = 0
var player_position = Vector2.ZERO
var chase_wait_timer_started = false
#SIDE TO SIDE VARIABLES
var arena_pos_SE = Vector2.ZERO
var arena_pos_SW = Vector2.ZERO
var arena_pos_E = Vector2.ZERO
var arena_pos_W = Vector2.ZERO
var arena_pos_NE = Vector2.ZERO
var arena_pos_NW = Vector2.ZERO
var side_to_side_random_num_chosen = false
var sidetoside_random_num = 0
var first_destination_reached = false
var second_destination_reached = false
var third_destination_reached = false
var fourth_destination_reached = false
var fifth_destination_reached = false
var sixth_destination_reached = false
var side_to_side_wait_timer_started = false
#PROJECTILES VARIABLES
var projectiles_shot = false
var projectiles_timer_started = false
var projectiles_random_num = 0
var projectiles_random_num_chosen = false
var times_projectiles_thrown = 0
var projectiles_windup_timer_started = false
#SPAWN ADDS VARIABLES
var spawn_adds_random_num_chosen = false
var spawn_adds_random_num = 0
var adds_have_been_spawned = false
var penguins_times_spawned = 0
var penguin_timer_started = false
var platform_L1 = Vector2.ZERO
var platform_L2 = Vector2.ZERO
var platform_L3 = Vector2.ZERO
var platform_L4 = Vector2.ZERO
var platform_R1 = Vector2.ZERO
var platform_R2 = Vector2.ZERO
var platform_R3 = Vector2.ZERO
var platform_R4 = Vector2.ZERO
var platform_floor = Vector2.ZERO
var top_left_penguin_spawn = Vector2.ZERO
var top_right_penguin_spawn = Vector2.ZERO
var bottom_left_penguin_spawn = Vector2.ZERO
var bottom_right_penguin_spawn = Vector2.ZERO
var change_out_of_adds_state_timer_started = false
var mist_effect_timer_started = false
#HIT EFFECT VARIABLES
var hit_effect_random_num_chosen = false
var hit_effect_random_number = 0
#ANIMATION VARIABLES
var sleeping_into_wakeup_played = false
var chase_startup_played = false
var chase_effect_active_played = false
var entire_chase_startup_played = false
var sidetoside_effect_active_played = false
var sidetoside_startup_played = false
var entire_sidetoside_startup_played = false
var summon_effect_active_played = false
var summon_startup_played = false
var entire_summon_startup_played = false
var projectile_effect_first_part_played = false
var entire_projectile_effect_played = false
var fix_summon_animation = false

var laser_effect_played = false
var death_effect_played = false

func _ready():
	hurtbox.get_node("CollisionShape2D").disabled = true
	hitbox.get_node("CollisionShape2D").disabled = true
	starting_position = garglius.global_position
	#SIDE TO SIDE VARIABLE INITIALIZATIONS
	arena_pos_SE.y = starting_position.y + 128
	arena_pos_SE.x = starting_position.x + 136
	arena_pos_SW.y = starting_position.y + 128
	arena_pos_SW.x = starting_position.x - 136
	arena_pos_E.y = starting_position.y + 56
	arena_pos_E.x = starting_position.x + 136
	arena_pos_W.y = starting_position.y + 56
	arena_pos_W.x = starting_position.x - 136
	arena_pos_NE.y = starting_position.y - 16
	arena_pos_NE.x = starting_position.x + 136
	arena_pos_NW.y = starting_position.y - 16
	arena_pos_NW.x = starting_position.x - 136
	#SPAWN ADDS VARIABLE INITIALIZATIONS
	platform_L4.x = starting_position.x - 81
	platform_L4.y = starting_position.y + 8
	platform_L3.x = starting_position.x - 112
	platform_L3.y = starting_position.y + 40
	platform_L2.x = starting_position.x - 136
	platform_L2.y = starting_position.y + 72
	platform_L1.x = starting_position.x - 112
	platform_L1.y = starting_position.y + 104
	platform_R4.x = starting_position.x + 81
	platform_R4.y = starting_position.y + 8
	platform_R3.x = starting_position.x + 112
	platform_R3.y = starting_position.y + 40
	platform_R2.x = starting_position.x + 136
	platform_R2.y = starting_position.y + 72
	platform_R1.x = starting_position.x + 112
	platform_R1.y = starting_position.y + 104
	platform_floor.x = starting_position.x
	platform_floor.y = starting_position.y + 136
	top_left_penguin_spawn.x = starting_position.x - 176
	top_left_penguin_spawn.y = starting_position.y
	top_right_penguin_spawn.x = starting_position.x + 176
	top_right_penguin_spawn.y = starting_position.y
	bottom_left_penguin_spawn.x = starting_position.x - 176
	bottom_left_penguin_spawn.y = starting_position.y + 104
	bottom_right_penguin_spawn.x = starting_position.x + 176
	bottom_right_penguin_spawn.y = starting_position.y + 104
	#ANIMATIONS
	animated_body.play("SleepingBody")
	animated_effects.play("Nothing")
	animated_wings.play("Nothing")

func _physics_process(delta):
	summon_halfway_slime()
	match state:
		SLEEPING:
			sleeping_state()
		IDLE:
			idle_state(delta)
		CHOOSE:
			choose_state()
		CHASE:
			chase_state(delta)
		SIDETOSIDE:
			side_to_side_state(delta)
		PROJECTILES:
			projectiles_state()
		SPAWNADDS:
			spawn_adds_state()
		CHANGEFROMCHASE:
			change_from_chase_state()
		CHANGEFROMSIDE:
			change_from_sidetoside_state()
		DEATH:
			death_state(delta)

#|||||||||||||||||||||||||THE DIFFERENT STATES||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func sleeping_state():
	if awake_detection_zone.can_see_player() and not sleeping_timer_started:
		sleeping_timer.start()
		sleeping_timer_started = true
	if sleeping_timer.time_left == 0 and sleeping_timer_started:
		if not laser_effect_played:
			SoundPlayer.play_garglius_laser_sound()
			laser_effect_played = true
		if not sleeping_into_wakeup_played:
			animated_effects.play("WakeUpEffect")
			await animated_effects.animation_finished
			animated_effects.play("Nothing")
			animated_body.play("SleepingIntoWakeup")
			animation_player.play("WingSound")
			sleeping_into_wakeup_played = true
			await animated_body.animation_finished
			animated_body.play("WakeUpBody")
			animated_wings.play("WakeUpWings")
			await animated_body.animation_finished
			hurtbox.get_node("CollisionShape2D").disabled = false
			hitbox.get_node("CollisionShape2D").disabled = false
			disable_player_movement_area.get_node("CollisionShape2D").disabled = true
			SoundPlayer.play_boss_music()
			state = IDLE

func idle_state(delta):
	projectiles_windup_timer_started = false
	entire_projectile_effect_played = false
	projectile_effect_first_part_played = false
	animated_body.position.y = -9
	animated_effects.position.y = -9
	animated_wings.position.y = -9
	animated_effects.play("Nothing")
	animated_body.play("IdleBody")
	animated_wings.play("IdleWings")
	garglius.global_position = garglius.global_position.move_toward(starting_position, speed * delta)
	if garglius.global_position == starting_position:
		on_starting_position = true
	if on_starting_position and not idle_timer_started:
		idle_timer.start()
		idle_timer_started = true
	if idle_timer.time_left == 0 and idle_timer_started:
		on_starting_position = false
		idle_timer_started = false
		state = CHOOSE

func choose_state():
	var random = rng.randi_range(0,3)
	if previously_chosen_attack_num != null:
		if random == previously_chosen_attack_num:
			if random == 3:
				random = 0
			else:
				random += 1
	previously_chosen_attack_num = random
	choose_attack(random)

func chase_state(delta):
	if not entire_chase_startup_played:
		if not chase_startup_played:
			animated_body.play("ChargeBody")
			animated_wings.play("ChaseWings (StartUp)")
			animated_effects.play("ChaseEffect")
			chase_startup_played = true
		await animated_body.animation_finished
		if not chase_effect_active_played:
			animated_effects.play("ChaseEffect (Active)")
			chase_effect_active_played = true
			entire_chase_startup_played = true
	animated_wings.play("Nothing")
	animated_body.play("ChaseTornado")
	
	if entire_chase_startup_played:
		if not chase_wait_timer_started:
			chase_wait_timer.start()
			chase_wait_timer_started = true
		
	if chase_wait_timer.time_left == 0 and chase_wait_timer_started:
		find_player_position()
		chase_player(delta)
		check_if_done_chasing()

func side_to_side_state(delta):
	speed = 300
	if not entire_sidetoside_startup_played:
		if not sidetoside_startup_played:
			animated_body.play("ChargeBody")
			animated_wings.play("ChaseWings (StartUp)")
			animated_effects.play("ChargeEffect")
			sidetoside_startup_played = true
		await animated_body.animation_finished
		if not sidetoside_effect_active_played:
			animated_effects.play("ChargeEffect (Active)")
			sidetoside_effect_active_played = true
			entire_sidetoside_startup_played = true
	animated_wings.play("Nothing")
	animated_body.play("ChargeTornado")
	
	if entire_sidetoside_startup_played:
		if not side_to_side_wait_timer_started:
			side_to_side_wait_timer.start()
			side_to_side_wait_timer_started = true
	
	if side_to_side_wait_timer.time_left == 0 and side_to_side_wait_timer_started:
		choose_random_number_sidetoside()
		
		if sidetoside_random_num == 0:
			bottom_right_to_top_left(delta)
		elif sidetoside_random_num == 1:
			bottom_left_to_top_right(delta)
		elif sidetoside_random_num == 2:
			top_right_to_bottom_left(delta)
		else:
			top_left_to_bottom_right(delta)
		if sixth_destination_reached:
			switch_from_sidetoside_to_idle()

func projectiles_state():
	if PlayerData.garglius_health <= 0:
		animated_effects.play("Nothing")
	fix_summon_animation = true
	if not entire_projectile_effect_played:
		if not projectile_effect_first_part_played:
			animated_body.play("ProjectileBody")
			animated_effects.play("ProjectilesEffect(FIRST3)")
			projectile_effect_first_part_played = true
		await animated_effects.animation_finished
		animated_effects.play("ProjectilesEffect(LAST2)")
		await animated_body.animation_finished
		if fix_summon_animation:
			animated_body.play("ProjectileBody(LAST FRAME)")
			entire_projectile_effect_played = true

	if entire_projectile_effect_played:
		if not projectiles_windup_timer_started:
			projectiles_windup_timer.start()
			projectiles_windup_timer_started = true
		
		if projectiles_windup_timer.time_left == 0 and projectiles_windup_timer_started:
			choose_random_number_projectiles()
			start_projectile_timer()
			shoot_projectiles()
			switch_from_projectiles_to_idle()

func spawn_adds_state():
	fix_summon_animation = false
	hurtbox.get_node("CollisionShape2D").disabled = true
	animation_player.play("Transparent")
	if not entire_summon_startup_played:
		if not summon_startup_played:
			animated_body.play("SummonBody")
			animated_wings.play("IdleWings")
			animated_effects.play("SummonEffect")
			summon_startup_played = true
		await animated_effects.animation_finished
		if not summon_effect_active_played:
			animated_effects.play("SummonEffectLinger")
			summon_effect_active_played = true
			entire_summon_startup_played = true
	choose_random_number_spawn_adds()
	choose_to_be_spawned_enemies()
	start_change_out_of_adds_state_timer()
	change_out_of_spawn_adds_state()

func change_from_chase_state():
	animated_body.play("IdleBody")
	animated_effects.play("ChaseEffect (Inactive)")
	animated_wings.play("ChaseWings (Finished)")
	await animated_effects.animation_finished
	state = IDLE

func change_from_sidetoside_state():
	animated_body.play("IdleBody")
	animated_effects.play("ChargeEffect (Inactive)")
	animated_wings.play("ChaseWings (Finished)")
	await animated_effects.animation_finished
	sidetoside_effect_active_played = false
	sidetoside_startup_played = false
	entire_sidetoside_startup_played = false
	side_to_side_wait_timer_started = false
	state = IDLE

func death_state(delta):
	SoundPlayer.stop_boss_music()
	speed = 75
	animated_effects.visible = false
	hitbox.get_node("CollisionShape2D").disabled = true
	hurtbox.get_node("CollisionShape2D").disabled = true
	animated_body.position.y = -9
	animated_effects.position.y = -9
	animated_wings.position.y = -9
	if garglius.global_position != starting_position:
		animated_effects.play("Nothing")
		animated_body.play("IdleBody")
		animated_wings.play("IdleWings")
		garglius.global_position = garglius.global_position.move_toward(starting_position, speed * delta)
	else:
		if not death_effect_played:
			SoundPlayer.play_garglius_death_sound()
			death_effect_played = true
		animated_wings.play("Nothing")
		animated_body.play("Death")
		await animated_body.animation_finished
		queue_free()

#|||||||||||||||||||||||||SUPPORTING FUNCTIONS||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func switch_from_sidetoside_to_idle():
	first_destination_reached = false
	second_destination_reached = false
	third_destination_reached = false
	fourth_destination_reached = false
	fifth_destination_reached = false
	sixth_destination_reached = false
	side_to_side_random_num_chosen = false
	speed = 100
	hurtbox.get_node("CollisionShape2D").disabled = false
	state = CHANGEFROMSIDE

func bottom_right_to_top_left(delta):
	if not first_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_SE, speed * delta)
		if garglius.global_position == arena_pos_SE:
			first_destination_reached = true
	if not second_destination_reached and first_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_SW, speed * delta)
		if garglius.global_position == arena_pos_SW:
			second_destination_reached = true
	if not third_destination_reached and second_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_W, speed * delta)
		if garglius.global_position == arena_pos_W:
			third_destination_reached = true
	if not fourth_destination_reached and third_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_E, speed * delta)
		if garglius.global_position == arena_pos_E:
			fourth_destination_reached = true
	if not fifth_destination_reached and fourth_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_NE, speed * delta)
		if garglius.global_position == arena_pos_NE:
			fifth_destination_reached = true
	if not sixth_destination_reached and fifth_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_NW, speed * delta)
		if garglius.global_position == arena_pos_NW:
			sixth_destination_reached = true

func bottom_left_to_top_right(delta):
	if not first_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_SW, speed * delta)
		if garglius.global_position == arena_pos_SW:
			first_destination_reached = true
	if not second_destination_reached and first_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_SE, speed * delta)
		if garglius.global_position == arena_pos_SE:
			second_destination_reached = true
	if not third_destination_reached and second_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_E, speed * delta)
		if garglius.global_position == arena_pos_E:
			third_destination_reached = true
	if not fourth_destination_reached and third_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_W, speed * delta)
		if garglius.global_position == arena_pos_W:
			fourth_destination_reached = true
	if not fifth_destination_reached and fourth_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_NW, speed * delta)
		if garglius.global_position == arena_pos_NW:
			fifth_destination_reached = true
	if not sixth_destination_reached and fifth_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_NE, speed * delta)
		if garglius.global_position == arena_pos_NE:
			sixth_destination_reached = true

func top_right_to_bottom_left(delta):
	if not first_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_NE, speed * delta)
		if garglius.global_position == arena_pos_NE:
			first_destination_reached = true
	if not second_destination_reached and first_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_NW, speed * delta)
		if garglius.global_position == arena_pos_NW:
			second_destination_reached = true
	if not third_destination_reached and second_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_W, speed * delta)
		if garglius.global_position == arena_pos_W:
			third_destination_reached = true
	if not fourth_destination_reached and third_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_E, speed * delta)
		if garglius.global_position == arena_pos_E:
			fourth_destination_reached = true
	if not fifth_destination_reached and fourth_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_SE, speed * delta)
		if garglius.global_position == arena_pos_SE:
			fifth_destination_reached = true
	if not sixth_destination_reached and fifth_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_SW, speed * delta)
		if garglius.global_position == arena_pos_SW:
			sixth_destination_reached = true

func top_left_to_bottom_right(delta):
	if not first_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_NW, speed * delta)
		if garglius.global_position == arena_pos_NW:
			first_destination_reached = true
	if not second_destination_reached and first_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_NE, speed * delta)
		if garglius.global_position == arena_pos_NE:
			second_destination_reached = true
	if not third_destination_reached and second_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_E, speed * delta)
		if garglius.global_position == arena_pos_E:
			third_destination_reached = true
	if not fourth_destination_reached and third_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_W, speed * delta)
		if garglius.global_position == arena_pos_W:
			fourth_destination_reached = true
	if not fifth_destination_reached and fourth_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_SW, speed * delta)
		if garglius.global_position == arena_pos_SW:
			fifth_destination_reached = true
	if not sixth_destination_reached and fifth_destination_reached:
		garglius.global_position = garglius.global_position.move_toward(arena_pos_SE, speed * delta)
		if garglius.global_position == arena_pos_SE:
			sixth_destination_reached = true

func choose_random_number_sidetoside():
	if not side_to_side_random_num_chosen:
		sidetoside_random_num = rng.randi_range(0,3)
		side_to_side_random_num_chosen = true

func choose_random_number_projectiles():
	if not projectiles_random_num_chosen:
		projectiles_random_num = rng.randi_range(0,1)
		projectiles_random_num_chosen = true

func choose_random_number_spawn_adds():
	if not spawn_adds_random_num_chosen:
		spawn_adds_random_num = rng.randi_range(0,3)
		spawn_adds_random_num_chosen = true

func choose_random_number_hit_effect():
	if not hit_effect_random_num_chosen:
		hit_effect_random_number = rng.randi_range(0,3)
		hit_effect_random_num_chosen = true

func check_if_done_chasing():
	if chase_timer.time_left == 0 and chase_timer_started:
		if times_chased == 3:
			player_position_received = false
			on_player_position = false
			chase_timer_started = false
			entire_chase_startup_played = false
			chase_startup_played = false
			chase_effect_active_played = false
			chase_wait_timer_started = false
			times_chased = 0
			state = CHANGEFROMCHASE
		else:
			player_position_received = false
			on_player_position = false
			chase_timer_started = false

func find_player_position():
	if not player_position_received:
		if player_detection_zone.can_see_player():
			player_position = player_detection_zone.player.global_position
			player_position_received = true

func chase_player(delta):
	if player_position_received:
		if not on_player_position:
			garglius.global_position = garglius.global_position.move_toward(player_position, speed * delta)
			if garglius.global_position == player_position:
				on_player_position = true
				times_chased += 1
		if on_player_position and not chase_timer_started:
			chase_timer.start()
			chase_timer_started = true

func shoot_projectiles_pattern_1():
	if not projectiles_shot:
		var garglius_ball = load("res://Source/Actors/Enemies/Garglius(BOSS)/garglius_ball.tscn")
		var gargilus_ball_instance_1 = garglius_ball.instantiate()
		var gargilus_ball_instance_2 = garglius_ball.instantiate()
		var gargilus_ball_instance_3 = garglius_ball.instantiate()
		var gargilus_ball_instance_4 = garglius_ball.instantiate()
		var gargilus_ball_instance_5 = garglius_ball.instantiate()
		var gargilus_ball_instance_6 = garglius_ball.instantiate()
		var gargilus_ball_instance_7 = garglius_ball.instantiate()
		var gargilus_ball_instance_8 = garglius_ball.instantiate()
		var gargilus_ball_instance_9 = garglius_ball.instantiate()
		var world = get_tree().current_scene
		world.add_child(gargilus_ball_instance_1)
		world.add_child(gargilus_ball_instance_2)
		world.add_child(gargilus_ball_instance_3)
		world.add_child(gargilus_ball_instance_4)
		world.add_child(gargilus_ball_instance_5)
		world.add_child(gargilus_ball_instance_6)
		world.add_child(gargilus_ball_instance_7)
		world.add_child(gargilus_ball_instance_8)
		world.add_child(gargilus_ball_instance_9)
		gargilus_ball_instance_1.global_position = garglius.global_position
		gargilus_ball_instance_2.global_position = garglius.global_position
		gargilus_ball_instance_3.global_position = garglius.global_position
		gargilus_ball_instance_4.global_position = garglius.global_position
		gargilus_ball_instance_5.global_position = garglius.global_position
		gargilus_ball_instance_6.global_position = garglius.global_position
		gargilus_ball_instance_7.global_position = garglius.global_position
		gargilus_ball_instance_8.global_position = garglius.global_position
		gargilus_ball_instance_9.global_position = garglius.global_position
		gargilus_ball_instance_7.speed *= -1
		gargilus_ball_instance_1.speed /= 2
		gargilus_ball_instance_6.speed /= -2
		gargilus_ball_instance_3.speed *= 1.5
		gargilus_ball_instance_8.speed *= -1.5
		gargilus_ball_instance_4.speed *= 2
		gargilus_ball_instance_9.speed *= -2
		gargilus_ball_instance_5.speed = 0
		projectiles_shot = true

func shoot_projectiles_pattern_2():
		if not projectiles_shot:
			var garglius_ball = load("res://Source/Actors/Enemies/Garglius(BOSS)/garglius_ball.tscn")
			var gargilus_ball_instance_1 = garglius_ball.instantiate()
			var gargilus_ball_instance_2 = garglius_ball.instantiate()
			var gargilus_ball_instance_3 = garglius_ball.instantiate()
			var gargilus_ball_instance_4 = garglius_ball.instantiate()
			var gargilus_ball_instance_5 = garglius_ball.instantiate()
			var gargilus_ball_instance_6 = garglius_ball.instantiate()
			var gargilus_ball_instance_7 = garglius_ball.instantiate()
			var gargilus_ball_instance_8 = garglius_ball.instantiate()
			var world = get_tree().current_scene
			world.add_child(gargilus_ball_instance_1)
			world.add_child(gargilus_ball_instance_2)
			world.add_child(gargilus_ball_instance_3)
			world.add_child(gargilus_ball_instance_4)
			world.add_child(gargilus_ball_instance_5)
			world.add_child(gargilus_ball_instance_6)
			world.add_child(gargilus_ball_instance_7)
			world.add_child(gargilus_ball_instance_8)
			gargilus_ball_instance_1.global_position = garglius.global_position
			gargilus_ball_instance_2.global_position = garglius.global_position
			gargilus_ball_instance_3.global_position = garglius.global_position
			gargilus_ball_instance_4.global_position = garglius.global_position
			gargilus_ball_instance_5.global_position = garglius.global_position
			gargilus_ball_instance_6.global_position = garglius.global_position
			gargilus_ball_instance_7.global_position = garglius.global_position
			gargilus_ball_instance_8.global_position = garglius.global_position
			gargilus_ball_instance_1.speed *= 0.25
			gargilus_ball_instance_2.speed *= -0.25
			gargilus_ball_instance_3.speed *= 0.75
			gargilus_ball_instance_4.speed *= -0.75
			gargilus_ball_instance_5.speed *= 1.25
			gargilus_ball_instance_6.speed *= -1.25
			gargilus_ball_instance_7.speed *= 1.75
			gargilus_ball_instance_8.speed *= -1.75
			projectiles_shot = true

func start_projectile_timer():
	if not projectiles_timer_started:
		projectiles_timer.start()
		projectiles_timer_started = true

func shoot_projectiles():
	if projectiles_timer.time_left == 0 and projectiles_timer_started:
		times_projectiles_thrown += 1
		if projectiles_random_num == 0:
			shoot_projectiles_pattern_1()
		else:
			shoot_projectiles_pattern_2()
		projectiles_timer_started = false
		projectiles_random_num_chosen = false
		projectiles_shot = false

func switch_from_projectiles_to_idle():
	if times_projectiles_thrown == 5:
		times_projectiles_thrown = 0
		state = IDLE

func spawn_adds_pattern_1():
	if not adds_have_been_spawned:
		var purple_slime = load("res://Source/Actors/Enemies/PurpleSlime/purple_slime_enemy.tscn")
		var green_slime = load("res://Source/Actors/Enemies/GreenSlime/green_slime_enemy.tscn")
		var purple_slime_instance_1 = purple_slime.instantiate()
		var purple_slime_instance_2 = purple_slime.instantiate()
		var green_slime_instance_1 = green_slime.instantiate()
		var green_slime_instance_2 = green_slime.instantiate()
		var green_slime_instance_3 = green_slime.instantiate()
		var world = get_tree().current_scene
		world.add_child(purple_slime_instance_1)
		world.add_child(purple_slime_instance_2)
		world.add_child(green_slime_instance_1)
		world.add_child(green_slime_instance_2)
		world.add_child(green_slime_instance_3)
		purple_slime_instance_1.global_position = platform_L1
		purple_slime_instance_2.global_position = platform_R1
		green_slime_instance_1.global_position = platform_L4
		green_slime_instance_2.global_position = platform_R4
		green_slime_instance_3.global_position = platform_floor
		adds_have_been_spawned = true

func spawn_adds_pattern_2():
	if not adds_have_been_spawned:
		var funny_bones = load("res://Source/Actors/Enemies/FunnyBones/funny_bones.tscn")
		var funny_bones_instance_1 = funny_bones.instantiate()
		var funny_bones_instance_2 = funny_bones.instantiate()
		var funny_bones_instance_3 = funny_bones.instantiate()
		var funny_bones_instance_4 = funny_bones.instantiate()
		var world = get_tree().current_scene
		world.add_child(funny_bones_instance_1)
		world.add_child(funny_bones_instance_2)
		world.add_child(funny_bones_instance_3)
		world.add_child(funny_bones_instance_4)
		funny_bones_instance_1.global_position = platform_L1
		funny_bones_instance_2.global_position = platform_R1
		funny_bones_instance_3.global_position = platform_L4
		funny_bones_instance_4.global_position = platform_R4
		adds_have_been_spawned = true

func spawn_adds_pattern_3():
	if not adds_have_been_spawned:
		var magic_penguin_right = load("res://Source/Actors/Enemies/MagicPenguin/magic_penguin_right.tscn")
		var magic_penguin_left = load("res://Source/Actors/Enemies/MagicPenguin/magic_penguin_left.tscn")
		var purple_slime = load("res://Source/Actors/Enemies/PurpleSlime/purple_slime_enemy.tscn")
		var green_slime = load("res://Source/Actors/Enemies/GreenSlime/green_slime_enemy.tscn")
		var magic_penguin_left_instance_1 = magic_penguin_left.instantiate()
		var magic_penguin_right_instance_1 = magic_penguin_right.instantiate()
		var magic_penguin_left_instance_2 = magic_penguin_left.instantiate()
		var magic_penguin_right_instance_2 = magic_penguin_right.instantiate()
		var purple_slime_instance_1 = purple_slime.instantiate()
		var purple_slime_instance_2 = purple_slime.instantiate()
		var green_slime_instance = green_slime.instantiate()
		var world = get_tree().current_scene
		world.add_child(magic_penguin_left_instance_1)
		world.add_child(magic_penguin_left_instance_2)
		world.add_child(magic_penguin_right_instance_1)
		world.add_child(magic_penguin_right_instance_2)
		world.add_child(purple_slime_instance_1)
		world.add_child(purple_slime_instance_2)
		world.add_child(green_slime_instance)
		magic_penguin_right_instance_1.global_position = top_left_penguin_spawn
		magic_penguin_right_instance_2.global_position = bottom_left_penguin_spawn
		magic_penguin_left_instance_1.global_position = top_right_penguin_spawn
		magic_penguin_left_instance_2.global_position = bottom_right_penguin_spawn
		purple_slime_instance_1.global_position = platform_L1
		purple_slime_instance_2.global_position = platform_R1
		green_slime_instance.global_position = platform_floor
		adds_have_been_spawned = true

func spawn_adds_pattern_4():
	if not adds_have_been_spawned:
		var funny_bones = load("res://Source/Actors/Enemies/FunnyBones/funny_bones.tscn")
		var purple_slime = load("res://Source/Actors/Enemies/PurpleSlime/purple_slime_enemy.tscn")
		var funny_bones_instance_1 = funny_bones.instantiate()
		var funny_bones_instance_2 = funny_bones.instantiate()
		var purple_slime_instance_1 = purple_slime.instantiate()
		var purple_slime_instance_2 = purple_slime.instantiate()
		var world = get_tree().current_scene
		world.add_child(funny_bones_instance_1)
		world.add_child(funny_bones_instance_2)
		world.add_child(purple_slime_instance_1)
		world.add_child(purple_slime_instance_2)
		funny_bones_instance_1.global_position = platform_L4
		funny_bones_instance_2.global_position = platform_R4
		purple_slime_instance_1.global_position = platform_L2
		purple_slime_instance_2.global_position = platform_R2
		adds_have_been_spawned = true

func change_out_of_spawn_adds_state():
	if change_out_of_adds_state_timer.time_left == 0 and change_out_of_adds_state_timer_started:
		spawn_adds_random_num_chosen = false
		adds_have_been_spawned = false
		change_out_of_adds_state_timer_started = false
		mist_effect_timer_started = false
		entire_summon_startup_played = false
		summon_effect_active_played = false
		summon_startup_played = false
		animation_player.play("RESET")
		hurtbox.get_node("CollisionShape2D").disabled = false
		state = IDLE

func _on_hurtbox_area_entered(area):
	SoundPlayer.play_whip_hit_sound()
	hit_effect_random_num_chosen = false
	create_hit_effect()
	PlayerData.garglius_health -= area.damage
	stats.health -= area.damage

func create_hit_effect():
	var hit_effect = load("res://Source/Actors/Enemies/Effects/boss_hit_effect.tscn")
	var hit_effect_instance = hit_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(hit_effect_instance)
	choose_random_number_hit_effect()
	if hit_effect_random_number == 0:
		hit_effect_instance.global_position.x = garglius.global_position.x + 15
		hit_effect_instance.global_position.y = garglius.global_position.y - 15
	elif hit_effect_random_number == 1:
		hit_effect_instance.global_position.x = garglius.global_position.x + 7
		hit_effect_instance.global_position.y = garglius.global_position.y + 12
	elif hit_effect_random_number == 2:
		hit_effect_instance.global_position.x = garglius.global_position.x - 15
		hit_effect_instance.global_position.y = garglius.global_position.y - 15
	else:
		hit_effect_instance.global_position.x = garglius.global_position.x - 7
		hit_effect_instance.global_position.y = garglius.global_position.y + 12

func _on_stats_no_health():
	PlayerData.score += 5000
	state = DEATH

func spawn_mist_effect_1():
	var mist_effect = load("res://Source/Actors/Enemies/Effects/spawn_mist_effect.tscn")
	var mist_effect_instance_1 = mist_effect.instantiate()
	var mist_effect_instance_2 = mist_effect.instantiate()
	var mist_effect_instance_3 = mist_effect.instantiate()
	var mist_effect_instance_4 = mist_effect.instantiate()
	var mist_effect_instance_5 = mist_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(mist_effect_instance_1)
	world.add_child(mist_effect_instance_2)
	world.add_child(mist_effect_instance_3)
	world.add_child(mist_effect_instance_4)
	world.add_child(mist_effect_instance_5)
	mist_effect_instance_1.global_position = platform_L1
	mist_effect_instance_2.global_position = platform_R1
	mist_effect_instance_3.global_position = platform_L4
	mist_effect_instance_4.global_position = platform_R4
	mist_effect_instance_5.global_position = platform_floor

func spawn_mist_effect_2():
	var mist_effect = load("res://Source/Actors/Enemies/Effects/spawn_mist_effect.tscn")
	var mist_effect_instance_1 = mist_effect.instantiate()
	var mist_effect_instance_2 = mist_effect.instantiate()
	var mist_effect_instance_3 = mist_effect.instantiate()
	var mist_effect_instance_4 = mist_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(mist_effect_instance_1)
	world.add_child(mist_effect_instance_2)
	world.add_child(mist_effect_instance_3)
	world.add_child(mist_effect_instance_4)
	mist_effect_instance_1.global_position = platform_L1
	mist_effect_instance_2.global_position = platform_R1
	mist_effect_instance_3.global_position = platform_L4
	mist_effect_instance_4.global_position = platform_R4

func spawn_mist_effect_3():
		var mist_effect = load("res://Source/Actors/Enemies/Effects/spawn_mist_effect.tscn")
		var mist_effect_instance_1 = mist_effect.instantiate()
		var mist_effect_instance_2 = mist_effect.instantiate()
		var mist_effect_instance_3 = mist_effect.instantiate()
		var world = get_tree().current_scene
		world.add_child(mist_effect_instance_1)
		world.add_child(mist_effect_instance_2)
		world.add_child(mist_effect_instance_3)
		mist_effect_instance_1.global_position = platform_L1
		mist_effect_instance_2.global_position = platform_R1
		mist_effect_instance_3.global_position = platform_floor

func spawn_mist_effect_4():
	var mist_effect = load("res://Source/Actors/Enemies/Effects/spawn_mist_effect.tscn")
	var mist_effect_instance_1 = mist_effect.instantiate()
	var mist_effect_instance_2 = mist_effect.instantiate()
	var mist_effect_instance_3 = mist_effect.instantiate()
	var mist_effect_instance_4 = mist_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(mist_effect_instance_1)
	world.add_child(mist_effect_instance_2)
	world.add_child(mist_effect_instance_3)
	world.add_child(mist_effect_instance_4)
	mist_effect_instance_1.global_position = platform_L4
	mist_effect_instance_2.global_position = platform_R4
	mist_effect_instance_3.global_position = platform_L2
	mist_effect_instance_4.global_position = platform_R2

func spawn_mist_effect_5():
	var mist_effect = load("res://Source/Actors/Enemies/Effects/spawn_mist_effect.tscn")
	var mist_effect_instance_1 = mist_effect.instantiate()
	var world = get_tree().current_scene
	world.add_child(mist_effect_instance_1)
	mist_effect_instance_1.global_position = platform_floor

func choose_to_be_spawned_enemies():
	if spawn_adds_random_num == 0:
		if not mist_effect_timer_started:
			mist_effect_timer.start()
			mist_effect_timer_started = true
			spawn_mist_effect_1()
		if mist_effect_timer.time_left == 0 and mist_effect_timer_started:
			spawn_adds_pattern_1()
	elif spawn_adds_random_num == 1:
		if not mist_effect_timer_started:
			mist_effect_timer.start()
			mist_effect_timer_started = true
			spawn_mist_effect_2()
		if mist_effect_timer.time_left == 0 and mist_effect_timer_started:
			spawn_adds_pattern_2()
	elif spawn_adds_random_num == 2:
		if not mist_effect_timer_started:
			mist_effect_timer.start()
			mist_effect_timer_started = true
			spawn_mist_effect_3()
		if mist_effect_timer.time_left == 0 and mist_effect_timer_started:
			spawn_adds_pattern_3()
	else:
		if not mist_effect_timer_started:
			mist_effect_timer.start()
			mist_effect_timer_started = true
			spawn_mist_effect_4()
		if mist_effect_timer.time_left == 0 and mist_effect_timer_started:
			spawn_adds_pattern_4()

func start_change_out_of_adds_state_timer():
	if adds_have_been_spawned:
		if not change_out_of_adds_state_timer_started:
			change_out_of_adds_state_timer.start()
			change_out_of_adds_state_timer_started = true

func ensure_new_attack(random):
	if previously_chosen_attack_num != null:
		if random == previously_chosen_attack_num:
			if random == 3:
				random = 0
			else:
				random += 1

func choose_attack(random):
	if random == 0:
		state = CHASE
	elif random == 1:
		state = SIDETOSIDE
	elif random == 2:
		state = PROJECTILES
	else:
		state = SPAWNADDS

func summon_halfway_slime():
	if stats.health <= 25:
		if not slime_mist_effect_timer_started:
			slime_mist_effect_timer.start()
			spawn_mist_effect_5()
			slime_mist_effect_timer_started = true
		if slime_mist_effect_timer_started and slime_mist_effect_timer.time_left == 0:
			if not halfway_slime_spawned:
				var slime = load("res://Source/Actors/Enemies/ArmoredSlime/armored_slime.tscn")
				var slime_instance = slime.instantiate()
				var world = get_tree().current_scene
				world.add_child(slime_instance)
				slime_instance.global_position = platform_floor
				slime_instance.will_despawn = true
				halfway_slime_spawned = true

func play_startup_wing_sound():
	SoundPlayer.play_garglius_wing_sound()
