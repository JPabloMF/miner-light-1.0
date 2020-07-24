extends KinematicBody2D

const ACCELERATION = 50
const MAX_SPEED = 150
var motion = Vector2()

var stairs_entered = false
var died = false
var moving_cage_entered = false

var collision_magic_house = false
var collision_armory = false
var collision_magic_house_first_floor_tp = false
var collision_magic_house_second_floor_tp = false
var collision_jump_wall = false

# This timer is to prevent movement breaks
var move_timer = 0
var last_horizontal_key_pressed = ""

var _timerDash = null
var has_key = false

func get_timer():
	_timerDash = Timer.new()
	add_child(_timerDash)
	_timerDash.connect("timeout", self, "_on_Timer_timeout")
	_timerDash.set_wait_time(0.2)
	_timerDash.set_one_shot(false) # Make sure it loops
	
func start_timer():
	_timerDash.start()
	
func stop_timer():
	_timerDash.stop()
	
func _on_Timer_timeout():
	stop_timer()

# GUI
func handle_show_key():
	if has_key:
		$CanvasLayer/ContainerKey.show()
	
# MOVEMENT
func handle_apply_gravity():
	if stairs_entered:
		motion.y = 0
	else:
		motion.y += 10

func handle_horizontal_movement():
	if Input.is_action_pressed("ui_left"):
		Input.vibrate_handheld(500)
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		last_horizontal_key_pressed = "left"
		if not is_on_wall():
			$AnimationPlayer.play("runLeft")
		else:
			$AnimationPlayer.play("idleLeft")
	elif Input.is_action_pressed("ui_right"):
		Input.vibrate_handheld(500)
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		last_horizontal_key_pressed = "right"
		if not is_on_wall():
			$AnimationPlayer.play("runRight")
		else:
			$AnimationPlayer.play("idleRight")
	else:
		if not stairs_entered:
			if last_horizontal_key_pressed == "right":
				$AnimationPlayer.play("idleRight")
			else:
				$AnimationPlayer.play("idleLeft")
		motion.x = lerp(motion.x, 0, 0.5)

func handle_vertical_movement():
	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			motion.y = -270
	elif stairs_entered:
		if Input.is_action_pressed("ui_up"):
			$AnimationPlayer.play("stairs")
			motion.y = -100
		elif Input.is_action_pressed("ui_down"):
			$AnimationPlayer.play("stairs")
			motion.y = +100
		else:
			$AnimationPlayer.play("stairsIdle")
	else:
		if motion.y < 0:
			if last_horizontal_key_pressed == "right":
				$AnimationPlayer.play("jumpRight")
			else:
				$AnimationPlayer.play("jumpLeft")
		else:
			if last_horizontal_key_pressed == "right":
				$AnimationPlayer.play("landRight")
			else:
				$AnimationPlayer.play("landLeft")

func handle_initial_animation():
	yield(get_tree().create_timer(0.35), "timeout")
	$DieAnimation.hide()
	$RespawnAnimation.play("respawn")
	yield(get_tree().create_timer(0.35), "timeout")
	$RespawnAnimation.hide()

func handle_reset_initial_movements():
	motion.y = 0
	motion.x = 0

# WALL JUMP
func get_which_wall_collided():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if collision.normal.x > 0:
			return "left"
		elif collision.normal.x < 0:
			return "right"
	return "none"

func handle_wall_jump():
	if Input.is_action_pressed("ui_up"):
		# jump in wall
		if not is_on_floor() and is_on_wall() and collision_jump_wall:
			motion.y = -200
			if get_which_wall_collided() == "left":
				motion.x += 600
			else:
				motion.x -= 600
	

# POWERUPS
func handle_dash_movement():
	if last_horizontal_key_pressed == "right":
			$AnimationPlayer.play("idleRight")
			motion.x = +450
			motion.y = 0
	elif last_horizontal_key_pressed == "left":
		$AnimationPlayer.play("idleLeft")
		motion.x = -450
		motion.y = 0
		
func handle_dash():
	if not _timerDash.is_stopped():
		handle_dash_movement()
	if Input.is_action_just_pressed("Dash"): 
		start_timer()

# ENTER SOME PLACE
func handle_enter_magic_house():
	if Input.is_action_pressed("Interaction"):
		if collision_magic_house:
			get_tree().change_scene("res://scenes/worlds/City/MagicHouse.tscn")
		elif collision_magic_house_second_floor_tp:
			get_tree().change_scene("res://scenes/worlds/City/MagicHouse.tscn")
		elif collision_magic_house_first_floor_tp:
			get_tree().change_scene("res://scenes/worlds/City/MagicHouseSecondFloor.tscn")

func handle_enter_armory():
	if Input.is_action_pressed("Interaction"):
		if collision_armory:
			get_tree().change_scene("res://scenes/worlds/City/Armory.tscn")

# UTILS
#func handle_hide_parallax():
#	if get_tree().get_current_scene().get_name() == "MagicHouse":
#		$ParallaxBackground/ParallaxLayer/Sprite.hide()

func handle_camera_offset():
	if get_tree().get_current_scene().get_name() == "City":
		$Camera2D.offset_v = -1
		$RespawnAnimation.offset = Vector2(0,-4.5)

func _ready():
	handle_initial_animation()
	get_timer()
	pass # Replace with function body.

func _physics_process(delta):
	move_timer += delta
	if !died:
		handle_camera_offset()
		handle_apply_gravity()
#		handle_hide_parallax()
#		yield(get_tree().create_timer(0.7), "timeout")
		if move_timer > 0.9:
			handle_horizontal_movement()
			handle_vertical_movement()
			handle_enter_magic_house()
			handle_enter_armory()
#			handle_dash()
			handle_wall_jump()
			handle_show_key()
	else:
		motion.x = 0
	motion = move_and_slide(motion,Vector2.UP,false,4,PI/4,false)

# ACTIONS
func handle_die():
	died = true
	$DieAnimation.show()
	$DieAnimation.play("die")
	yield(get_tree().create_timer(0.35), "timeout")
	get_tree().reload_current_scene()

func handle_show_iteraction():
	$Iteraction.show()
	
func handle_hide_iteraction():
	$Iteraction.hide()

# COLLISIONS
func _on_Player_area_entered(area):
	if "Trap" in area.get_name():
		handle_die()
	elif "Saw" == area.get_name():
		handle_die()
	elif "Poso" == area.get_name():
		get_tree().change_scene("res://scenes/worlds/First world.tscn")
	elif "Armory" == area.get_name():
		collision_armory = true
		handle_show_iteraction()
	elif "MagicHouse" == area.get_name():
		collision_magic_house = true
		handle_show_iteraction()
	elif "MagicHouseSecondFloorTp" == area.get_name():
		collision_magic_house_second_floor_tp = true
		handle_show_iteraction()
	elif "MagicHouseFirstFloorTp" == area.get_name():
		collision_magic_house_first_floor_tp = true
		handle_show_iteraction()
	elif "Stairs" == area.get_name():
		stairs_entered = true
	elif "ArmoryFirstFloorStair" == area.get_name():
		get_tree().change_scene("res://scenes/worlds/City/ArmorySecondFloor.tscn")
	elif "ArmorySecondFloorStair" == area.get_name():
		get_tree().change_scene("res://scenes/worlds/City/Armory.tscn")
	elif "ExitToCity" == area.get_name():
		get_tree().change_scene("res://scenes/worlds/City/City.tscn")
	elif "JumpWall" in area.get_name():
		collision_jump_wall = true
	elif "Key" == area.get_name():
		has_key = true

func _on_Player_area_exited(area):
	if "MovingCage" == area.get_name():
		moving_cage_entered = false
	elif "Armory" == area.get_name():
		collision_armory = false
		handle_hide_iteraction()
	elif "MagicHouse" == area.get_name():
		handle_hide_iteraction()
		collision_magic_house = false
	elif "MagicHouseSecondFloorTp" == area.get_name():
		collision_magic_house_second_floor_tp = false
		handle_hide_iteraction()
	elif "MagicHouseFirstFloorTp" == area.get_name():
		collision_magic_house_first_floor_tp = false
		handle_hide_iteraction()
	elif "Stairs" == area.get_name():
		stairs_entered = false
	elif "JumpWall" in area.get_name():
		collision_jump_wall = false
