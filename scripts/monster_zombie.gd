@tool
extends Enemy
class_name Monster_Zombie

#states
var DO_ATTACK = 30
var chaseDistance = 30

var current_hb = null

## For the sake of ease, jump means SPIT for this enemy
## it spits slime at you, it does not jump at you.
var attackDistance = 4
var attackTimer = 2
var attackTimerMax = 2
var attackDuration = 0
var attackDurationMax = 1.3
var attackBlend = 0.0
@onready var animTree = %AnimationTree
@onready var bloodParticles = $GibParticles/BloodParticles
@onready var gibParticles = $GibParticles/GibParticles
var canEmit = true
var hasSpit = false

var hitbox_timer := 0.0
var hitbox_timer_max := 1.0
var hitbox_countdown := false

var growl_timer := 0.0
	

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): return
	super._ready()
	Game.DestroyOnDifficultyFlag(difficulty_spawn, self)
	
	distToPlayer = transform.origin.distance_to(player.position)
	
	state = IDLE
	grvty = 12.0
	speed = randi_range(4.5,7.5)
	%BloodTimer.timeout.connect(BloodTimerDone)  # Connect the timer signal
	
	LoadEnemy()

func _process(delta: float) -> void:
	if hitbox_countdown == false: return
	if not is_visible_in_tree(): return  # skip logic if not visible
	if stop_processing: return
	if Game.IsPaused(): return
	
	hitbox_timer += delta
	if hitbox_timer >= hitbox_timer_max:
		current_hb = CreateHitbox()
		hitbox_countdown = false
		hitbox_timer = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Engine.is_editor_hint(): return
	if not is_visible_in_tree(): return  # skip logic if not visible
	if stop_processing: return
	if Game.IsPaused(): return
	
	lag_timer += delta
	if LagTimer(delta): 
		distToPlayer = transform.origin.distance_to(player.position)
	
	if attackDuration > attackDurationMax:
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
			
			var walkamt = animTree.get("parameters/Walk/blend_amount")
			walkamt = lerp(walkamt,0.0,0.1)
			
			animTree.set("parameters/Walk/blend_amount", walkamt)
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
			
			var walkamt = animTree.get("parameters/Walk/blend_amount")
			walkamt = lerp(walkamt,1.0,0.1)
			animTree.set("parameters/Walk/blend_amount", walkamt)
			
			pass
		ATTACK:
			if distToPlayer > chaseDistance: 
				GibsStop()
				return
			
			ApplyGravity(grvty,delta)
			FacePlayer(delta)
			move_and_slide()
			
			var atkamt = animTree.get("parameters/Attack/blend_amount")
			atkamt = lerp(atkamt,1.0,0.1)
			animTree.set("parameters/Attack/blend_amount", atkamt)
			
			state = CHASEPLAYER
			
			pass
		DEATH:
			if %Breath.playing: %Breath.playing = false
			
			## Destroy our attack hitbox when the zombie dies so we cant cheeze the player out  a free shot after its already dead
			if current_hb != null:
				if current_hb.has_method("queue_free"):
					current_hb.queue_free()
			
			ApplyGravity(grvty,delta)
			
			velocity.x = 0
			velocity.z = 0
			move_and_slide()
			
			animTree["parameters/Walk/blend_amount"] = 0.0
			animTree["parameters/Attack/blend_amount"] = 0.0
			animTree["parameters/Death/blend_amount"] = 1.0
			
			
			EmitGibs()
			
			
			pass
		CHASEPLAYER:
			if distToPlayer > chaseDistance: 
				GibsStop()
				return
			if LagTimer(delta): AttemptToKillPlayer()
			if hpcurrent <= 0: ChangeState(DEATH)
			
			target = player
			targetOrigin = target.position
			var walkamt = animTree.get("parameters/Walk/blend_amount")
			walkamt = lerp(walkamt,1.0,0.1)
			animTree.set("parameters/Walk/blend_amount", walkamt)
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
				
			if LagTimer(delta): AttemptToKillPlayer()
			
			attackBlend = lerp(attackBlend,1.0,0.1)
			animTree.set("parameters/Attack/blend_amount",attackBlend)
			
			velocity.x = 0
			velocity.z = 0
			ApplyGravity(grvty,delta)
			FacePlayer(delta, false)
			move_and_slide()
			
			attackDuration += delta
			if attackDuration >= 0.6 and not hasSpit:
				hasSpit = true
				%Growl.stop()
				%Growl.play()
				var player_dir = Game.GetDirectionToPlayer(self)


func Hurt(dmg):
	if state == DEATH: return
	super.Hurt(dmg);
	EmitBlood();
	%Growl.stop()
	%Growl.play()
	
	if hpcurrent <= 0:
		ChangeState(DEATH)
		#%DrippingMouthParticles.hide()
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
	
## if we go too far and come back enemies start randomly exploding gibs
## so call this once we go too far i guess
func GibsStop():
	%BloodTimer.stop()
	bloodParticles.emitting = false
	bloodParticles.one_shot = false
	gibParticles.emitting = false

func EmitBlood():
	if bloodParticles.emitting: return
	
	bloodParticles.one_shot = true
	bloodParticles.emitting = true
	%BloodTimer.stop()
	%BloodTimer.start(bloodParticles.lifetime)	
	bloodParticles.one_shot = false
	pass

func ChangeState(newState):
	if newState == DO_ATTACK:
		hitbox_countdown = true
		
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
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:

	pass # Replace with function body.


func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:

	pass # Replace with function body.


func AttemptToKillPlayer():
	if distToPlayer > collisionRange:
		return
		
	var eyeLine = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eyeLine, player.global_position+eyeLine, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	
	## if zombie gets too close just hurt player for touching them
	if result.is_empty():
		#state = ATTACK
		player.Hurt(power)
		#should_attack = true

@onready var HitboxScene = preload("res://scenes/hitbox.tscn")
func CreateHitbox():
	var hb = HitboxScene.instantiate()
	hb.power = power
	add_child(hb)
	
	var forward = transform.basis.z.normalized()
	var offset = 2.0
	hb.global_position = global_position + forward * offset
	
	return hb


func _on_gib_particles_finished() -> void:
	stop_processing = true
	pass # Replace with function body.
