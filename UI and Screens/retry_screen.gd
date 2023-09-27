extends Control

@onready var lives_left_label = $LivesLeftLabel
@onready var retry_button = $VBoxContainer/RetryButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	SoundPlayer.stop_bg_stage_music()
	SoundPlayer.stop_boss_music()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	retry_button.grab_focus()
	lives_left_label.text = "lives left %s" % PlayerData.player_lives

func _on_retry_button_button_up():
	quit_button.focus_mode = FOCUS_NONE
	retry_button.focus_mode = FOCUS_NONE
	SoundPlayer.play_death_jingle_sound()
	await SoundPlayer.death_jingle_sound.finished
	PlayerData.essence_value = int(round(PlayerData.essence_value/2))
	PlayerData.player_movement_disabled = false 
	PlayerData.garglius_health = 50
	PlayerData.health = 10
	PlayerData.score /= 2
	get_tree().change_scene_to_file("res://Source/Levels/world.tscn")

func _on_quit_button_button_up():
	PlayerData.score = 0 
	PlayerData.ability_active = false 
	PlayerData.essence_value = 0 
	PlayerData.player_movement_disabled = false 
	PlayerData.garglius_health = 50
	PlayerData.player_lives = 10
	PlayerData.health = 10
	get_tree().change_scene_to_file("res://Source/UI and Screens/start_screen.tscn")
