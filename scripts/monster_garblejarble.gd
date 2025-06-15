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
var attackDurationMax = 1.3
var attackBlend = 0.0
@onready var animTree = $AnimationTree
@onready var bloodParticles = $GibParticles/BloodParticles
@onready var gibParticles = $GibParticles/GibParticles
var canEmit = true
var hasSpit = false

var growl_timer := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): return
	super._ready()
	Game.DestroyOnDifficultyFlag(difficulty_spawn, self)
	distToPlayer = transform.origin.distance_to(player.position)
	state = IDLE
	grvty = 12.0
	speed = 10.0
	%BloodTimer.timeout.connect(BloodTimerDone)  # Connect the timer signal
	LoadEnemy()
	pass # Replace with function body.

## if we go too far and come back enemies start randomly exploding gibs
## so call this once we go too far i guess
func GibsStop():
	%BloodTimer.stop()
	bloodParticles.emitting = false
	bloodParticles.one_shot = false
	gibParticles.emitting = false
	bloodParticles.emitting = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Engine.is_editor_hint(): return
	if not is_visible_in_tree(): return  # skip logic if not visible
	if stop_processing: return
	if Game.IsPaused(): return
	
	#if Input.is_action_just_pressed("num1"): ChangeState(IDLE)
	#if Input.is_action_just_pressed("num2"): ChangeState(WALK)
	#if Input.is_action_just_pressed("num3"): ChangeState(ATTACK)
	#if Input.is_action_just_pressed("num4"): ChangeState(SUCKONHEAD)
	
	lag_timer += delta
	if LagTimer(delta): distToPlayer = transform.origin.distance_to(player.position)
	
	if attackDuration > attackDurationMax and distToPlayer <= chaseDistance:
		hasSpit = false
		attackDuration = 0.0
		ChangeState(CHASEPLAYER)
	
	match(state):
		IDLE:
			if distToPlayer > chaseDistance: 
				GibsStop()
				return
		
			if not is_on_floor(): velocity.y -= grvty * delta
			move_and_slide()
			animTree.set("parameters/Walk/blend_amount", 0.0)
			if distToPlayer <= chaseDistance && shouldChase:
				ChangeState(CHASEPLAYER)
			pass
		WALK:
			if distToPlayer > chaseDistance: 
				GibsStop()
				return
			ApplyGravity(grvty,delta)
			FacePlayer(delta)
			move_and_slide()
			animTree.set("parameters/Walk/blend_amount", 1.0)
			pass
		ATTACK:
			if distToPlayer > chaseDistance: 
				GibsStop()
				return
			state = CHASEPLAYER
			ApplyGravity(grvty,delta)
			FacePlayer(delta)
			
			move_and_slide()
			animTree.set("parameters/Attack/blend_amount", 1.0)
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
			if distToPlayer > chaseDistance: 
				GibsStop()
				return
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
			if distToPlayer > chaseDistance: 
				GibsStop()
				return
			AttemptToKillPlayer()
			attackBlend = lerp(attackBlend,1.0,0.1)
			animTree.set("parameters/Attack/blend_amount",attackBlend)
			
			velocity.x = 0
			velocity.z = 0
			ApplyGravity(grvty,delta)
			FacePlayer(delta)
			move_and_slide()
			
			attackDuration += delta
			
			#print(attackDuration)
			
			if attackDuration >= 0.6 and not hasSpit:
				hasSpit = true
				%Growl.stop()
				%Growl.play()
				
				#print("SPIT GOOP AT CHU!")
				var player_dir = Game.GetDirectionToPlayer(self)
				
				#@export var power : int = 20
#@export var speed: float = 15.0
#@export var spin_speed : float = 10.0
#@export var destroy_distance: float = 1000.0
				var _padding = 0.1
				var projspd  = 30.0
				var _projtype = Defs.PROJECTILE_TYPE.SLIME
				var _pos1 = player_dir + Vector3(-_padding, 0, -_padding)
				var _pos2 = player_dir + Vector3(_padding, 0, _padding)
				Signals.SpawnProjectile.emit(self, _pos1, _projtype, power, projspd)
				Signals.SpawnProjectile.emit(self, player_dir, _projtype, power, projspd)
				Signals.SpawnProjectile.emit(self, _pos2, _projtype, power, projspd)
			pass
			
	pass
	
func Hurt(dmg):
	super.Hurt(dmg);
	EmitBlood();
	%Growl.stop()
	%Growl.play()
	
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
	#bloodParticles.one_shot = true	
	%BloodTimer.stop()
	bloodParticles.emitting = false
	pass

func EmitBlood():
	if bloodParticles.emitting: return
	
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
	%Growl.stop()
	%Growl.play()
	ChangeState(CHASEPLAYER)
	#print_debug("Trigger Success!")
	
func Kill():
	super.Kill()


func _on_gib_particles_finished() -> void:
	stop_processing = true
	pass # Replace with function body.
