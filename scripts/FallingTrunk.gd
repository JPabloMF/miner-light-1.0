extends KinematicBody2D

var motion = Vector2()
var player_tentered = false
var _timerFall = null

func get_timer():
	_timerFall = Timer.new()
	add_child(_timerFall)
	_timerFall.connect("timeout", self, "_on_Timer_timeout")
	_timerFall.set_wait_time(0.3)
	_timerFall.set_one_shot(false) # Make sure it loops
	
func start_timer():
	_timerFall.start()
	
func stop_timer():
	_timerFall.stop()
	
func _on_Timer_timeout():
	player_tentered = true
	stop_timer()

func _ready():
	get_timer()
	pass # Replace with function body.

func _physics_process(delta):
	if player_tentered:
		motion.y += 20
	motion = move_and_slide(motion,Vector2.UP,false,4,PI/4,false)

func _on_FallingTrunk_area_entered(area):
	if "Player" in area.get_name():
		start_timer()
