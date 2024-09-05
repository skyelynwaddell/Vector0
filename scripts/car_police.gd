extends Node
@onready var blue = $blue
@onready var red = $red

var bluelight = 1
var redlight = 0

var on = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var flashspd = 0.1
	var maxEnergy = 3
	
	match(on):
		true:
			redlight -= flashspd
			bluelight += flashspd
			
			if bluelight >= maxEnergy: 
				on = !on
		false:
			redlight += flashspd
			bluelight -= flashspd
			
			if redlight >= maxEnergy: 
				on = !on
	
	red.set_param(Light3D.PARAM_ENERGY, redlight)
	blue.set_param(Light3D.PARAM_ENERGY, bluelight)
	
	pass
