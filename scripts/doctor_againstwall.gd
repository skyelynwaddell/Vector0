#Doctor
extends NPC

#Doctor Type [ 1 - 4 ]
@export var type = 1
@export var animTree = $AnimTreeDoctor1

var aAgainstWall = 0.0
var AGAINST_WALL = 0
var state = AGAINST_WALL

# Called when the node enters the scene tree for the first time.
func _ready():
	state = AGAINST_WALL
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	animTree.set("parameters/AgainstWall/blend_amount", 1.0)
	
	#animation speed
	var aspd = 0.1
	
	
	pass

func _physics_process(delta):
	MoveToTarget(delta)

func onAreaEntered(area):
	pass

func _on_findtarget():
	pass # Replace with function body.
