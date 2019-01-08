extends KinematicBody

signal speed_updated
signal state_changed

var input_direction = Vector3()
var last_move_direction = Vector3()

const MAX_WALK_SPEED = 400
const MAX_RUN_SPEED = 700

var speed = 0.0
var max_speed = 0.0

var velocity = Vector3()

var state = null

enum STATE { IDLE, MOVE }

func _ready():
	_change_state(IDLE)

func _change_state(new_state):
	
	match new_state:
		IDLE:
			$AnimationPlayer.play('idle')
		MOVE:
			$AnimationPlayer.play('walk')
	
	state = new_state
	emit_signal('state_changed', new_state)
	

func _physics_process(delta):
	update_direction()
	
	if state == IDLE and input_direction:
		_change_state(MOVE)
	elif state == MOVE:
		move(delta)
		if not input_direction:
			_change_state(IDLE)

func update_direction():
	if input_direction:
		last_move_direction = input_direction

func move(delta):
	if input_direction:
		if speed != max_speed:
			speed = max_speed
	else:
		speed = 0.0
	emit_signal('speed_updated', speed)
		
	velocity = input_direction.normalized() * speed * delta
	move_and_slide(velocity, Vector3(0, 1, 0))