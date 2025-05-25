@tool
extends Enemy
class_name Monster_GarbleJarble

#states
var DO_ATTACK = 30
var chaseDistance = 30

## For the sake of ease, jump means SPIT for this enemy
## it spits slime at you, it does not jump at you.
var attackDistance = 20
var attackTimer = 2
var attackTimerMax = 2
var attackDuration = 0
var attackDurationMax = 1.2917
var attackBlend = 0.0
@onready var animTree = $AnimationTree
@onready var bloodParticles = $GibParticles/BloodParticles
@onready var gibParticles = $GibParticles/GibParticles
var canEmit = true
var hasSpit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): return
	state = IDLE
	grvty = 12.0
	speed = 5.0
	%BloodTimer.timeout.connect(BloodTimerDone)  # Connect the timer signal
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Engine.is_editor_hint(): return
	#if Input.is_action_just_pressed("num1"): ChangeState(IDLE)
	#if Input.is_action_just_pressed("num2"): ChangeState(WALK)
	#if Input.is_action_just_pressed("num3"): ChangeState(ATTACK)
	#if Input.is_action_just_pressed("num4"): ChangeState(SUCKONHEAD)
	
	distToPlayer = transform.origin.distance_to(player.position)
	
	if attackDuration > attackDurationMax:
		hasSpit = false
		attackDuration = 0.0
		ChangeState(CHASEPLAYER)
	
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
			
			attackTimer += delta
			if attackTimer >= attackTimerMax and distToPlayer <= attackDistance:
				ChangeState(DO_ATTACK)
				attackTimer = 0
				
			pass
		DO_ATTACK:
			AttemptToKillPlayer()
			attackBlend = lerp(attackBlend,1.0,0.1)
			animTree.set("parameters/Attack/blend_amount",attackBlend)
			
			ApplyGravity(grvty,delta)
			FacePlayer(delta)
			
			attackDuration += delta
			
			print(attackDuration)
			
			if attackDuration >= 0.6 and not hasSpit:
				hasSpit = true
				print("SPIT GOOP AT CHU!")
				var player_dir = Game.GetDirectionToPlayer(self)
				
				var _padding = 0.1
				#Signals.SpawnProjectile.emit(self, player_dir + Vector3(-_padding, 0, -_padding))
				Signals.SpawnProjectile.emit(self, player_dir)
				#Signals.SpawnProjectile.emit(self, player_dir + Vector3(_padding, 0, _padding))
			
			
			pass
			
	pass
	
func Hurt(dmg):
	super.Hurt(dmg);
	EmitBlood();
	
	if hpcurrent <= 0:
		%DrippingMouthParticles.hide()
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
	attackBlend = 0.0
	animTree.set("parameters/Walk/blend_amount", 0.0)
	animTree.set("parameters/Attack/blend_amount", 0.0)
	
func on_trigger():
	if hpcurrent <= 0: return
	ChangeState(CHASEPLAYER)
	print_debug("Trigger Success!")
	
func Kill():
	super.Kill()
