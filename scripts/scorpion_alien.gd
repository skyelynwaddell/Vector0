@tool
extends Enemy

#states
var SUCKONHEAD = 10
var chaseDistance = 20
@onready var animTree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): return
	state = IDLE
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint(): return
	if Input.is_action_just_pressed("num1"): ChangeState(IDLE)
	if Input.is_action_just_pressed("num2"): ChangeState(WALK)
	if Input.is_action_just_pressed("num3"): ChangeState(ATTACK)
	if Input.is_action_just_pressed("num4"): ChangeState(SUCKONHEAD)
	
	distToPlayer = transform.origin.distance_to(player.position)
	
	match(state):
		IDLE:
			animTree.set("parameters/Walk/blend_amount", 0.0)
			if distToPlayer <= chaseDistance && shouldChase:
				ChangeState(CHASEPLAYER)
			pass
		WALK:
			animTree.set("parameters/Walk/blend_amount", 1.0)
			pass
		ATTACK:
			animTree.set("parameters/Attack/blend_amount", 1.0)
			FacePlayer(delta)
			pass
		DEATH:
			animTree["parameters/Walk/blend_amount"] = 0.0
			animTree["parameters/Attack/blend_amount"] = 0.0
			animTree["parameters/Death/blend_amount"] = 1.0
			pass
		CHASEPLAYER:
			if hpcurrent <= 0: ChangeState(DEATH)
			#if distToPlayer > chaseDistance: ChangeState(IDLE)
			target = player
			targetOrigin = target.position
			animTree.set("parameters/Walk/blend_amount", 1.0)
			FacePlayer(delta)
			MoveToTarget(delta)
			pass
			
		SUCKONHEAD:
			animTree.set("parameters/SuckOnHead/blend_amount", 1.0)
			pass
	pass

func _physics_process(delta):
	pass
	
func ChangeState(newState):
	ResetAllAnims()
	state = newState

func ResetAllAnims():
	animTree.set("parameters/Walk/blend_amount", 0.0)
	animTree.set("parameters/Attack/blend_amount", 0.0)
	animTree.set("parameters/SuckOnHead/blend_amount", 0.0)
	
func on_trigger():
	if hpcurrent <= 0: return
	ChangeState(CHASEPLAYER)
	print_debug("Trigger Success!")
