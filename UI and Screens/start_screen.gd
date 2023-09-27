extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	SoundPlayer.stop_bg_stage_music()
	SoundPlayer.stop_boss_music()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	start_button.grab_focus()

func _on_start_button_button_up():
	start_button.focus_mode = FOCUS_NONE
	quit_button.focus_mode = FOCUS_NONE
	SoundPlayer.play_startup_jingle()
	await SoundPlayer.startup_jingle_sound.finished
	PlayerData.boss_orb_collected = false
	PlayerData.score = 0 
	PlayerData.ability_active = false 
	PlayerData.essence_value = 0 
	PlayerData.player_movement_disabled = false 
	PlayerData.garglius_health = 50
	PlayerData.player_lives = 10
	PlayerData.health = 10
	PlayerData.player_starting_position = Vector2(-335, 222)
	get_tree().change_scene_to_file("res://Source/Levels/world.tscn")

func _on_quit_button_button_up():
	get_tree().quit()
