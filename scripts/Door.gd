extends KinematicBody2D

var has_key = false
var player_entered = false
var animation_executed = false

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if has_key and player_entered and not animation_executed:
		$AnimationDoor.play("doorOpen")
		animation_executed = true

func _on_door_area_entered(area):
	if "Player" in area.get_name():
		player_entered = true


func _on_Key_area_entered(area):
	if "Player" in area.get_name():
		has_key = true
