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

var height = 0.0 setget set_height

var speed = 0.0
var max_speed = 0.0

var velocity = Vector3()

var state = null

enum STATE { IDLE, MOVE, BUMP }

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
			if speed == MAX_RUN_SPEED and collider.is_in_group('environment'):
				_change_state(BUMP)

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
	
	var slide_count = get_slide_count()
	return get_slide_collision(slide_count - 1) if slide_count else null
	
func set_height(value):
	$Pivot.translation.y = value
	height = value
	
func animate_bump_height(progress):
	self.height = pow(sin(progress * PI), 0.4) * MAX_BUMP_HEIGHT
	
func _on_Tween_tween_completed(object, key):
	# Bump state end
	# This function is unique to the bump state, so we know the key is also unique to it
	# while we may animate the 'position' in other states
	# Don't forget the leading ':'
	if key == ":animate_bump_height":
		_change_state(IDLE)