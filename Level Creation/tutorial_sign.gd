extends Node2D

@onready var text_box = $TextBox
@onready var player_detection_zone = $PlayerDetectionZone
@onready var label = $Label

func _ready():
	text_box.visible = false
	label.visible = false

func _process(_delta):
	if player_detection_zone.can_see_player():
		text_box.visible = true
		label.visible = true
	else:
		text_box.visible = false
		label.visible = false
