extends Node

@onready var essence_pickup_sound = $Sounds/EssencePickupSound
@onready var score_pickup_sound = $Sounds/ScorePickupSound
@onready var block_destroyed_sound = $Sounds/BlockDestroyedSound
@onready var death_blow_sound = $Sounds/DeathBlowSound
@onready var death_jingle_sound = $Sounds/DeathJingleSound
@onready var garglius_laser_sound = $Sounds/GargliusLaserSound
@onready var garglius_wings_sound = $Sounds/GargliusWingsSound
@onready var fireball_pickup_sound = $Sounds/FireballPickupSound
@onready var health_pickup_sound = $Sounds/HealthPickupSound
@onready var player_hurt_sound = $Sounds/PlayerHurtSound
@onready var startup_jingle_sound = $Sounds/StartupJingleSound
@onready var whip_sound = $Sounds/WhipSound
@onready var whip_hit_sound = $Sounds/WhipHitSound
@onready var stage_music_sound = $Sounds/StageMusicSound
@onready var fireball_cast_sound = $Sounds/FireballCastSound
@onready var boss_music_sound = $Sounds/BossMusicSound
@onready var garglius_death_effect = $Sounds/GargliusDeathEffect
@onready var victory_sound_effect = $Sounds/VictorySoundEffect

func play_essence_pickup_sound():
	essence_pickup_sound.play()

func play_score_pickup_sound():
	score_pickup_sound.play()

func play_block_destroyed_sound():
	block_destroyed_sound.play()

func play_death_sound():
	death_blow_sound.play()

func play_death_jingle_sound():
	death_jingle_sound.play()

func play_fireball_pickup_sound():
	fireball_pickup_sound.play()

func play_heath_pickup_sound():
	health_pickup_sound.play()

func play_player_hurt_sound():
	player_hurt_sound.play()

func play_startup_jingle():
	startup_jingle_sound.play()

func play_whip_sound():
	whip_sound.play()

func play_whip_hit_sound():
	whip_hit_sound.play()

func play_garglius_laser_sound():
	garglius_laser_sound.play()

func play_garglius_wing_sound():
	garglius_wings_sound.play()

func play_fireball_cast_sound():
	fireball_cast_sound.play()

func play_bg_stage_music():
	stage_music_sound.play()

func stop_bg_stage_music():
	stage_music_sound.stop()

func play_boss_music():
	boss_music_sound.play()

func stop_boss_music():
	boss_music_sound.stop()

func play_garglius_death_sound():
	garglius_death_effect.play()

func play_victory_sound():
	victory_sound_effect.play()
