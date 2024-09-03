@tool
extends CharacterBody3D
#NODE REFS
@onready var animated_sprite_2d = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var ray_cast_3d = $Head/Camera3D/RayCast3D
@onready var sndShoot = $sndShoot
@onready var camera_3d = $Head/Camera3D
@onready var svp_camera_3d = %Subviewport_camera
@onready var head = $Head
@onready var barrel = $Head/Camera3D/Barrel

#animation trees
@onready var animPistol = $Head/Camera3D/arms_pistol/AnimationTree
@onready var animM4A1 = $Head/Camera3D/arms_m4a1/AnimationTree
@onready var animPumpShotgun = $Head/Camera3D/PumpShotgun/AnimationTree
@onready var animRevolver = $Head/Camera3D/Revolver/AnimationTree
@onready var animCrowbar = $Head/Camera3D/Crowbar/AnimationTree
@onready var animSubMachineGun = $Head/Camera3D/SubMachineGun/AnimationTree
@onready var anim_tree = animPistol

#models
@onready var modelPistol = $Head/Camera3D/arms_pistol
@onready var modelM4A1 = $Head/Camera3D/arms_m4a1
@onready var modelPumpShotgun = $Head/Camera3D/PumpShotgun
@onready var modelRevolver = $Head/Camera3D/Revolver
@onready var modelCrowbar = $Head/Camera3D/Crowbar
@onready var modelSubMachineGun = %SubMachineGun

#HUD
@onready var lblEnergy = $CanvasLayer/lblEnergy
@onready var lblAmmo = $CanvasLayer/lblAmmo
@onready var healthbar = $CanvasLayer/Health
@onready var hudKeycardRed = $CanvasLayer/Node/CardRed
@onready var hudKeycardYellow = $CanvasLayer/Node/CardYellow
@onready var hudKeycardBlue = $CanvasLayer/Node/CardBlue
@onready var hudInteract = $CanvasLayer/Interact
@onready var sBullet = $CanvasLayer/Bullet
@onready var hudAnimPlayer = $CanvasLayer/AnimationPlayer
@onready var standingRaycast = $Head/StandingRayCast
#SFX
@onready var sfxShotgun = $Audio/sfxShotgun
@onready var sfxReload = $Audio/sfxShotgunReload

## Initial Spawn Direction
@export var spawndir = "forward"
## Target Name - Default is "Player"
@export var targetname = "player"

var weaponSFX = sfxShotgun

#signals
signal UpdateHUDSignal(message)
signal HideHUDInteract

#VARIABLES
const mouseSens = 0.2
var direction = 0
var spd = { current=12, default=12, walk=7, crouch=5, swim=7, climb=7 } 
var jumpHeight = { current=10, default=10, water=5}
@export var grvty = 20
var grvtyDefault = 20
var grvtyWater = 5
var frict = { default=7.0, jump=0.0, accel=6.0 }

#crouching
var crouching = false
var crouchHeight = 1	
var crouchJumpBoost = crouchHeight * 0.9
var headpos = 0
@onready var ogCapsuleHeight = $Player.shape.height

#ladder climbing
var climbing = false
var currentLadder = null

#hurt/death
var dead = false
var isHurt = false
var hurtTimer = { current=100, maximum=100 }
var hpGoto = 0

#shooting / weapon
var canShoot = true
var reloading = false
var changingWeapon = false
var changingWeaponTimer = { current = 0, maximum = 0.2 }
var reloadTimer = { current = 0, maximum = 0.5 }
var shootTimer = 0
var shootTimerMax = 0.1
var raycastRange = 2000

#swimming
var swimming = false

#flashlight
var flashlightModel = $Head/Camera3D/Flashlight
var flashlight = false

#amimation speeds
var runVal = 0.0
var runSpd = 0.0
var shootSpd = 0.0
var shootVal = 0.0

#BOBBING
var bobFreq = 2.0
var bobAmp = 0.05
var tBob = 0
var headPosY = 0.0

#STATE MACHINE
const DEFAULT  = 0
const CLIMBING = 1
const SWIMMING = 2
const WALKING = 3
var state = DEFAULT

func _func_godot_apply_properties(props : Dictionary):
	print_debug(props)
	spawndir = props.spawndir
	targetname = props.targetname
	print_debug(spawndir)

#READY EVENT
func _ready():
	print_debug("player made")
	#_func_godot_apply_properties(func_godot_properties)
	print_debug(spawndir)
	#Get Data from Trenchbroom
	match(spawndir):
		"0":
			$Head.rotation_degrees = Vector3(0,0,0)		
		"1":
			$Head.rotation_degrees = Vector3(0,180,0)
		"2":
			$Head.rotation_degrees = Vector3(0,90,0)
		"3":
			$Head.rotation_degrees = Vector3(0,-90,0)
	
	if Engine.is_editor_hint(): return
		
	#initiate game settings
	InputMap.load_from_project_settings()	#IMPORTANT DONT REMOVE OR HELL WILL BREAK LOOSE NOT JOKING THE MOUSE WILL DISAPPEAR AND 100000 ERRORS WILL SPIT OUT IDEK WTF ITS A GODOT ERROR APPARENTLY WITH USING @TOOL
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	UpdateHUD()
	ChangeWeapon(Game.currentWeapon)
	
	#initiate head height
	headPosY = head.position.y
	SetHeadHeight(headPosY)

	

#STEP EVENT
func _process(delta): 
	if Engine.is_editor_hint(): return
	#print_debug(spawndir)
	#set camera position	
	svp_camera_3d.set_global_transform(camera_3d.get_global_transform())
	
		#game updates
	UpdateHUD()
	Exit()
	
	if dead: return
	
	#print_debug(state)
	match(state):
		DEFAULT:
			if crouching: SetSpeed(spd.crouch)
			else: SetSpeed(spd.default)
				
			Walk()
			Crouch()
			ApplyGravity(delta,grvty)
			SetJumpHeight(jumpHeight.default)
			if is_on_floor:
					if !reloading:
						runVal = lerp(runVal,0.2,0.1)
			pass
		
		CLIMBING:
			SetJumpHeight(jumpHeight.default)
			SetSpeed(spd.climb)
			ApplyGravity(delta,0)
			HandleClimbing()
			pass
		
		SWIMMING:
			SetJumpHeight(jumpHeight.water)
			SetSpeed(spd.swim)
			Walk()
			Crouch()
			ApplyGravity(delta,grvty)
			
			pass
		
		WALKING:
			SetJumpHeight(jumpHeight.default)
			Walk()
			Crouch()
			ApplyGravity(delta,grvty)
			
			if Input.is_action_just_released("run"):
				state = DEFAULT
			
			if is_on_floor:
				runVal = lerp(runVal,0.4,0.1)
				spd.current = spd.walk
			else:
				state = DEFAULT
				
			pass
	
	HandleReload()
	HandleJump()
	HandleFlashlight()
	HandleShoot()
	DamageEffect()
	AllowWeaponChange()
	HandleWeaponChange(delta)
	HandlePlayerDirection(delta)
	pass

#PHYSICS PROCESS
func _physics_process(delta):
	if Engine.is_editor_hint(): return

	_push_away_rigid_bodies()
	var lastVelocity = velocity
	move_and_slide()
	push_rigid_bodies(lastVelocity,delta)
	pass

func push_rigid_bodies(lastVelocity, delta):
	var push_force = 10
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
 		
		# ignore everything that isn't a RigidBody
		if collision.get_collider() is RigidBody3D:
			var body = collision.get_collider() as RigidBody3D
			# invert the collision normal to get the push direction
			var push_direction = -collision.get_normal()
 
			# following line will avoid pushing into a body when right on top of it
			# so the player doesnt push boxes while standing on them
			if push_direction.dot(Vector3.DOWN) > 0.99: continue
 
			var push_velocity = lastVelocity.length() * delta
			# offset from pushed body origin in global space
			var push_position = collision.get_position() - body.global_position
 
			# push the RigidBody by combining the push_force and players (previous) velocity
			body.apply_impulse(push_direction * push_velocity * push_force, push_position)
	pass

#SET SPEED
func SetSpeed(_spd):
	spd.current = _spd
	pass

#HANDLE PLAYER DIRECTION
func HandlePlayerDirection(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#if is_on_floor() || state == CLIMBING:
	if direction:
		#move player
		velocity.x = lerp(velocity.x,direction.x * spd.current, delta * frict.accel)
		velocity.z = lerp(velocity.z,direction.z * spd.current, delta * frict.accel)
	else:
		#apply regular friction
		runVal = 0.0
		velocity.x = lerp(velocity.x,direction.x*spd.current, delta * frict.default)
		velocity.z =  lerp(velocity.z,direction.z*spd.current, delta * frict.default)
	#else:
		#apply airborne friction
		#velocity.x = lerp(velocity.x,direction.x*spd.current, delta * frict.jump)
		#velocity.z = lerp(velocity.z,direction.z*spd.current, delta * frict.jump)
	#	pass
	# Head Bobbing
	tBob += delta * velocity.length() * float(is_on_floor())
	camera_3d.transform.origin = HeadBob(tBob)

#HANDLE CLIMBING
func HandleClimbing():
	#If no ladder exists, get outta here
	if currentLadder == null: return;
	
	#if Input.is_action_pressed("jump"): state = DEFAULT
	
	#vars
	var _vel = 0
	var climbSpd = 8
	
	if Input.is_action_pressed("move_forward"):
		var rot = camera_3d.rotation_degrees.x
		if rot < 45 and rot > -45:
			rot = 45
		_vel = climbSpd * (rot * 0.01)
		
	spd.current = spd.climb
	self.velocity.y = _vel
	self.velocity.z = 0
	self.velocity.x = 0

#HANDLE JUMP
func HandleJump():
		# Jump
		if Input.is_action_just_pressed("jump"):
			Jump()

#HANDLE WEAPON CHANGE
func HandleWeaponChange(delta):
	if changingWeapon:
		canShoot = false
		changingWeaponTimer.current -= delta
		if changingWeaponTimer.current <= 0:
			canShoot = true
			changingWeapon = false
			changingWeaponTimer.current = changingWeaponTimer.maximum

#HANDLE SHOOT
func HandleShoot():
	#Shoot [MOUSE LEFT]
	if Input.is_action_pressed("shoot"):
		Shoot()

#HANDLE RELOAD
func HandleReload():
	#Reload [R]
	if Input.is_action_just_pressed("Reload"):
		Reload()	

#HANDLE FLASHLIGHT
func HandleFlashlight():
	#Flashlight [F]
	if Input.is_action_just_pressed("Flashlight"):
		flashlight = !flashlight
		$Head/Camera3D/Flashlight.visible = flashlight	

#UPDATE HUD
func UpdateHUD():
	hpGoto = lerpf(hpGoto,Game.hp.current,0.1)
	lblEnergy.text = str(Game.hp.current)
	healthbar.value = hpGoto
	hudKeycardRed.visible = Game.keycard.red
	hudKeycardYellow.visible = Game.keycard.yellow
	hudKeycardBlue.visible = Game.keycard.blue
	
	
#ALLOW WEAPON CHANGE
func AllowWeaponChange():
	#Change to Weapon 1 [1]
	if Input.is_action_pressed("Weapon1"):
		ChangeWeapon(0)
	
	#Change to Weapon 2 [2]
	if Input.is_action_pressed("Weapon2"):
		ChangeWeapon(1)	
	
	#Change Weapon Up [SCROLL WHEEL UP]
	if Input.is_action_just_released("ChangeWeaponUp"):
		ChangeWeaponScroll(true)	
	
	#Change Weapon Down [SCROLL WHEEL DOWN]
	if Input.is_action_just_released("ChangeWeaponDown"):
		ChangeWeaponScroll(false)	

#INPUT
func _input(event):
	if dead:
		return
	if event is InputEventMouseMotion:
		var _event = -event.relative
		var yRotationLimit = 90
		
		head.rotate_y(deg_to_rad(_event.x * mouseSens))
		camera_3d.rotation_degrees.x += _event.y * mouseSens
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -yRotationLimit, yRotationLimit)
		
		#camera_3d.rotate_x(-event.relative.y * mouseSens)
		#camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad(90))

#SET HEAD HEIGHT
func SetHeadHeight(posY):
	#head.position.y = posY
	#$Player.shape.height = ogCapsuleHeight - crouchHeight if crouching else ogCapsuleHeight
	#$Player.position.y = $Player.shape.height/2 - 1
	pass
	
#CROUCH
func Crouch():
	return
	#Crouch [CTRL]
	var wascrouchinglastframe = crouching
	
	if Input.is_action_pressed("Crouch"):
		crouching = true
	#prevent player from getting head stuck in roofs
	elif crouching and not self.test_move(self.transform,Vector3(0,crouchHeight,0)):
		crouching = false
	
	if !crouching: return
	#Give jump boost when crouch jumping
	var translatey := 0.0
	if wascrouchinglastframe != crouching and not is_on_floor():
		#translatey = crouchJumpBoost if crouching else -crouchJumpBoost
		pass
	if translatey != 0.0:
		var result = KinematicCollision3D.new()
		self.test_move(self.transform, Vector3(0,translatey,0),result)
		#self.position.y += result.get_travel().y
		#$Head/Camera3D.position.y = result.get_travel().y
		#$Head/Camera3D.position.y = -crouchHeight
		pass
		
	if crouching:
		SetHeadHeight(headPosY - crouchHeight)
		pass
	else:
		SetHeadHeight(headPosY)
		pass
	pass

#RELOAD
func Reload():
	if canShoot == false: return
	if reloading: return
	
	for w in Game.weapons:
		if w.index == Game.currentWeapon:
			if w.clip >= Game.weaponList[Game.currentWeapon].magSize:
				return
			if w.ammo <= 0: return
	
	reloading = true
	$Audio/sfxShotgunReload.play()
	reloadTimer.current = reloadTimer.maximum
	runVal = 0.0
	runSpd = 0.0
	shootVal = 0.0
	shootSpd = 0.0
	ShootAnimDone()
	anim_tree.set("parameters/Reload/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)	
	
#RELOAD AMMO
func ReloadAmmo():
	var _magSize = Game.weaponList[Game.currentWeapon].magSize
	
	for w in Game.weapons:
		if w.index == Game.currentWeapon:
			var neededAmmo = _magSize - w.clip
			if w.ammo >= neededAmmo:
				w.ammo -= neededAmmo
				w.clip = _magSize
			else:
				w.clip += w.ammo
				w.ammo = 0
			lblAmmo.text = str(w.clip, " | ", w.ammo)
			Game.weapons[Game.currentWeapon].ammo = w.ammo
			Game.weapons[Game.currentWeapon].clip = w.clip
	
#EXIT
func Exit():
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
#RESTART
func Restart():
	pass
	#if Input.is_action_just_pressed("restart"):
		#get_tree().reload_current_scene()

#CHANGE WEAPON
func ChangeWeapon(type):
	if canShoot == false: return
	
	#set all gun models invisible
	modelPistol.visible = false
	modelM4A1.visible = false
	modelPumpShotgun.visible = false
	modelRevolver.visible = false
	modelCrowbar.visible = false
	modelSubMachineGun.visible = false
	
	canShoot = false
	changingWeapon = true
	
	anim_tree.set("parameters/Reload/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
	#set current weapon visible
	match type:
		#NO WEAPON
		0:
			anim_tree = animPistol
			pass
		#PISTOL
		1:
			anim_tree = animPistol
			modelPistol.visible = true
			pass
		#M4A1
		2:
			anim_tree = animM4A1
			modelM4A1.visible = true
			pass		
		#PUMP SHOTGUN
		3:
			anim_tree = animPumpShotgun
			modelPumpShotgun.visible = true
			pass		
		#REVOLVER
		4:
			anim_tree = animRevolver
			modelRevolver.visible = true
			pass		
		#CROWBAR
		5:
			anim_tree = animCrowbar
			modelCrowbar.visible = true
			pass		
		#SUB MACHINE GUN
		6:
			anim_tree = animSubMachineGun
			modelSubMachineGun.visible = true
			pass
					
	Game.currentWeapon = type
	
	for w in Game.weapons:
		if w.index == Game.currentWeapon:
			var isMelee = Game.weaponList[Game.currentWeapon].melee
			if isMelee:
				sBullet.visible = false
				lblAmmo.text = ""
			else:
				sBullet.visible = true
				lblAmmo.text = str(w.clip, " | ", w.ammo)
			
	#shootTimerMax = Game.weaponList[type].cooldown
	canShoot = true
	reloading = false
	pass

#PUSH AWAY RIGID BODIES
# CC0/public domain/use for whatever you want no need to credit
# Call this function directly before move_and_slide() on your CharacterBody3D script
func _push_away_rigid_bodies():
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D && is_on_floor():
			var push_dir = -c.get_normal()
			# How much velocity the object needs to increase to match player velocity in the push direction
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			# Only count velocity towards push dir, away from character
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			# Objects with more mass than us should be harder to push. But doesn't really make sense to push faster than we are going
			const MY_APPROX_MASS_KG = 300.0
			var mass_ratio = min(1., MY_APPROX_MASS_KG / c.get_collider().mass)
			# Optional add: Don't push object at all if it's 4x heavier or more
			if mass_ratio < 0.25:
				continue
			# Don't push object from above/below
			push_dir.y = 0
			# 5.0 is a magic number, adjust to your needs
			var push_force = mass_ratio
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)
			
#WEAPON CHANGE ON SCROLL WHEEL
func ChangeWeaponScroll(isUp):
	if isUp:
		Game.currentWeapon = int(Game.currentWeapon + 1) % Game.weapons.size()
	else:
		Game.currentWeapon = int(Game.currentWeapon - 1 + Game.weapons.size()) % Game.weapons.size()
	ChangeWeapon(Game.currentWeapon)
	pass

#HURT
func Hurt(dmg):
	if isHurt || Game.godmode :
		return
	print_debug("Player Hurt")
	isHurt = true
	Game.hp.current = Game.hp.current - dmg
	Game.hp.current = clamp(Game.hp.current,0,Game.hp.maximum)
	UpdateHUD()

#INCREASE HEALTH
func IncreaseHealth(amount):
	Game.hp.current = Game.hp.current + amount
	Game.hp.current = clamp(Game.hp.current,0,Game.hp.maximum)

#DAMAGE EFFECT
func DamageEffect():
	if isHurt == false:
		return
	hudAnimPlayer.play("Pain")
	pass

#KILL
func Kill():
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

#RUN
func Walk():
	
	if !reloading:
		runSpd = lerp(runSpd,runVal,0.1)
	
	if Input.is_action_pressed("run"):
		state = WALKING
	
	if !is_on_floor() || reloading:
		runVal = 0.0

#JUMP
func Jump():
	if is_on_floor() || state == SWIMMING || state == CLIMBING:
		if state == CLIMBING:
			state = DEFAULT
		velocity.y = jumpHeight.current

#SET JUMP HEIGHT
func SetJumpHeight(_jumpHeight):
	jumpHeight.current=_jumpHeight
	pass

#GRAVITY
func ApplyGravity(delta, grvty):
	
	if not is_on_floor():
		velocity.y -= grvty * delta
		if state == SWIMMING:
			velocity.y = clamp(velocity.y,-5,100)

#Get Raycast Target of Intersection
func GetRayCastTarget(target, group, hasMethod):
	if target.is_in_group(group) && target.has_method(hasMethod):
		return true
	else:
		return false

#Bullet collision
func CreateRayCast():
	if ray_cast_3d.is_colliding():
		var colPoint = ray_cast_3d.get_collision_point()
		var normal = ray_cast_3d.get_collision_normal()
		var target = ray_cast_3d.get_collider()
		if target == null: return
		print_debug(target)
		
		#Every Entity that can be interacted with must inherit from Entity and have a type defined in _ready
		if target.is_in_group("Enemy"): target.Hurt(Game.weaponList[Game.currentWeapon].power)
		if target.is_in_group("Breakable"): target.Destroy()
		#if "type" in target:
			#match(target.type):
				#"Enemy":
					#target.Hurt(Game.weaponList[Game.currentWeapon].power)
				#"Breakable":
					#target.Destroy()
		
		return target

#SHOOT
func Shoot():
	var weaponData = Game.weaponList[Game.currentWeapon]
	
	var isMelee = weaponData.melee
	for weapon in Game.weapons:
		if weapon.index == Game.currentWeapon:
			if weapon.index == 0: return
			
			if weapon.clip <= 0 && isMelee == false:
				Reload()
				return
	
	if canShoot == false || reloading || changingWeapon :
		return
		
	canShoot = false
	$Audio/sfxShotgun.play()
	CreateRayCast()
	anim_tree.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)	
	
	for weapon in Game.weapons:
		if weapon.index == Game.currentWeapon:
			
			#if weapon.clip <= 0: return
			if isMelee: 
				return
			weapon.clip -= 1
			lblAmmo.text = str(weapon.clip, " | ", weapon.ammo)
			if weapon.clip <= 0:
				Reload()
	
			#print_debug('ammo: ' , weapon.clip , ' / ' , weapon.ammo)
	
	#if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("Kill"):
	#	ray_cast_3d.get_collider().Kill()

#SHOOT ANIM DONE
func ShootAnimDone():
	canShoot = true
	shootVal = 0.0
	#shootSpd = lerp(shootSpd,shootVal,0.1)

#HEAD BOB
func HeadBob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bobFreq) * bobAmp
	pos.x = cos(time * bobFreq / 2) * bobAmp
	return pos
	
#UPDATE HUD
func _on_update_hud_signal(message):
	hudInteract.text = message
	hudInteract.visible = true
	#print("update hud")
	pass # Replace with function body.

#HIDE HUD INTERACT 
func _on_hide_hud_interact():
	hudInteract.visible = false
	#hudInteract.text = ""
	pass # Replace with function body.

#ANIM CHANGED
func _on_animation_player_animation_changed(old_name, new_name):
	ShootAnimDone()
	#anim_tree.set("parameters/TimeSeek/seek_request", 0.0)
	pass # Replace with function body.

#ANIM FINISHED
func _on_animation_player_animation_finished(anim_name):
	#print_debug("sasdasadasdad")
	#print_debug(anim_name)
	
	#Damage Pain HUD Flash Finished
	if anim_name == "Pain":
		isHurt = false
		return
	
	#Finished Shooting
	if (anim_name == "Armature|Shoot_001" ||
		anim_name == "Armature|Shoot" ||
		anim_name == "Shoot"):
		ShootAnimDone()
		return
		
	#Finished Reloading
	if (anim_name == "Armature|Reload_001" ||
		anim_name == "Armature|Reload" ||
		anim_name == "Reload"):
		reloading = false
		ReloadAmmo()
		ShootAnimDone()
		return
	
	pass # Replace with function body.

#ON COLLISION ENTERED CHECKS
func onAreaEntered(area):
	#print_debug(area.name)
	
	#WATER
	if area.is_in_group("Water"):
		#print_debug("swim")
		grvty = grvtyWater
		state = SWIMMING
	
	#LADDER
	if area.is_in_group("Ladder"):
		state = CLIMBING
		currentLadder = area
		
	pass # Replace with function body.

#ON COLLISION EXITED CHECKS
func onAreaExited(area):
	#WATER
	if area.is_in_group("Water"):
		state = DEFAULT
		grvty = grvtyDefault
	
	#LADDER
	if area.is_in_group("Ladder"):
		state = DEFAULT
		currentLadder = null
	pass # Replace with function body.

