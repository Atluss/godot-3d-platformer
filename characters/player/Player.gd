extends "res://characters/Character.gd"

func _physics_process(delta):
	input_direction = Vector3()
	
	input_direction.x  = float(Input.is_action_pressed("move_right")) - float(Input.is_action_pressed("move_left"))
	input_direction.z  = float(Input.is_action_pressed("move_down")) - float(Input.is_action_pressed("move_up"))
	
	if input_direction and input_direction != last_move_direction:
		emit_signal('direction_changed', input_direction)
	
	max_speed = MAX_RUN_SPEED if Input.is_action_pressed("action_run") else MAX_WALK_SPEED
