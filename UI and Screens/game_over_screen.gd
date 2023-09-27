extends Control

@onready var retry_button = $VBoxContainer/RetryButton

func _ready():
	SoundPlayer.stop_bg_stage_music()
	SoundPlayer.stop_boss_music()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	retry_button.grab_focus()

func _on_retry_button_button_up():
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
