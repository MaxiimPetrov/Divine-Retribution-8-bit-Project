extends Node

signal score_updated
signal ability_active_updated
signal essence_value_updated
signal no_health
signal health_updated
signal player_lives_updated
signal garglius_health_updated
signal garglius_died

var score = 0  : set = set_score
var ability_active = false  : set = set_ability_active
var essence_value = 0 : set = set_essence_value
var player_max_health = 10
var player_movement_disabled = false : set = disable_player_movement
var garglius_health = 50 : set = set_garglius_health
var player_lives = 5 : set = set_player_lives
var health = player_max_health : set = set_health
var player_starting_position = Vector2(0, 0) : set = set_player_starting_position
var boss_orb_collected = false : set = set_orb_collected

func set_health(value):
	health = value
	if health < 0:
		health = 0
	if health > 10:
		health = 10
	emit_signal("health_updated")
	if health == 0:
		emit_signal("no_health")

func set_score(value):
	score = value
	if score > 99999:
		score = 99999
	emit_signal("score_updated")

func set_ability_active(value):
	ability_active = value
	emit_signal("ability_active_updated")

func set_essence_value(value):
	essence_value = value
	if essence_value > 99:
		essence_value = 99
	emit_signal("essence_value_updated")

func disable_player_movement(value):
	player_movement_disabled = value

func set_garglius_health(value):
	garglius_health = value
	emit_signal("garglius_health_updated")
	if garglius_health <= 0:
		emit_signal("garglius_died")

func set_player_lives(value):
	player_lives = value
	emit_signal("player_lives_updated")

func set_player_starting_position(value):
	player_starting_position = value

func set_orb_collected(value):
	boss_orb_collected = value
