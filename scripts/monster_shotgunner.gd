@tool
extends Enemy
class_name Monster_Shotgunner
@onready var ShotgunPickupScene = preload("res://scenes/pickups/weapon_shotgun2.tscn")
@onready var ShotgunnerHeadScene = preload("res://scenes/shotgunner_head.tscn")
@onready var ShotgunnerBrainScene = preload("res://scenes/brain.tscn")
@onready var ProjectileScene = preload("res://scenes/projectile.tscn")

#states
var DO_ATTACK = 30
var WALK_TO_TARGET = 40
var HURT = 50
var AFTER_HURT = 60
var AFTER_DEATH = 70
var AFTER_SHOOT = 80

var random_direction_to_run_after_shooting = Vector2(randf_range(-speed,speed),randf_range(-speed,speed))
var thing_todo_after_running_in_the_random_direction_like_a_dumbass = DO_ATTACK

var chaseDistance = 50
var current_hb = null

## For the sake of ease, jump means SPIT for this enemy
## it spits slime at you, it does not jump at you.
var attackDistance = 50
var attackTimer = 0
var attackTimerMax = 0.5 ## How long the enemy should chase you
var attackDuration = 0
var attackDurationMax = 1.6667 ## how long the attack animation lasts
var attackBlend = 0.0
@onready var animTree = %AnimationTree
@onready var bloodParticles = $GibParticles/BloodParticles
@onready var gibParticles = $GibParticles/GibParticles
var canEmit = true
var hasSpit = false

var hitbox_timer := 0.0
var hitbox_timer_max := 0.25
var hitbox_countdown := false

var growl_timer := 0.0
var loaded = false
var headshot = false
var headchopoff = false
var hurt_timer := 0.0
var hurt_timer_max := 0.8 ## stun the enemy for this amount of seconds when shot
var after_shoot_timer = 0.0
var after_shoot_timer_max = 0.5

func HeadChopOff(brain=false):
	var head = null
	if brain == true:
		head = ShotgunnerBrainScene.instantiate()
	else:
		head = ShotgunnerHeadScene.instantiate()
	
	# Set position above enemy
	head.global_transform.origin = global_position + Vector3(0, 1.5, 0)
	
	# Apply realistic launch force
	var forward = -global_transform.basis.z.normalized()
	var random = Vector3(randf() - 0.5, 0, randf() - 0.5).normalized()
	head.linear_velocity = random * 1.5 + Vector3.UP * 3 + random * 1.5
	
	# Add spin
	head.angular_velocity = Vector3(randf(), randf(), randf()) * 6

	# Add to world
	get_parent().add_child(head)

func DropWeaponPickup():
	var pickup = ShotgunPickupScene.instantiate()
	pickup.AmmoAmount = 10
	# Set position above enemy
	pickup.global_transform.origin = global_position + Vector3(0, 1.5, 0)
	
	# Apply realistic launch force
	var forward = -global_transform.basis.z.normalized()
	var random = Vector3(randf() - 0.5, 0, randf() - 0.5).normalized()
	pickup.linear_velocity = random * 1.5 + Vector3.UP * 3 + random * 1.5
	
	# Add spin
	pickup.angular_velocity = Vector3(randf(), randf(), randf()) * 6

	# Add to world
	get_parent().add_child(pickup)
	

func _func_godot_apply_properties(props:Dictionary):
	super._func_godot_apply_properties(props)

	print("shotgunner targetname: " + str(targetname))
	print("shotgunner target: " + str(target))
	print("shotgunner monstergroup: " + str(monster_group))
	
	
	if Game.map_build == Game.MAP_BUILD.PREBUILD: return
	ready()

# Called when the node enters the scene tree for the first time.
func _ready():
	if Game.map_build == Game.MAP_BUILD.RUNTIME: return
	ready()
	
func MapGenerated(): loaded = true
	
func ready():
	if Engine.is_editor_hint(): return
	
	Signals.MapGenerated.connect(MapGenerated)
	super._ready()
	Game.DestroyOnDifficultyFlag(difficulty_spawn, self)
	
	distToPlayer = transform.origin.distance_to(player.position)
	
	GetTargetWalkPointOrigin() ## get our initial walkpoint target pos, if any
	
	%BloodTimer.timeout.connect(BloodTimerDone)  # Connect the timer signal
	LoadEnemy()
	
	grvty = 12.0
	speed = 1.8
	ChangeState(WALK_TO_TARGET)

func CreateAttack(delta):
	%Shotgun.play()
	var player_dir = Game.GetDirectionToPlayer(self)
	var _padding = 0.0
	var projspd  = 30.0
	var _projtype = Defs.PROJECTILE_TYPE.BULLET
	var _pos1 = player_dir + Vector3(-_padding, 0, -_padding)
	var _pos2 = player_dir + Vector3(_padding, 0, _padding)
	Signals.SpawnProjectile.emit(self, _pos1, _projtype, power, projspd)
		
	
		

func onAreaEntered(area):
	#if area.is_in_group("WalkPoint"):
		#self.state = WALK
	GetTarget(area)


## Animation Blenders -- Smooth animation transitions dude
func WalkBlend():
	var amt = animTree.get("parameters/Walk/blend_amount")
	amt = lerp(amt,1.0,0.1)
	animTree.set("parameters/Walk/blend_amount", amt)
	
func RunBlend():
	print("Run Blend")
	var amt = animTree.get("parameters/Run/blend_amount")
	amt = lerp(amt,1.0,0.1)
	animTree.set("parameters/Run/blend_amount", amt)
	
func IdleBlend():
	var amt = animTree.get("parameters/Walk/blend_amount")
	amt = lerp(amt,0.0,0.1)
	animTree.set("parameters/Walk/blend_amount", amt)
	
func AttackBlend():
	var amt = animTree.get("parameters/Shoot/blend_amount")
	amt = lerp(amt,1.0,0.1)
	animTree.set("parameters/Shoot/blend_amount", amt)

var rnd_anim = randi_range(0,2)
func DeathBlend():
	%monster_shotgunner.get_node("Armature/Skeleton3D/weapon_01").visible = false
	%monster_shotgunner.get_node("Armature/Skeleton3D/weapon_02").visible = false
	
	
	ResetAllAnims()
	var anim = "Death1"

	if headshot == false:
		## Default kill
		match(rnd_anim):
			## Choose a random animation
			0: anim = "Death1"
			1: anim = "Death2"
			2: anim = "Death3"
			#3: anim = "Death4" ## this animation is for headshots only
	else: 
		## It was a headshot ohhh yeah
		anim = "Death4"
		## hide all the head stuff 
		%monster_shotgunner.get_node("Armature/Skeleton3D/head_2/head_2").visible = false
		%monster_shotgunner.get_node("Armature/Skeleton3D/head_2/OmniLight3D").visible = false
		%monster_shotgunner.get_node("Armature/Skeleton3D/head_2/OmniLight3D2").visible = false
		
		
	animTree["parameters/" + str(anim) + "/blend_amount"] = 1.0

enum TALK_TYPE {
	IDLE,
	ALERT,
	
}
var current_talk_type := TALK_TYPE.IDLE
var talk_timer := 0.0
var last_vocal = null
@onready var talk_timer_max := randf_range(5,10)
func RandomlyTalk(delta):
	
	talk_timer += delta
	var can_talk = false
	if talk_timer >= talk_timer_max:
		talk_timer = 0;
		talk_timer_max = randf_range(5,20)
		can_talk = true
		
	if can_talk == false: return
	
	match(current_talk_type):
		TALK_TYPE.IDLE:
			var rnd1 = 0
			var rnd2 = 2
			var rndi = randi_range(rnd1,rnd2)
			var i = 0
			#while(rndi == last_vocal and i < 3):
			#	rndi = randi_range(rnd1,rnd2)
			#	i += 1
				
			match(rndi):
				0: SetVocal(%HoldThePerimeter, 0)
				1: SetVocal(%ScanningForTarget, 1)
				2: SetVocal(%StayAlert, 2)
				
	can_talk = false
	
func SetVocal(node, index):
	node.play()
	last_vocal = index

@onready var animplayer : AnimationPlayer = %monster_shotgunner.get_node("AnimationPlayer")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Engine.is_editor_hint(): return
	if not is_visible_in_tree(): return  # skip logic if not visible
	if stop_processing: return
	if Game.IsPaused(): return
	
	lag_timer += delta
	if LagTimer(delta): 
		distToPlayer = transform.origin.distance_to(player.position)
	
	match(state):
		WALK_TO_TARGET:
			MoveToTarget(delta)
			ApplyGravity(grvty,delta)
			
			RandomlyTalk(delta)
			
			move_and_slide()
			WalkBlend()
		
		IDLE:
			if distToPlayer > chaseDistance: 
				GibsStop()
				return
			if not is_on_floor(): velocity.y -= grvty * delta
			move_and_slide()
			
			IdleBlend()
			
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
			WalkBlend()
			
			pass
		ATTACK:
			if distToPlayer > chaseDistance: 
				GibsStop()
				return
			
			ApplyGravity(grvty,delta)
			FacePlayer(delta)
			move_and_slide()
			AttackBlend()
			ChangeState(CHASEPLAYER)
			
			
			pass
		DEATH:
			var head_col = get_node_or_null("HeadHitboxArea")
			if head_col != null: head_col.queue_free()
			
			if headshot:
				%HeadshotParts.emitting = true
				$HeadExplosion.play()
			
			if headshot and not headchopoff: HeadChopOff(true) ## create a brain
			elif headshot and headchopoff: HeadChopOff() ## chop off the entire enemies head
			
			DropWeaponPickup()
			ChangeState(AFTER_DEATH)
		AFTER_SHOOT:
			print("=== AFTER SHOOT ===")
			ApplyGravity(grvty, delta)
			velocity.x = int(random_direction_to_run_after_shooting.x)
			velocity.z = int(random_direction_to_run_after_shooting.y)
			
			var is_shooting = animTree.get("parameters/Shoot/active")
			if is_shooting: 
				print("IS shooting")
				velocity.x = 0
				velocity.z = 0
				
			print("After shoot moveandslide")
			move_and_slide()
			RunBlend()
			# Make character face movement direction
			var vx = velocity.x
			var vz = velocity.z

			#print("Validating the rotation of the enemy")
			if is_finite(vx) and is_finite(vz):
				var horizontal_velocity = Vector3(vx, 0, vz)
				if horizontal_velocity.length() > 0.1:
					var target_rotation = atan2(vx, vz)
					if is_finite(target_rotation):
						rotation.y = lerp_angle(rotation.y, target_rotation, delta * 8.0)
			
			#print("rotation validated")

			after_shoot_timer += delta
			#print("seeing after shoot timer")
			if after_shoot_timer >= after_shoot_timer_max:
				#print("after shoot timer was greater than after shoot timer max")
				after_shoot_timer = 0
				var rndi = randi_range(0,1)
				match(rndi):
					0: thing_todo_after_running_in_the_random_direction_like_a_dumbass = DO_ATTACK
					1: thing_todo_after_running_in_the_random_direction_like_a_dumbass = CHASEPLAYER
					#2: thing_todo_after_running_in_the_random_direction_like_a_dumbass = AFTER_SHOOT
				
				#print("calculating random direction...")
				#thing_todo_after_running_in_the_random_direction_like_a_dumbass = CHASEPLAYER
				var s = clamp(speed, 0.01, 100.0)
				random_direction_to_run_after_shooting = Vector2(randf_range(-s, s), randf_range(-s, s))
				
				#print("Got some random direction")
				
				if thing_todo_after_running_in_the_random_direction_like_a_dumbass == state: return
				#print("thing todo wasnt our state")
				ChangeState(thing_todo_after_running_in_the_random_direction_like_a_dumbass)
			
			
		AFTER_DEATH:
			if %Breath.playing: %Breath.playing = false
			
			## Destroy our attack hitbox when the zombie dies so we cant cheeze the player out  a free shot after its already dead
			if current_hb != null:
				if current_hb.has_method("queue_free"):
					current_hb.queue_free()
			
			ApplyGravity(grvty,delta)
			
			velocity.x = 0
			velocity.z = 0
			DeathBlend()
			
			EmitGibs()
			ApplyGravity(grvty,delta)
			move_and_slide()
			
			
			pass
		CHASEPLAYER:
			#print("=== CHASE PLAYER ===")
			speed = 5.0
			if distToPlayer > chaseDistance: 
				GibsStop()
				return
			if LagTimer(delta): AttemptToKillPlayer()
			if hpcurrent <= 0: ChangeState(DEATH)
			
			target = player
			targetOrigin = target.position
			
			RunBlend()
			ApplyGravity(grvty,delta)
			FacePlayer(delta)
			
			var is_shooting = animTree.get("parameters/Shoot/active")
			if is_shooting == false:
				MoveToTarget(delta)

			
			attackTimer += delta
			if attackTimer >= attackTimerMax:# and distToPlayer <= attackDistance:
				ResetAllAnims()
				ChangeState(DO_ATTACK)
				attackTimer = 0
				#print("End Of HURT")
			move_and_slide()
			#print("Moved and slided")
			
				
			pass
		HURT:
			velocity.z = 0
			velocity.x = 0
			
			if hurt_timer <= 0.0:
				var rnd = randi_range(0,1)
				var anim_name = "Hurt1"
				match(rnd):
					0: anim_name = "Hurt1"
					1: anim_name = "Hurt2"
					
				animTree.set("parameters/" + str(anim_name) + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			
			ChangeState(AFTER_HURT)
		AFTER_HURT:
			hurt_timer += delta
			if hurt_timer >= hurt_timer_max:
				hurt_timer = 0.0
				ChangeState(CHASEPLAYER)
			
		DO_ATTACK:
			#print("DO ATTACK")
			if distToPlayer > chaseDistance: 
				GibsStop()
				return
				
			if LagTimer(delta): AttemptToKillPlayer()
		
			ApplyGravity(grvty,delta)
			FacePlayer(delta, false)
			velocity.x = 0
			velocity.z = 0
			#print("Do attack - moveandslide")
			move_and_slide()
			
			if hitbox_countdown:
				hitbox_timer += delta
				if hitbox_timer >= hitbox_timer_max:
					CreateAttack(delta)
					hitbox_timer = 0.0
					hitbox_countdown = false
			
			attackDuration += delta
				#print("anim pos: " + str(attackDuration))
			if attackDuration >= 1.6:
				#print("Attack duration reached 1.6")
				hasSpit = false
				attackDuration = 0.0
				var s = clamp(speed, 0.01, 100.0)
				random_direction_to_run_after_shooting = Vector2(randf_range(-s, s), randf_range(-s, s))
				print("Got random dir to run")
				var rndi = randi_range(0,0)
				
				match(rndi):
					0: thing_todo_after_running_in_the_random_direction_like_a_dumbass = DO_ATTACK
					1: thing_todo_after_running_in_the_random_direction_like_a_dumbass = AFTER_SHOOT
					#0: thing_todo_after_running_in_the_random_direction_like_a_dumbass = CHASEPLAYER
				
				thing_todo_after_running_in_the_random_direction_like_a_dumbass = CHASEPLAYER
				#print("Set state after running around to CHASE PLAYER")
				#print("Changing state to after shoot")
				ChangeState(AFTER_SHOOT)
			#if attackDuration >= 0.6 and not hasSpit:
				#hasSpit = true
				#%Growl.stop()
				#%Growl.play()
				#var player_dir = Game.GetDirectionToPlayer(self)


func Hurt(dmg):
	if state == DEATH: return
	
	#if headshot: dmg = dmg * 2
	super.Hurt(dmg);
	$ShootImpact.play()
	Signals.HitmarkerDisplay.emit()
	
	ChangeState(HURT)
	AlertMonsterGroup()
	
	EmitBlood();
	
	var rnd_hurt_i = randi_range(1,4)
	match(rnd_hurt_i):
		1: %SoldierHurt1.play()
		2: %SoldierHurt2.play()
		3: %SoldierHurt3.play()
		4: %SoldierHurt4.play()
	
	
	if hpcurrent <= 0:
		ChangeState(DEATH)
		return
		#%DrippingMouthParticles.hide()
		
	headshot = false
	headchopoff = false
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

var last_state = IDLE
func ChangeState(newState):
	print("Changing state to: " + str(newState))
	if last_state == newState: return
	last_state = newState
	
	attackTimer = 0.0
	attackDuration = 0.0
	after_shoot_timer = 0.0
	attackTimerMax = randf_range(0.5,2.0)
	after_shoot_timer_max = randf_range(0.5,2.0)
	
	if newState == DO_ATTACK:
		animTree.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		hitbox_countdown = true
		

		
	#ResetAllAnims()
	state = newState
	$monster_shotgunner/AnimationPlayer.seek(0,0,true)
	print("State Changed")


func ResetAllAnims():
	attackBlend = 0.0
	animTree.set("parameters/Walk/blend_amount", 0.0)
	animTree.set("parameters/Shoot/blend_amount", 0.0)
	animTree.set("parameters/Run/blend_amount", 0.0)
	animTree.set("parameters/Death1/blend_amount", 0.0)
	animTree.set("parameters/Death2/blend_amount", 0.0)
	animTree.set("parameters/Death3/blend_amount", 0.0)
	animTree.set("parameters/Death4/blend_amount", 0.0)
	animTree.set("parameters/Hurt1/blend_amount", 0.0)
	animTree.set("parameters/Hurt2/blend_amount", 0.0)
	animTree.set("parameters/Reload/blend_amount", 0.0)
	animTree.set("parameters/Crouch/blend_amount", 0.0)
	print("Reset All Anims")
	
func on_trigger():
	if hpcurrent <= 0: return
	%Growl.stop()
	%Growl.play()
	ChangeState(CHASEPLAYER)
	#AlertMonsterGroup()

var alerted = false
func AlertMonsterGroup():
	if alerted: return
	alerted = true
	
	for monster in get_tree().get_nodes_in_group("Enemy"):
		print(str("MONSTER: " + str(monster)))
		if monster.name == name: continue
		
		if "monster_group" in monster:
			if monster.monster_group == monster_group:
				monster.ChangeState(CHASEPLAYER)
	
	#print_debug("Trigger Success!")
	
func Kill():
	super.Kill()
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:

	pass # Replace with function body.


func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:

	pass # Replace with function body.


func AttemptToKillPlayer():
	print("Attempting to kill player...")
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
	print("Attempted to kill player")

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
