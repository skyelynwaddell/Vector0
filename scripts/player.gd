@tool
extends CharacterBody3D
#NODE REFS
@onready var ray_cast_3d = %RayCast3D
@onready var camera_3d = %Camera3D
@onready var svp_camera_3d = %Subviewport_camera
@onready var head = %Head
@onready var barrel = %Barrel
@onready var ogCapsuleHeight = %Player.shape.height

#animation trees
@onready var animPistol = %arms_pistol/AnimationTree
@onready var animCarbine = %arms_carbine/AnimationTree
@onready var animPumpShotgun = %PumpShotgun/AnimationTree
@onready var animRevolver = %Revolver/AnimationTree
@onready var animSubMachineGun = %SubMachineGun/AnimationTree
@onready var animCrowbar = %Crowbar/AnimationTree
@onready var animKnife = %Knife/AnimationTree
@onready var animMP = %MP/AnimationTree
@onready var anim_tree = animPistol

#models
@onready var modelPistol = %arms_pistol
@onready var modelCarbine = %arms_carbine 
@onready var modelPumpShotgun = %PumpShotgun
@onready var modelRevolver = %Revolver
@onready var modelSubMachineGun = %SubMachineGun
@onready var modelCrowbar = %Crowbar
@onready var modelKnife = %Knife
@onready var modelMP = %MP

#HUD
@onready var lblAmmo = %lblAmmo
@onready var healthbar = %Health
@onready var lblHealth = %lblHealth
@onready var hudKeycardRed = %CardRed
@onready var hudKeycardYellow = %CardYellow
@onready var hudKeycardBlue = %CardBlue
@onready var hudInteract = %Interact
@onready var sBullet = %Bullet
@onready var hudAnimPlayer = %AnimationPlayer

#SFX
@onready var sfxShotgun = %sfxShotgun
@onready var sfxReload = %sfxShotgunReload
@onready var sfxInteractNowork = %sfxInteractNowork
@onready var sfxInteractSwitch = %sfxInteractSwitch
@onready var sfxWhip1 = %sfxWhip1
@onready var sfxWhip2 = %sfxWhip2
@onready var currentSFX = sfxInteractNowork
@onready var weaponSFX = sfxShotgun

#Decals
@onready var decalBulletHole = preload("res://scenes/decals/decal_bullethole.tscn")

#signals
signal UpdateHUDSignal

@export_group("Properties")
## Target Name - Default is "Player"
@export var targetname : String = "player"
## Initial Spawn Direction
@export var spawndir : String = "forward"
## Mouse Sensitivity
@export_range(0,1) var mouseSens : float = 0.2

@export_group("Weapon Properties")
## Gun Bullet Distance
@export var bulletDistance : float = 2000.0
@export var meleeDistance : float = 1.5

@export_group("Speed")
## Default Movement Speed
@export_range(0,50) var spdDefault : float = 10.0
## Walking Speed
@export_range(0,50) var spdWalk : float = 8.0
## Crouching Speed
@export_range(0,50) var spdCrouch : float = 5.0
## Swimming Speed
@export_range(0,50) var spdSwim : float = 10.0
## Climb Speed
@export_range(0,50) var spdClimb : float = 10.0
@onready var spd = 12.0


@export_group("Jump Height")
## Default Jump Height
@export_range(0,50) var jumpHeightDefault : int = 8
## Water Jump Height
@export_range(0,50) var jumpHeightWater : int = 5
var jumpHeight = 8

@export_group("Gravity")
## Default Gravity
@export_range(0,50) var grvtyDefault : float = 20.0
## Water Gravity
@export_range(0,50) var grvtyWater : float = 5.0
var grvty = 20.0

@export_group("Friction")
## Default Friction
@export_range(0,50) var frictDefault : float = 7.0 
## Jumping Friction
@export_range(0,50) var frictJump : float = 0.0
## Acceleration Friction
@export_range(0,50) var frictAccel : float = 6.0

#crouching
@export_group("Crouch")
## Crouch Height
@export_range(0,5) var crouchHeight : float = 1.55
## Crouch Jump Boost
@export_range(0,2) var crouchJumpBoost : float = 0.7
var crouchJumpFinal = crouchHeight * crouchJumpBoost
var crouching = false

#decals
@export_group("Decals")
## Maximum Amount of decals that can be placed in the room
@export_range(0,100) var decalsMax : int = 20
var decals : Array = []

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
var currentMeleeAnim = 0

#swimming
var swimming = false

#flashlight
#var flashlightModel = %Flashlight
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
var direction = 0

#Load player data from mapping software
func _func_godot_apply_properties(props : Dictionary):
	spawndir = props.spawndir
	targetname = props.targetname
	pass

#READY EVENT
func _ready():
	# Make player face the spawn direction
	match(spawndir):
		"0":
			%Head.rotation_degrees = Vector3(0,0,0)		
		"1":
			%Head.rotation_degrees = Vector3(0,180,0)
		"2":
			%Head.rotation_degrees = Vector3(0,90,0)
		"3":
			%Head.rotation_degrees = Vector3(0,-90,0)
	
	if Engine.is_editor_hint(): return
		
	#initiate game settings
	InputMap.load_from_project_settings()	#IMPORTANT DONT REMOVE OR HELL WILL BREAK LOOSE NOT JOKING THE MOUSE WILL DISAPPEAR AND 100000 ERRORS WILL SPIT OUT IDEK WTF ITS A GODOT ERROR APPARENTLY WITH USING @TOOL
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	UpdateHUD()
	ChangeWeapon(Game.currentWeapon)
	
	#initiate head height
	headPosY = head.position.y
	SetHeadHeight(headPosY)
	pass

#STEP EVENT
func _process(delta): 
	if Engine.is_editor_hint(): return
	#set camera position	
	svp_camera_3d.set_global_transform(camera_3d.get_global_transform())
	
	#game updates
	Exit() ## exit game function
	if dead: return
	
	# Interact sound effect
	if Input.is_action_just_pressed("Interact"): currentSFX.play()
	
	# State specific functionality
	match(state):
		DEFAULT:
			HandleSpeed()
			Walk()
			ApplyGravity(delta,grvty)
			SetJumpHeight(jumpHeightDefault)
			StateDefault()
			pass
		
		CLIMBING:
			SetJumpHeight(jumpHeightDefault)
			SetSpeed(spdClimb)
			ApplyGravity(delta,0)
			HandleClimbing()
			pass
		
		SWIMMING:
			SetJumpHeight(jumpHeightWater)
			SetSpeed(spdSwim)
			Walk()
			ApplyGravity(delta,grvty)
			pass
		
		WALKING:
			HandleSpeed()
			SetJumpHeight(jumpHeightDefault)
			Walk()
			ApplyGravity(delta,grvty)
			StateWalking()
			pass
	
	# Functions allowed for all states
	HandleReload()
	HandleJump()
	HandleFlashlight()
	HandleShoot()
	DamageEffect()
	AllowWeaponChange()
	HandleWeaponChange(delta)
	HandlePlayerDirection(delta)
	ChangeCrosshair()
	pass

#PHYSICS PROCESS
func _physics_process(delta):
	if Engine.is_editor_hint(): return
	var lastVelocity = velocity

	push_rigid_bodies(lastVelocity,delta)
	
	HandleCrouch(delta)
	move_and_slide()
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
	
func StateDefault():
	if is_on_floor:
		if !reloading:
			runVal = lerp(runVal,0.2,0.1)
	pass

func StateWalking():
	if Input.is_action_just_released("run"):
		state = DEFAULT
			
	if is_on_floor:
		runVal = lerp(runVal,0.4,0.1)
	else:
		state = DEFAULT
	pass

func HandleSpeed():
	if crouching && is_on_floor(): SetSpeed(spdCrouch)
	else: SetSpeed(spdDefault)
	pass

#SET SPEED
func SetSpeed(_spd):
	self.spd = _spd
	pass

#HANDLE PLAYER DIRECTION
func HandlePlayerDirection(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized()
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	
	# Check if the player is on the floor
	if is_on_floor():
		# Ground movement: accelerate towards the desired direction
		if direction != Vector3.ZERO:
			# Apply movement direction
			velocity.x = lerp(velocity.x, direction.x * spd, delta * frictAccel)
			velocity.z = lerp(velocity.z, direction.z * spd, delta * frictAccel)
		else:
			# Apply friction when not moving
			velocity.x = lerp(velocity.x, 0.0, delta * frictDefault)
			velocity.z = lerp(velocity.z, 0.0, delta * frictDefault)
	else:
		if direction != Vector3.ZERO:
			# Apply reduced air control movement (slower speed in the air)
			var air_control_spd = spd 
			var air_friction = 5.0
			velocity.x = lerp(velocity.x, direction.x * air_control_spd, delta * air_friction)
			velocity.z = lerp(velocity.z, direction.z * air_control_spd, delta * air_friction)


	# Head Bobbing
	tBob += delta * velocity.length() * float(is_on_floor())
	camera_3d.transform.origin = HeadBob(tBob)

#HANDLE CLIMBING
func HandleClimbing():
	#If no ladder exists, get outta here
	if currentLadder == null: return;
	
	#vars
	var _vel = 0
	var climbSpd = 8
	
	if Input.is_action_pressed("move_forward"):
		var rot = camera_3d.rotation_degrees.x
		if rot < 45 and rot > -45:
			rot = 45
		_vel = climbSpd * (rot * 0.01)
		
	spd = spdClimb
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
		%Flashlight.visible = flashlight	

#UPDATE HUD
func UpdateHUD():
	#hpGoto = lerpf(hpGoto,Game.hp.current,0.1)
	lblHealth.text = str(Game.hp.current)
	healthbar.value = hpGoto
	hudKeycardRed.visible = Game.keycard.red
	hudKeycardYellow.visible = Game.keycard.yellow
	hudKeycardBlue.visible = Game.keycard.blue
	var currentWeapon = Game.weapons[Game.currentWeapon]
	var ammo = GetCurrentWeaponAmmoCount()
	
	lblAmmo.text = str(currentWeapon.clip, " | ", ammo)
	pass

func GetCurrentWeaponAmmoCount():
	var currentWeapon = Game.weapons[Game.currentWeapon]
	var ammoPoolType = ""
	var ammoPool = null
	# Get our current ammo for the weapon equipped
	for w in Game.weaponList:
		if w.index == currentWeapon.index:
			ammoPoolType = w.ammoPool
	
	for a in Game.ammoPool:
		if a.type == ammoPoolType:
			ammoPool = a
	
	if ammoPool == null: return 0
	else: return ammoPool.ammo
	pass

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
	
	pass

func HandleCrouch(delta):
	
	var wasCrouching = crouching

	# Crouching input
	if Input.is_action_pressed("Crouch"):
		crouching = true
	elif crouching and not self.test_move(self.global_transform,Vector3(0,crouchHeight,0)):
		crouching = false
	
	var translateY = 0.0
	if wasCrouching != crouching and not is_on_floor():
		translateY = crouchJumpFinal if crouching else -crouchJumpFinal
	
	if translateY != 0.0:
		var col = KinematicCollision3D.new()
		self.test_move(self.global_transform,Vector3(0,translateY,0), col)
		self.position.y += col.get_travel().y
		%Head.position.y -= col.get_travel().y 
		%Head.position.y = clamp(%Head.position.y,-crouchHeight,0)

	var smoothingSpd = 5.0
	if not crouching: smoothingSpd = 12.0
		
	#%Head.position = Vector3(0,(-crouchHeight if crouching else 0),0) 
	%Head.position.y = lerp(%Head.position.y, -crouchHeight if crouching else 0.0, smoothingSpd * delta)
	%Player.shape.height = ogCapsuleHeight - crouchHeight if crouching else ogCapsuleHeight
	%Player.position.y = %Player.shape.height / 2

#RELOAD
func Reload():
	# Check if in an animation, or already reloading
	if canShoot == false: return
	if reloading: return
	
	# Get our currents weapon and ammo data
	var currentWeapon = Game.weapons[Game.currentWeapon]
	var weaponIndex = currentWeapon.index
	var ammo = GetCurrentWeaponAmmoCount()
	
	# Find our current weapon in our inventory
	for w in Game.weapons:
		if w.index == weaponIndex:
			var weapon = Game.weaponList[weaponIndex]
			
			# Check if we already have a full clip, our ammo is depleated, or if its a melee weapon
			if w.clip >= weapon.magSize || weapon.melee == true :
				return
			if ammo <= 0: return
	
	# Reloading checks succeeded, start reloading
	reloading = true
	
	# Play Reloading Sound Effect
	$Audio/sfxShotgunReload.play()
	
	# Set all of our animation blend speeds to 0 to avoid wonky animations during reloading
	runVal = 0.0
	runSpd = 0.0
	shootVal = 0.0
	shootSpd = 0.0
	
	# Tell our player to stop shooting if doing so
	ShootAnimDone()
	
	# Play the Reload Animation
	anim_tree.set("parameters/Reload/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)	
	
#RELOAD AMMO
#This function is called after Reloading animation finishes executing to ensure the ammo doesnt immedietly reload when you press the reload button
func ReloadAmmo():
	# Get current weapon and ammo information
	var currentWeapon = Game.weapons[Game.currentWeapon]
	var weaponIndex = currentWeapon.index
	var _magSize = Game.weaponList[weaponIndex].magSize
	var ammo = GetCurrentWeaponAmmoCount()
	var ammoPoolType = null
	
	# Find which ammo pool type our current gun uses
	for w in Game.weaponList:
		if w.index == weaponIndex:
			ammoPoolType = w.ammoPool
	
	# Check through all ammo types
	for a in Game.ammoPool:
		
		# Our ammo type matches a type found in the library
		if a.type == ammoPoolType:
			
			# Check through our weapon inventory
			for w in Game.weapons:
				# Found our currently equipped weapon
				if w.index == weaponIndex:
					# Perform Ammo calculations on Ammo & Clip
					var neededAmmo = _magSize - w.clip
					if ammo >= neededAmmo:
						a.ammo -= neededAmmo
						w.clip = _magSize
					else:
						w.clip += a.ammo
						a.ammo = 0
					
					UpdateHUD()
					
					#Reflect changes in the ammo pool
					a.ammo = a.ammo
					w.clip = w.clip
			pass
	
#EXIT
func Exit():
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
#RESTART
func Restart():
	pass

#CHANGE WEAPON
func ChangeWeapon(type):
	# Check if we can shoot (prevents changing weapons during animations like reloading and grenades, etc.)
	if canShoot == false: return
	
	#reset all gun models invisible initially
	modelPistol.visible = false
	modelCarbine.visible = false
	modelPumpShotgun.visible = false
	modelRevolver.visible = false
	modelCrowbar.visible = false
	modelSubMachineGun.visible = false
	modelKnife.visible = false
	modelMP.visible = false
	
	#Update data for other entities
	canShoot = false
	changingWeapon = true
	
	#Stop Reloading Animation if we shoot
	anim_tree.set("parameters/Reload/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
	#set current weapon visible
	#set current sound effect of weapon
	#set current animationtree of the weapon (found in the weapon's scene)
	match type:
		#NO WEAPON
		0:
			anim_tree = animPistol
			pass
		#PISTOL
		1:
			weaponSFX = sfxShotgun
			anim_tree = animPistol
			modelPistol.visible = true
			pass
		#CARBINE
		2:
			weaponSFX = sfxShotgun
			anim_tree = animCarbine
			modelCarbine.visible = true
			pass		
		#PUMP SHOTGUN
		3:
			weaponSFX = sfxShotgun
			anim_tree = animPumpShotgun
			modelPumpShotgun.visible = true
			pass		
		#REVOLVER
		4:
			weaponSFX = sfxShotgun
			anim_tree = animRevolver
			modelRevolver.visible = true
			pass		
		#CROWBAR
		5:
			weaponSFX = sfxWhip1
			anim_tree = animCrowbar
			modelCrowbar.visible = true
			pass	
		#SUB MACHINE GUN
		6:
			weaponSFX = sfxShotgun
			anim_tree = animSubMachineGun
			modelSubMachineGun.visible = true
			pass	
		#KNIFE
		7:
			weaponSFX = sfxWhip1
			anim_tree = animKnife
			modelKnife.visible = true
			pass
		#MP
		8:
			weaponSFX = sfxShotgun
			anim_tree = animMP
			modelMP.visible = true
			pass
	
	# Get current weapon data
	var _weapon = Game.weapons[Game.currentWeapon]
	var weaponIndex = _weapon.index
	
	#Find our equipped weapons data in the weapon library
	for w in Game.weaponList:
		if w.index == weaponIndex:
			
			#Check if our current weapon is a melee weapon
			var isMelee = false
			if w.melee : isMelee = true
			
			#Change Attack distance, and update hud elements correctly depending on weapon type			
			if isMelee:
				ChangeAttackRange(meleeDistance)
				sBullet.visible = false
				lblAmmo.text = ""
			else:
				ChangeAttackRange(bulletDistance)
				sBullet.visible = true
				UpdateHUD()
			
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

#Changes the attack range of our weapon
func ChangeAttackRange(newRange : int):
	raycastRange = newRange
	%RayCast3D.target_position.z = newRange
	pass

#Use 2 buttons to cycle through all the current weapon inventory
func ChangeWeaponScroll(isUp):
	
	# Get the amount of weapons in our inventory
	var weaponCount = Game.weapons.size()
	
	#Check which direction was inputed
	if isUp:
		#Cycle weapons upwards
		Game.currentWeapon += 1
		if Game.currentWeapon > weaponCount-1:
			Game.currentWeapon = 0
	else:
		#Cycle weapons downwards
		Game.currentWeapon -= 1
		if Game.currentWeapon < 0:
			Game.currentWeapon = weaponCount-1
	
	#Get next weapon data, and switch current weapon to new one
	var weaponIndex = Game.weapons[Game.currentWeapon].index
	ChangeWeapon(weaponIndex)
	
#HURT
func Hurt(dmg):
	# Check if were already being hurt or in god mode
	if isHurt || Game.godmode :
		return
	
	# Apply hurt, and damage calculations to player & Update HUD accordingly	
	isHurt = true
	Game.hp.current = Game.hp.current - dmg
	Game.hp.current = clamp(Game.hp.current,0,Game.hp.maximum)
	UpdateHUD()

#INCREASE HEALTH useful for healthkits
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

#WALK
func Walk():
	#Handles walking animation blends
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
		velocity.y = jumpHeight

#SET JUMP HEIGHT
func SetJumpHeight(_jumpHeight):
	jumpHeight = _jumpHeight
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

func ChangeCrosshair():
	if ray_cast_3d.is_colliding():
		var c_white = Color8(255,255,255)
		var c_red = Color8(255,0,0)
		var target = ray_cast_3d.get_collider()
		
		# Exit this function if we arent aiming at a viable target
		if target == null: 
			%Crosshair.color = c_white
			return
			
		# If aiming at enemy turn crosshair red
		if target.is_in_group("Enemy"):
			%Crosshair.color = c_red
		else:
			%Crosshair.color = c_white
	pass

#Bullet collision
func CreateRayCast():
	if ray_cast_3d.is_colliding():
		
		#Get raycast collision data
		var colPoint = ray_cast_3d.get_collision_point()
		var normal = ray_cast_3d.get_collision_normal()
		var target = ray_cast_3d.get_collider()
		if target == null: return
		
		#Create Bullet Hole Decal on the surface we just shot
		var weaponPower = 0
		var _weapon = Game.weapons[Game.currentWeapon]
		var isMelee = false
		for w in Game.weaponList:
			if w.index == _weapon.index:
				weaponPower = w.power
				isMelee = w.melee
		
		# Create Bullet Hole / Scratch Decal on wall when shooting		
		if target.is_in_group("Enemy") == false:
			var decal = decalBulletHole.instantiate()
					
			if isMelee: decal.type = 2
			else: decal.type = 1
			
			#Limit amount of decals that can be in the room for performance
			if decals.size() >= decalsMax:
				var old_decal = decals.pop_front()
				old_decal.queue_free()
			
			# Add the decal to the scene and attach it to the wall we just shot
			decals.append(decal)
			target.add_child(decal)
			decal.global_transform.origin = colPoint
			decal.look_at(colPoint + normal, Vector3.UP)
		
		#Do stuff when specific entities are shot
		#Enemies
		if target.is_in_group("Enemy"): 
			target.Hurt(weaponPower)
		
		#Breakables
		if target.is_in_group("Breakable"): target.Destroy()
		
		return target

#SHOOT
func Shoot():
	#Get global weapon properties 
	var currentWeapon = Game.weapons[Game.currentWeapon]
	var weaponIndex = currentWeapon.index
	var weaponData = null
	
	var isMelee = false
	for i in Game.weaponList:
		if i.index == weaponIndex:
			weaponData = i
			isMelee = i.melee
	
	#Get our current weapons data from the weapons list 
	for weapon in Game.weaponList:
		if weapon.index == weaponIndex:
			
			#No weapon is equipped
			if weapon.index == 0: return
			
			#If we shoot and have no ammo, reload if not a melee weapon
			if currentWeapon.clip <= 0 && isMelee == false:
				Reload()
				return
	
	#Check if we can shoot, and aren't doing the following actions
	if canShoot == false || reloading || changingWeapon :
		return
	
	#Shooting checks succeeded, perform the shot
	canShoot = false
	
	#Play Shoot audio for the correct weapon
	weaponSFX.play()
	if weaponSFX == sfxWhip1: weaponSFX = sfxWhip2
	elif weaponSFX == sfxWhip2: weaponSFX = sfxWhip1
	
	#Create a raycast to the point we just shot to get collider
	CreateRayCast()
	
	#Update our Weapons array to reflect our new ammo after shooting
	for weapon in Game.weapons:
		if weapon.index == weaponIndex:
			
			#If it is a melee weapon, we cannot reload duh
			if isMelee: 
				#Play our melee oneshot, they have multiple so it isnt so boring
				if currentMeleeAnim == 0:
					anim_tree.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)	
				else:
					anim_tree.set("parameters/Shoot2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)	
				currentMeleeAnim += 1
				if currentMeleeAnim >= 2: currentMeleeAnim = 0
				
				return
			
			#Play gun model one shot
			anim_tree.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				
			#Decrease the weapon clip, and update the HUD
			var ammo = GetCurrentWeaponAmmoCount()
			currentWeapon.clip -= 1
			lblAmmo.text = str(weapon.clip, " | ", ammo)
			
			#If we have no more ammo, reload the weapon instead of shooting
			if currentWeapon.clip <= 0:
				Reload()
	UpdateHUDSignal.emit()

#SHOOT ANIM DONE
func ShootAnimDone():
	canShoot = true
	shootVal = 0.0

#HEAD BOB
func HeadBob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bobFreq) * bobAmp
	pos.x = cos(time * bobFreq / 2) * bobAmp
	return pos
	
#HIDE HUD INTERACT 
func _on_hide_hud_interact():
	hudInteract.visible = false
	pass 

#ANIM CHANGED
func _on_animation_player_animation_changed(old_name, new_name):
	ShootAnimDone()
	pass 

#ANIM FINISHED
func _on_animation_player_animation_finished(anim_name):
	
	#Damage Pain HUD Flash Finished
	if anim_name == "Pain":
		isHurt = false
		return
	
	#Finished Shooting
	if (anim_name == "Armature|Shoot_001" ||
		anim_name == "Armature|Shoot" ||
		anim_name == "Shoot" ||
		anim_name == "Armature|Shoot2"):
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
	
	pass

#ON COLLISION ENTERED CHECKS
func onAreaEntered(area):
	
	# Set sfx to the switch effect if the area is an interactable entity
	if area.is_in_group("Interact"):
		currentSFX = sfxInteractSwitch
	
	#WATER
	if area.is_in_group("Water"):
		grvty = grvtyWater
		state = SWIMMING
	
	#LADDER
	if area.is_in_group("Ladder"):
		state = CLIMBING
		currentLadder = area
		
	pass 

#ON COLLISION EXITED CHECKS
func onAreaExited(area):
	
	# Reset sfx to the no work effect
	if area.is_in_group("Interact"):
		currentSFX = sfxInteractNowork
	
	#WATER
	if area.is_in_group("Water"):
		state = DEFAULT
		grvty = grvtyDefault
	
	#LADDER
	if area.is_in_group("Ladder"):
		state = DEFAULT
		currentLadder = null
	pass 
