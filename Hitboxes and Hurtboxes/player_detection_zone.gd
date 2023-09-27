extends Area2D

var player = null

func can_see_player():
	return player != null

func _on_player_detection_zone_entered(body):
	player = body

func _on_player_detection_zone_exited(_body):
	player = null
