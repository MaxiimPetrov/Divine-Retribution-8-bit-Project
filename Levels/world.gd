extends Node2D

@onready var player = $Player
@onready var camera = $Camera
@onready var spawn_bears_timer = $Timers/SpawnBearsTimer
@onready var spawn_penguins_timer = $Timers/SpawnPenguinsTimer
@onready var spawn_slimes_timer_1 = $Timers/SpawnSlimesTimer1
@onready var spawn_slimes_timer_2 = $Timers/SpawnSlimesTimer2
@onready var spawn_slimes_timer_3 = $Timers/SpawnSlimesTimer3
@onready var spawn_orb_timer = $Timers/SpawnOrbTimer
@onready var garglius = $Garglius/Garglius

var spawn_bears_1 = false
var spawn_bears_2 = false
var spawn_penguins_1 = false
var spawn_penguins_2 = false
var spawn_penguins_3 = false
var spawn_armored_slimes = false
var spawn_bears_timer_started = false
var spawn_penguins_timer_started = false
var spawn_slimes_timer_1_started = false
var spawn_slimes_timer_2_started = false
var spawn_slimes_timer_3_started = false
var rng = RandomNumberGenerator.new()
var random_b = null
var random_bear = null
var random_penguin
var bear = null
var penguin = null
var mist_effect_spawned_1 = false
var mist_effect_spawned_2 = false
var mist_effect_spawned_3 = false
var spawn_orb_timer_started = false
var spawn_orb_position = Vector2.ZERO
var boss_orb_spawned = false

func _ready():
	SoundPlayer.play_bg_stage_music()
	player.connect_camera(camera)
	player.global_position = PlayerData.player_starting_position
	spawn_orb_position = garglius.global_position
	PlayerData.garglius_died.connect(start_orb_timer)
	get_tree().paused = false

func _physics_process(_delta):
	if spawn_bears_1:
		spawning_bears_1()
	if spawn_bears_2:
		spawning_bears_2()
	if spawn_penguins_1:
		spawning_penguins_1()
	if spawn_penguins_2:
		spawning_penguins_2()
	if spawn_penguins_3:
		spawning_penguins_3()
	if spawn_armored_slimes:
		spawn_slimes_1()
		spawn_slimes_2()
		spawn_slimes_3()
	spawn_orb()

#CAMERA CHANGE FUNCTIONS

func _on_change_camera_area_body_entered(_body):
	camera.limit_top = -704
	camera.limit_left = -384
	camera.limit_right = 320 

func _on_change_camera_area_1_body_entered(_body):
	camera.limit_top = 0
	camera.limit_left = 320
	camera.limit_right = 1808 

func _on_change_camera_area_2_body_entered(_body):
	camera.limit_top = 0
	camera.limit_left = 320
	camera.limit_right = 1808 

func _on_change_camera_area_3_body_entered(_body):
	camera.limit_top = 0
	camera.limit_left = 1808
	camera.limit_right = 3688
	PlayerData.player_starting_position = Vector2(1824, 220)

func _on_change_camera_area_4_body_entered(_body):
	camera.limit_top = 96
	camera.limit_left = 3688
	camera.limit_right = 5024
	camera.limit_bottom = 336
	PlayerData.player_starting_position = Vector2(3696, 240)

func _on_change_camera_area_5_body_entered(_body):
	camera.limit_top = 0
	camera.limit_left = 1808
	camera.limit_right = 3688
	camera.limit_bottom = 240

func _on_change_camera_area_6_body_entered(_body):
	camera.limit_top = -176
	camera.limit_left = 5024
	camera.limit_right = 5568
	camera.limit_bottom = 240

func _on_change_camera_area_7_body_entered(_body):
	camera.limit_top = 96
	camera.limit_left = 3688
	camera.limit_right = 5024
	camera.limit_bottom = 336

func _on_change_camera_area_8_body_entered(_body):
	camera.limit_top = -256
	camera.limit_left = 5568
	camera.limit_right = 6256
	camera.limit_bottom = -16
	PlayerData.player_starting_position = Vector2(5576, -152)

func _on_change_camera_area_9_body_entered(_body):
	camera.limit_top = -176
	camera.limit_left = 5024
	camera.limit_right = 5568
	camera.limit_bottom = 240

func _on_change_camera_area_10_body_entered(_body):
	camera.limit_top = -16
	camera.limit_left = 5704
	camera.limit_right = 6240
	camera.limit_bottom = 224
	PlayerData.player_starting_position = Vector2(5720, 10)

func _on_change_camera_area_11_body_entered(_body):
	camera.limit_top = -256
	camera.limit_left = 5568
	camera.limit_right = 6256
	camera.limit_bottom = -16

func _on_change_camera_area_12_body_entered(_body):
	camera.limit_top = -16
	camera.limit_left = 5704
	camera.limit_right = 6240
	camera.limit_bottom = 224

func _on_change_camera_area_13_body_entered(_body):
	camera.limit_top = -32
	camera.limit_left = 6240
	camera.limit_right = 6944
	camera.limit_bottom = 208

func _on_change_camera_area_14_body_entered(_body):
	camera.limit_top = -32
	camera.limit_left = 6240
	camera.limit_right = 6944
	camera.limit_bottom = 208

func _on_change_camera_area_15_body_entered(_body):
	camera.limit_top = -336
	camera.limit_left = 6944
	camera.limit_right = 7344
	camera.limit_bottom = 96
	PlayerData.player_starting_position = Vector2(6952, 72)

func _on_change_camera_area_16_body_entered(_body):
	camera.limit_top = -336
	camera.limit_left = 6944
	camera.limit_right = 7344
	camera.limit_bottom = 96
	PlayerData.player_starting_position = Vector2(7328, -272)

func _on_change_camera_area_17_body_entered(_body):
	camera.limit_top = -336
	camera.limit_left = 7344
	camera.limit_right = 7872
	camera.limit_bottom = 464

func _on_change_camera_area_18_body_entered(_body):
	camera.limit_top = -336
	camera.limit_left = 7344
	camera.limit_right = 7872
	camera.limit_bottom = 464
	PlayerData.player_starting_position = Vector2(7336, 424)

func _on_change_camera_area_19_body_entered(_body):
	camera.limit_top = 353
	camera.limit_left = 7024
	camera.limit_right = 7344
	camera.limit_bottom = 896

func _on_change_camera_area_20_body_entered(_body):
	camera.limit_top = 896
	camera.limit_left = 7024
	camera.limit_right = 7344
	camera.limit_bottom = 1152
	call_deferred("add_barrier_blocks_2")

func _on_change_camera_area_21_body_entered(_body):
	camera.limit_top = 896
	camera.limit_left = 7024
	camera.limit_right = 7344
	camera.limit_bottom = 1152
	spawn_armored_slimes = true

func _on_change_camera_area_22_body_entered(_body):
	camera.limit_top = 1040
	camera.limit_left = 7296
	camera.limit_right = 7728
	camera.limit_bottom = 1328

func _on_change_camera_area_23_body_entered(_body):
	camera.limit_top = 1088
	camera.limit_left = 7744
	camera.limit_right = 8064
	camera.limit_bottom = 1328
	PlayerData.player_starting_position = Vector2(7744, 1280)

func _on_change_camera_area_24_body_entered(_body):
	camera.limit_top = 1040
	camera.limit_left = 7296
	camera.limit_right = 7728
	camera.limit_bottom = 1328

func _on_change_camera_area_25_body_entered(_body):
	camera.limit_top = 1312
	camera.limit_bottom = 2224
	spawn_armored_slimes = true
	SoundPlayer.stop_bg_stage_music()

func _on_change_camera_area_26_body_entered(_body):
	camera.limit_top = 1984
	camera.limit_right = 8064

func _on_change_camera_area_27_body_entered(_body):
	camera.limit_right = 8304
	camera.limit_left = 8048

func _on_change_camera_area_28_body_entered(_body):
	camera.limit_top = 1088
	camera.limit_left = 7744
	camera.limit_right = 8064
	camera.limit_bottom = 1328

#TRIGGER BEAR AREA FUNCTIONS

func _on_trigger_bear_area_body_entered(_body):
	spawn_bears_1 = true

func _on_trigger_bear_area_body_exited(_body):
	spawn_bears_timer_started = false
	spawn_bears_1 = false

func _on_trigger_bear_area_2_body_entered(_body):
	spawn_bears_2 = true

func _on_trigger_bear_area_2_body_exited(_body):
	spawn_bears_timer_started = false
	spawn_bears_2 = false

func spawning_bears_1():
	random_bear = rng.randi_range(0,1)
	if not spawn_bears_timer_started:
		spawn_bears_timer.start()
		spawn_bears_timer_started = true
	if spawn_bears_timer_started and spawn_bears_timer.time_left == 0:
		if random_bear == 0:
			bear = load("res://Source/Actors/Enemies/Bear/running_bear_enemy.tscn")
		else:
			bear = load("res://Source/Actors/Enemies/ArmoredBear/armored_bear_enemy.tscn")
		random_b = rng.randi_range(0,1)
		var bear_instance = bear.instantiate()
		var world = get_tree().current_scene
		world.add_child(bear_instance)
		bear_instance.global_position.y = 176
		if random_b == 0:
			if player.global_position.x + 300 > 2760:
				bear_instance.global_position.x = player.global_position.x - 325
			else:
				bear_instance.global_position.x = player.global_position.x + 325
		else:
			if player.global_position.x - 300 < 1792:
				bear_instance.global_position.x = player.global_position.x + 325
			else:
				bear_instance.global_position.x = player.global_position.x - 325
		spawn_bears_timer_started = false

func spawning_bears_2():
	random_bear = rng.randi_range(0,1)
	if not spawn_bears_timer_started:
		spawn_bears_timer.start()
		spawn_bears_timer_started = true
	if spawn_bears_timer_started and spawn_bears_timer.time_left == 0:
		if random_bear == 0:
			bear = load("res://Source/Actors/Enemies/Bear/running_bear_enemy.tscn")
		else:
			bear = load("res://Source/Actors/Enemies/ArmoredBear/armored_bear_enemy.tscn")
		random_b = rng.randi_range(0,1)
		var bear_instance = bear.instantiate()
		var world = get_tree().current_scene
		world.add_child(bear_instance)
		bear_instance.global_position.y = 176
		if random_b == 0:
			if player.global_position.x + 250 > 4888:
				bear_instance.global_position.x = player.global_position.x - 250
			else:
				bear_instance.global_position.x = player.global_position.x + 250
		else:
			if player.global_position.x - 250 < 4272:
				bear_instance.global_position.x = player.global_position.x + 250
			else:
				bear_instance.global_position.x = player.global_position.x - 250
		spawn_bears_timer_started = false

#TRIGGER PENGUIN AREA FUNCTIONS

func _on_trigger_penguin_area_body_entered(_body):
	spawn_penguins_1 = true

func _on_trigger_penguin_area_body_exited(_body):
	spawn_penguins_timer_started = false
	spawn_penguins_1 = false

func _on_trigger_penguins_area_2_body_entered(_body):
	spawn_penguins_2 = true

func _on_trigger_penguins_area_2_body_exited(_body):
	spawn_penguins_timer_started = false
	spawn_penguins_2 = false

func _on_trigger_penguins_area_3_body_entered(_body):
	spawn_penguins_timer.wait_time = 5
	spawn_penguins_3 = true

func _on_trigger_penguins_area_3_body_exited(_body):
	spawn_penguins_timer_started = false
	spawn_penguins_3 = false

func spawning_penguins_1():
	if not spawn_penguins_timer_started:
		spawn_penguins_timer.start()
		spawn_penguins_timer_started = true
	if spawn_penguins_timer_started and spawn_penguins_timer.time_left == 0:
		penguin = load("res://Source/Actors/Enemies/MagicPenguin/magic_penguin_left.tscn")
		var penguin_instance = penguin.instantiate()
		var world = get_tree().current_scene
		world.add_child(penguin_instance)
		penguin_instance.global_position.y = 290
		penguin_instance.global_position.x = player.global_position.x + 275
		spawn_penguins_timer_started = false

func spawning_penguins_2():
	if not spawn_penguins_timer_started:
		spawn_penguins_timer.start()
		spawn_penguins_timer_started = true
	if spawn_penguins_timer_started and spawn_penguins_timer.time_left == 0:
		penguin = load("res://Source/Actors/Enemies/MagicPenguin/magic_penguin_left.tscn")
		var penguin_instance = penguin.instantiate()
		var world = get_tree().current_scene
		world.add_child(penguin_instance)
		penguin_instance.global_position.y = -160
		penguin_instance.global_position.x = player.global_position.x + 235
		spawn_penguins_timer_started = false

func spawning_penguins_3():
	if not spawn_penguins_timer_started:
		spawn_penguins_timer.start()
		spawn_penguins_timer_started = true
	if spawn_penguins_timer_started and spawn_penguins_timer.time_left == 0:
		penguin = load("res://Source/Actors/Enemies/MagicPenguin/magic_penguin_left.tscn")
		var penguin_instance = penguin.instantiate()
		var world = get_tree().current_scene
		world.add_child(penguin_instance)
		penguin_instance.global_position.y = 176
		penguin_instance.global_position.x = player.global_position.x + 235
		spawn_penguins_timer_started = false

#SPAWN ARMORED SLIMES

func spawn_slimes_1():
	var world = get_tree().current_scene
	if not mist_effect_spawned_1:
		var mist_effect = load("res://Source/Actors/Enemies/Effects/spawn_mist_effect.tscn")
		var mist_effect_instance = mist_effect.instantiate()
		world.add_child(mist_effect_instance)
		mist_effect_instance.global_position.x = 7384
		mist_effect_instance.global_position.y = 1152
		mist_effect_instance.will_end = false
		mist_effect_spawned_1 = true
	if not spawn_slimes_timer_1_started:
		spawn_slimes_timer_1.start()
		spawn_slimes_timer_1_started = true
	if spawn_slimes_timer_1_started and spawn_slimes_timer_1.time_left == 0:
		var slime = load("res://Source/Actors/Enemies/ArmoredSlime/armored_slime.tscn")
		var slime_instance = slime.instantiate()
		world.add_child(slime_instance)
		slime_instance.global_position.x = 7384
		slime_instance.global_position.y = 1152
		slime_instance.will_despawn = true
		spawn_slimes_timer_1_started = false

func spawn_slimes_2():
	var world = get_tree().current_scene
	if not mist_effect_spawned_2:
		var mist_effect = load("res://Source/Actors/Enemies/Effects/spawn_mist_effect.tscn")
		var mist_effect_instance = mist_effect.instantiate()
		world.add_child(mist_effect_instance)
		mist_effect_instance.global_position.x = 7656
		mist_effect_instance.global_position.y = 1232
		mist_effect_instance.will_end = false
		mist_effect_spawned_2 = true
	if not spawn_slimes_timer_2_started:
		spawn_slimes_timer_2.start()
		spawn_slimes_timer_2_started = true
	if spawn_slimes_timer_2_started and spawn_slimes_timer_2.time_left == 0:
		var slime = load("res://Source/Actors/Enemies/ArmoredSlime/armored_slime.tscn")
		var slime_instance = slime.instantiate()
		world.add_child(slime_instance)
		slime_instance.global_position.x = 7658
		slime_instance.global_position.y = 1232
		slime_instance.will_start_left = true
		slime_instance.will_despawn = true
		spawn_slimes_timer_2_started = false

func spawn_slimes_3():
	var world = get_tree().current_scene
	if not mist_effect_spawned_3:
		var mist_effect = load("res://Source/Actors/Enemies/Effects/spawn_mist_effect.tscn")
		var mist_effect_instance = mist_effect.instantiate()
		world.add_child(mist_effect_instance)
		mist_effect_instance.global_position.x = 7384
		mist_effect_instance.global_position.y = 1312
		mist_effect_instance.will_end = false
		mist_effect_spawned_3 = true
	if not spawn_slimes_timer_3_started:
		spawn_slimes_timer_3.start()
		spawn_slimes_timer_3_started = true
	if spawn_slimes_timer_3_started and spawn_slimes_timer_3.time_left == 0:
		var slime = load("res://Source/Actors/Enemies/ArmoredSlime/armored_slime.tscn")
		var slime_instance = slime.instantiate()
		world.add_child(slime_instance)
		slime_instance.global_position.x = 7384
		slime_instance.global_position.y = 1312
		slime_instance.will_despawn = true
		spawn_slimes_timer_3_started = false

#BARRIER BLOCK FUNCTIONS

func add_barrier_blocks_1():
	var barrier_block = load("res://Source/Level Creation/barrier_block.tscn")
	var barrier_block_instance_1 = barrier_block.instantiate()
	var barrier_block_instance_2 = barrier_block.instantiate()
	var barrier_block_instance_3 = barrier_block.instantiate()
	var world = get_tree().current_scene
	world.add_child(barrier_block_instance_1)
	world.add_child(barrier_block_instance_2)
	world.add_child(barrier_block_instance_3)
	barrier_block_instance_1.global_position.x = 1800
	barrier_block_instance_2.global_position.x = 1800
	barrier_block_instance_3.global_position.x = 1800
	barrier_block_instance_1.global_position.y = 184
	barrier_block_instance_2.global_position.y = 200
	barrier_block_instance_3.global_position.y = 216

func add_barrier_blocks_2():
	var barrier_block = load("res://Source/Level Creation/barrier_block.tscn")
	var barrier_block_instance_1 = barrier_block.instantiate()
	var world = get_tree().current_scene
	world.add_child(barrier_block_instance_1)
	barrier_block_instance_1.global_position.x = 7144
	barrier_block_instance_1.global_position.y = 880

#SPAWN ORB FUNCTION

func start_orb_timer():
	if not spawn_orb_timer_started:
		spawn_orb_timer.start()
		spawn_orb_timer_started = true

func spawn_orb():
	if spawn_orb_timer_started and spawn_orb_timer.time_left == 0 and not boss_orb_spawned:
		var boss_orb = load("res://Source/Level Creation/boss_orb.tscn")
		var boss_orb_instance = boss_orb.instantiate()
		var world = get_tree().current_scene
		world.add_child(boss_orb_instance)
		boss_orb_instance.global_position = spawn_orb_position
		boss_orb_spawned = true

