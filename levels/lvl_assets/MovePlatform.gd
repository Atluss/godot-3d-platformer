extends Spatial

var ACCSELERATION = 1
var heig
var DE_ACCSELERATION = 30
var velocity = Vector3()

export var motion = Vector3()
export var cycle = 1.0
var accum = 0.0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	
	var velocity = Vector3()
	
#	global_translate(Vector3(0,delta,0))

	accum += delta * (1.0 / cycle) * PI * 2.0
	accum = fmod(accum, PI * 2.0)
	var d = sin(accum)
	var xf = Transform()
	xf[3]= motion * d 
	transform = transform * xf
