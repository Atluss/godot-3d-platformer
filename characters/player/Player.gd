extends "res://characters/Character.gd"

var camera

func _ready():
	
	camera = $Camera.get_global_transform()

func _input(event):
	if event.is_action_pressed("action_jump"):
		if not state in [IDLE, MOVE, IN_AIR]:
			return
			
		if state == IN_AIR and double_jump_state == false:
			return
		
		if state == IN_AIR and double_jump_state == true:
			double_jump_state = false
		
		_change_state(JUMP)

func _physics_process(delta):
	input_direction = Vector3()
	
	input_direction.x  = float(Input.is_action_pressed("move_right")) - float(Input.is_action_pressed("move_left"))
	input_direction.z  = float(Input.is_action_pressed("move_down")) - float(Input.is_action_pressed("move_up"))
	
#	if input_direction and input_direction != last_move_direction:
#		emit_signal('direction_changed', input_direction)
	
	max_speed = MAX_RUN_SPEED if Input.is_action_pressed("action_run") else MAX_WALK_SPEED
