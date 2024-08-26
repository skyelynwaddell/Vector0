#Doctor
extends NPC

#Doctor Type [ 1 - 4 ]
@export var type = 1
@export var animTree = $AnimTreeDoctor1

var aWalk = 0.0
var aTalk = 0.0
var aRun = 0.0
var aInteract = 0.0
var aScared = 0.0
var aCower = 0.0
var aDie = 0.0

var IDLE = 0
var TALK = 1
var WALK = 2
var RUN = 3
var INTERACT = 4
var SCARED = 5
var COWER = 6
var DIE = 7

var state = IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Switch Animation tree depending on Doctor Type
	match(type):
		1:
			animTree = $AnimTreeDoctor1
			pass
		2:
			animTree = $AnimTreeDoctor1
			pass
		3:
			animTree = $AnimTreeDoctor1
			pass
		4:
			animTree = $AnimTreeDoctor1
			pass
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("num1"): state = IDLE
	if Input.is_action_just_pressed("num2"): state = TALK
	if Input.is_action_just_pressed("num3"): state = WALK
	if Input.is_action_just_pressed("num4"): state = RUN
	if Input.is_action_just_pressed("num5"): state = INTERACT
	if Input.is_action_just_pressed("num6"): state = SCARED
	if Input.is_action_just_pressed("num7"): state = COWER
	if Input.is_action_just_pressed("num8"): state = DIE
	
	animTree.set("parameters/Walk/blend_amount", aWalk)
	animTree.set("parameters/Talk/blend_amount", aTalk)
	animTree.set("parameters/Run/blend_amount", aRun)
	animTree.set("parameters/Interact/blend_amount", aInteract)
	animTree.set("parameters/Scared/blend_amount", aScared)
	animTree.set("parameters/Cower/blend_amount", aCower)
	animTree.set("parameters/Die/blend_amount", aDie)
	
	#animation speed
	var aspd = 0.1
	
	match(state):
		IDLE:
			aWalk = lerp(aWalk, 0.0, aspd)
			aTalk = lerp(aTalk, 0.0, aspd)
			aRun = lerp(aRun, 0.0, aspd)
			aInteract = lerp(aInteract, 0.0, aspd)
			aScared = lerp(aScared, 0.0, aspd)
			aCower = lerp(aCower, 0.0, aspd)
			aDie = lerp(aDie, 0.0, aspd)
			pass
		TALK:
			aTalk = lerp(aTalk, 1.0, aspd)
			
			aWalk = lerp(aWalk, 0.0, aspd)
			aRun = lerp(aRun, 0.0, aspd)
			aInteract = lerp(aInteract, 0.0, aspd)
			aScared = lerp(aScared, 0.0, aspd)
			aCower = lerp(aCower, 0.0, aspd)
			aDie = lerp(aDie, 0.0, aspd)
			pass
		WALK:
			aWalk = lerp(aWalk, 1.0, aspd)
			
			aTalk = lerp(aTalk, 0.0, aspd)
			aRun = lerp(aRun, 0.0, aspd)
			aInteract = lerp(aInteract, 0.0, aspd)
			aScared = lerp(aScared, 0.0, aspd)
			aCower = lerp(aCower, 0.0, aspd)
			aDie = lerp(aDie, 0.0, aspd)
			pass
		RUN:
			aRun = lerp(aRun, 1.0, aspd)
			
			aWalk = lerp(aWalk, 0.0, aspd)
			aTalk = lerp(aTalk, 0.0, aspd)
			aInteract = lerp(aInteract, 0.0, aspd)
			aScared = lerp(aScared, 0.0, aspd)
			aCower = lerp(aCower, 0.0, aspd)
			aDie = lerp(aDie, 0.0, aspd)
			pass
		INTERACT:
			aInteract = lerp(aInteract, 1.0, aspd)
			
			aWalk = lerp(aWalk, 0.0, aspd)
			aTalk = lerp(aTalk, 0.0, aspd)
			aRun = lerp(aRun, 0.0, aspd)
			aScared = lerp(aScared, 0.0, aspd)
			aCower = lerp(aCower, 0.0, aspd)
			aDie = lerp(aDie, 0.0, aspd)
			pass
		SCARED:
			aScared = lerp(aScared, 1.0, aspd)
			
			aWalk = lerp(aWalk, 0.0, aspd)
			aTalk = lerp(aTalk, 0.0, aspd)
			aRun = lerp(aRun, 0.0, aspd)
			aInteract = lerp(aInteract, 0.0, aspd)
			aCower = lerp(aCower, 0.0, aspd)
			aDie = lerp(aDie, 0.0, aspd)
			pass
		COWER:
			aCower = lerp(aCower, 1.0, aspd)
			
			aWalk = lerp(aWalk, 0.0, aspd)
			aTalk = lerp(aTalk, 0.0, aspd)
			aRun = lerp(aRun, 0.0, aspd)
			aInteract = lerp(aInteract, 0.0, aspd)
			aScared = lerp(aScared, 0.0, aspd)
			aDie = lerp(aDie, 0.0, aspd)
			pass
		DIE:
			aDie = lerp(aDie, 1.0, aspd)
			
			aWalk = lerp(aWalk, 0.0, aspd)
			aTalk = lerp(aTalk, 0.0, aspd)
			aRun = lerp(aRun, 0.0, aspd)
			aInteract = lerp(aInteract, 0.0, aspd)
			aScared = lerp(aScared, 0.0, aspd)
			aCower = lerp(aCower, 0.0, aspd)
			pass
	
	pass

func _physics_process(delta):
	MoveToTarget(delta)

func onAreaEntered(area):
	if area.is_in_group("WalkPoint"):
		self.state = WALK
	GetTarget(area)

func _on_findtarget():
	pass # Replace with function body.
