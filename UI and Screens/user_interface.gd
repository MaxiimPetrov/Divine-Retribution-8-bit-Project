extends Control

@onready var scene_tree = get_tree()
@onready var pause_overlay = $PauseOverlay
@onready var score_label = $ScoreLabel
@onready var essence_label = $EssenceLabel
@onready var flame_sprite = $FlameSprite
@onready var player_health = $PlayerHealth
@onready var enemy_health = $EnemyHealth
@onready var resume_button = $PauseOverlay/PauseMenu/ResumeButton

var paused = false  : set = set_paused

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	PlayerData.score_updated.connect(update_interface)
	PlayerData.health_updated.connect(update_interface)
	PlayerData.essence_value_updated.connect(update_interface)
	PlayerData.ability_active_updated.connect(update_interface)
	PlayerData.garglius_health_updated.connect(update_interface)
	update_interface()

func _unhandled_input(event):
	if event.is_action_pressed("Pause") and PlayerData.health > 0:
		resume_button.grab_focus()
		self.paused = !paused

func set_paused(value):
	paused = value
	scene_tree.paused = value
	pause_overlay.visible = value

func update_interface():
	score_label.text = "%s" % PlayerData.score
	essence_label.text = "%s" % PlayerData.essence_value
	if PlayerData.ability_active == true:
		flame_sprite.visible = true
	player_health.size.x = PlayerData.health * 8.8
	if PlayerData.garglius_health <= 45 and PlayerData.garglius_health > 40:
		enemy_health.size.x = 88 - 8.8
	elif PlayerData.garglius_health <= 40 and PlayerData.garglius_health > 35:
		enemy_health.size.x = 88 - 8.8 * 2
	elif PlayerData.garglius_health <= 35 and PlayerData.garglius_health > 30:
		enemy_health.size.x = 88 - 8.8 * 3
	elif PlayerData.garglius_health <= 30 and PlayerData.garglius_health > 25:
		enemy_health.size.x = 88 - 8.8 * 4
	elif PlayerData.garglius_health <= 25 and PlayerData.garglius_health > 20:
		enemy_health.size.x = 88 - 8.8 * 5
	elif PlayerData.garglius_health <= 20 and PlayerData.garglius_health > 15:
		enemy_health.size.x = 88 - 8.8 * 6
	elif PlayerData.garglius_health <= 15 and PlayerData.garglius_health > 10:
		enemy_health.size.x = 88 - 8.8 * 7
	elif PlayerData.garglius_health <= 10 and PlayerData.garglius_health > 5:
		enemy_health.size.x = 88 - 8.8 * 8
	elif PlayerData.garglius_health <= 5 and PlayerData.garglius_health > 0:
		enemy_health.size.x = 88 - 8.8 * 9
	elif PlayerData.garglius_health <= 0:
		enemy_health.size.x = 88 - 8.8 * 10

func _on_quit_button_button_up():
	SoundPlayer.stop_bg_stage_music()
	SoundPlayer.stop_boss_music()
	PlayerData.score = 0 
	PlayerData.ability_active = false 
	PlayerData.essence_value = 0 
	PlayerData.player_movement_disabled = false 
	PlayerData.garglius_health = 50
	PlayerData.player_lives = 5 
	PlayerData.health = 10
	get_tree().change_scene_to_file("res://Source/UI and Screens/start_screen.tscn")

func _on_resume_button_button_up():
	resume_button.grab_focus()
	self.paused = !paused
