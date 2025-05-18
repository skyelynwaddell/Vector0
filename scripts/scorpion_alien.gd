@tool
extends Enemy

#states
var SUCKONHEAD = 10
var chaseDistance = 30
var jumpDistance = 6
var JUMP = 30
var jumpTimer = 2
var jumpTimerMax = 2
var jumpDuration = 0
var jumpDurationMax = 0.2
var jumpBlend = 0.0
@onready var animTree = $AnimationTree
@onready var bloodParticles = $GibParticles/BloodParticles
@onready var gibParticles = $GibParticles/GibParticles
var canEmit = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): return
	state = IDLE
	grvty = 12.0
	%BloodTimer.timeout.connect(BloodTimerDone)  # Connect the timer signal
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Engine.is_editor_hint(): return
	if Input.is_action_just_pressed("num1"): ChangeState(IDLE)
	if Input.is_action_just_pressed("num2"): ChangeState(WALK)
	if Input.is_action_just_pressed("num3"): ChangeState(ATTACK)
	if Input.is_action_just_pressed("num4"): ChangeState(SUCKONHEAD)
	
	distToPlayer = transform.origin.distance_to(player.position)
	
	match(state):
		IDLE:
			if not is_on_floor(): velocity.y -= grvty * delta
			move_and_slide()
			animTree.set("parameters/Walk/blend_amount", 0.0)
			if distToPlayer <= chaseDistance && shouldChase:
				ChangeState(CHASEPLAYER)
			pass
		WALK:
			ApplyGravity(grvty,delta)
			move_and_slide()
			animTree.set("parameters/Walk/blend_amount", 1.0)
			pass
		ATTACK:
			state = CHASEPLAYER
			ApplyGravity(grvty,delta)
			move_and_slide()
			animTree.set("parameters/Attack/blend_amount", 1.0)
			FacePlayer(delta)
			pass
		DEATH:
			EmitGibs()
			ApplyGravity(grvty,delta)
			velocity.x = 0
			velocity.z = 0
			move_and_slide()
			animTree["parameters/Walk/blend_amount"] = 0.0
			animTree["parameters/Attack/blend_amount"] = 0.0
			animTree["parameters/Death/blend_amount"] = 1.0
			pass
		CHASEPLAYER:
			AttemptToKillPlayer()
			if hpcurrent <= 0: ChangeState(DEATH)
			#if distToPlayer > chaseDistance: ChangeState(IDLE)
			target = player
			targetOrigin = target.position
			animTree.set("parameters/Walk/blend_amount", 1.0)
			ApplyGravity(grvty,delta)
			FacePlayer(delta)
			MoveToTarget(delta)
			
			jumpTimer += delta
			if jumpTimer >= jumpTimerMax and distToPlayer <= jumpDistance:
				ChangeState(JUMP)
				jumpTimer = 0
			pass
		JUMP:
			AttemptToKillPlayer()
			jumpBlend = lerp(jumpBlend,1.0,0.1)
			animTree.set("parameters/SuckOnHead/blend_amount",jumpBlend)
			var playerpos = player.global_transform.origin
			var currentpos = self.global_transform.origin
			var dir = (Vector3(playerpos.x, currentpos.y, playerpos.z) - currentpos).normalized()
			var jumpspd = 20.0 
			var jumpheight = 7
			ApplyGravity(grvty,delta)
			FacePlayer(delta)
			if is_on_floor(): self.velocity.y = jumpheight
			
			self.velocity.x = dir.x * jumpspd
			self.velocity.z = dir.z * jumpspd
			
			move_and_slide()
			
			jumpDuration += delta
			if jumpDuration > jumpDurationMax and is_on_floor():
				ChangeState(CHASEPLAYER)
			pass
		
		SUCKONHEAD:
			animTree.set("parameters/SuckOnHead/blend_amount", 1.0)
			pass
			
	pass
	
func Hurt(dmg):
	super.Hurt(dmg);
	EmitBlood();
	pass

func EmitGibs():
	#gibParticles.restart()
	bloodParticles.one_shot = true
	gibParticles.emitting = true
	bloodParticles.emitting = true
	pass

func BloodTimerDone():
	bloodParticles.emitting = false
	bloodParticles.one_shot = true	
	pass

func EmitBlood():
	bloodParticles.one_shot = true
	bloodParticles.emitting = true
	%BloodTimer.stop()
	%BloodTimer.start(bloodParticles.lifetime)	
	bloodParticles.one_shot = false
	pass

func ChangeState(newState):
	ResetAllAnims()
	state = newState

func ResetAllAnims():
	jumpBlend = 0.0
	animTree.set("parameters/Walk/blend_amount", 0.0)
	animTree.set("parameters/Attack/blend_amount", 0.0)
	animTree.set("parameters/SuckOnHead/blend_amount", 0.0)
	
func on_trigger():
	if hpcurrent <= 0: return
	ChangeState(CHASEPLAYER)
	print_debug("Trigger Success!")
