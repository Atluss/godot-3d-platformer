extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var ACCSELERATION = 1
var heig
var DE_ACCSELERATION = 30
var velocity = Vector3()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	
	translation.y += ACCSELERATION * delta
	
	pass
