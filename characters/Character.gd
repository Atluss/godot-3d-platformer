extends KinematicBody

signal speed_updated
signal state_changed

var input_direction = Vector3()
var last_move_direction = Vector3()

const MAX_WALK_SPEED = 400
const MAX_RUN_SPEED = 700

const BUMP_DURATION = 0.2
const BUMP_DISTANCE = 4
const MAX_BUMP_HEIGHT = 1
const AIR_ACCELERATION = 10

const JUMP_DURATION = 0.5
const MAX_JUMP_HEIGHT = 5

const GRAVITY = -9.8

var height = 0.0 setget set_height
var max_air_speed = 0.0
var air_speed = 0.0
var air_velocity = Vector3()
var air_steering = Vector3()

var speed = 0.0
var max_speed = 0.0

var velocity = Vector3()

var state = null

enum STATE { IDLE, MOVE, BUMP, JUMP, IN_AIR }

func _ready():
	_change_state(IDLE)
	$Tween.connect("tween_completed", self, '_on_Tween_tween_completed')

func _change_state(new_state):
	
	match new_state:
		IDLE:
			speed = 0.0
			$AnimationPlayer.play('idle')
		MOVE:
			$AnimationPlayer.play('walk')
		BUMP:
			$AnimationPlayer.stop()
			
			$Tween.interpolate_property(self, 'translation', translation, translation + BUMP_DISTANCE * -last_move_direction, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.interpolate_method(self, 'animate_bump_height', 0, MAX_BUMP_HEIGHT, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
		JUMP:
			air_speed = speed
			max_air_speed = max_speed
			air_velocity = velocity
			$AnimationPlayer.play('idle')
			
#			$Tween.interpolate_method(self, '_animate_jump_height', 0, 1, JUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
#			$Tween.start()
			
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
		
		var collission_info = move(delta)
		if collission_info:
			var collider = collission_info.collider
			if speed == MAX_RUN_SPEED and collider.is_in_group('environment') and is_on_wall():
				_change_state(BUMP)
	elif state == JUMP:
		jump(delta)
	elif state == IN_AIR and is_on_floor():
		_change_state(IDLE)
	elif state == IN_AIR:
		jump(delta)
	
	velocity.y += GRAVITY * delta
	move_and_slide(velocity, Vector3(1, 1, 1))

func update_direction():
	if input_direction:
		last_move_direction = input_direction

func move(delta):
	
	var direction = Vector3()
	
	if input_direction:
		if speed != max_speed:
			speed = max_speed
	else:
		speed = 0.0
	emit_signal('speed_updated', speed)
	
	direction = input_direction.normalized() * speed * delta
	
	velocity.x = direction.x
	velocity.z = direction.z
	
	var slide_count = get_slide_count()
	return get_slide_collision(slide_count - 1) if slide_count else null
	
func jump(delta):
	var AIR_ACCELERATION = 1
	var AIR_DECCELERATION = 2
	var AIR_STEERING_POWER = 3
	if input_direction:
		air_speed += AIR_ACCELERATION * delta
	else:
		air_speed -= AIR_DECCELERATION * delta
		
	air_speed = clamp(air_speed, 0.0, max_air_speed)
	
	var target_velocity = air_speed * input_direction.normalized()
	var steering_velocity = (target_velocity - air_velocity).normalized() * AIR_STEERING_POWER
#	air_velocity += steering_velocity
	velocity.x += steering_velocity.x
	velocity.z += steering_velocity.z
	
	if is_on_floor():
		velocity.y = 10
		_change_state(IN_AIR)
	
	
func set_height(value):
	height = value
	$Pivot.translation.y = value
	
func animate_bump_height(progress):
	self.height = pow(sin(progress * PI), 0.4) * MAX_BUMP_HEIGHT
	
func _on_Tween_tween_completed(object, key):
	# Bump state end
	# This function is unique to the bump state, so we know the key is also unique to it
	# while we may animate the 'position' in other states
	# Don't forget the leading ':'
	if key == ":animate_bump_height":
		_change_state(IDLE)
	if key == ":_animate_jump_height":
		_change_state(IDLE)
		
func _animate_jump_height(progress):
	self.height = pow(sin(progress * PI), 0.7) * MAX_JUMP_HEIGHT