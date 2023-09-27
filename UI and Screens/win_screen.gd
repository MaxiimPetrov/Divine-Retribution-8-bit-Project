extends Control

@onready var lives_left_label = $LivesLeftLabel
@onready var final_score_label = $FinalScoreLabel
@onready var play_again_button = $VBoxContainer/PlayAgainButton

func _ready():
	SoundPlayer.stop_bg_stage_music()
	SoundPlayer.stop_boss_music()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	play_again_button.grab_focus()
	lives_left_label.text = "lives left %s" % PlayerData.player_lives
	final_score_label.text = "final score %s" % PlayerData.score

func _on_play_again_button_button_up():
	SoundPlayer.stop_bg_stage_music()
	SoundPlayer.stop_boss_music()
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

func _on_return_button_button_up():
	PlayerData.score = 0 
	PlayerData.ability_active = false 
	PlayerData.essence_value = 0 
	PlayerData.player_movement_disabled = false 
	PlayerData.garglius_health = 50
	PlayerData.player_lives = 10
	PlayerData.health = 10
	get_tree().change_scene_to_file("res://Source/UI and Screens/start_screen.tscn")
