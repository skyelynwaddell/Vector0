@tool
extends CharacterBody3D
class_name Player

## i promised this player controller wouldnt get messy
## it is unavoidable and it is what it is.

#NODE REFS
@onready var ray_cast_3d = %RayCast3D
@onready var camera_3d = %Camera3D
@onready var svp_camera_3d = %Subviewport_camera
@onready var head = %Head
@onready var barrel = %Barrel
@onready var ogCapsuleHeight = %Player.shape.height

#animation trees
@onready var animPistol = %arms_pistol/AnimationTree
@onready var animPistol2 = %NewPistol/AnimationTree
@onready var animCarbine = %arms_carbine/AnimationTree
#@onready var animPumpShotgun = %PumpShotgun/AnimationTree
@onready var animRevolver = %Revolver/AnimationTree
@onready var animSubMachineGun = %SubMachineGun/AnimationTree
#@onready var animCrowbar = %Crowbar/AnimationTree
@onready var animKnife = %Knife/AnimationTree
@onready var animMP = %MP/AnimationTree
@onready var animPump2 = %NewPump/AnimationTree
@onready var anim_tree = animPistol

#models
@onready var modelPistol = %arms_pistol
@onready var modelCarbine = %arms_carbine 
#@onready var modelPumpShotgun = %PumpShotgun
@onready var modelRevolver = %Revolver
@onready var modelSubMachineGun = %SubMachineGun
#@onready var modelCrowbar = %Crowbar
@onready var modelKnife = %Knife
@onready var modelMP = %MP
@onready var modelPump2 = %NewPump

#HUD
@onready var lblAmmo = %lblAmmo
@onready var healthbar = %Health
@onready var lblHealth = %lblHealth
@onready var hudKeycardRed = %CardRed
@onready var hudKeycardYellow = %CardYellow
@onready var hudKeycardBlue = %CardBlue
#@onready var hudInteract = %Interact
@onready var sBullet = %Bullet
@onready var hudAnimPlayer = %AnimationPlayer

var shoot_knockback_str = 4.0
var shoot_knockback_damping = 5.0
var shoot_knocback_vel = Vector3.ZERO
var sway_tilt_max = 1.0
var sway_tilt_speed = 8.0
var current_tilt = 0.0

#SFX
#@onready var sfxInteractNowork = %sfxInteractNowork
#@onready var sfxInteractSwitch = %sfxInteractSwitch
#@onready var sfxWhip1 = %sfxWhip1
#@onready var sfxWhip2 = %sfxWhip2
var sfxReload : AudioStream
var currentSFX : AudioStream
var weaponSFX : AudioStream

#Decals
@onready var decalBulletHole = preload("res://scenes/decals/decal_bullethole.tscn")

#signals
signal UpdateHUDSignal
signal PlayerShootSignal

@export_group("Properties")
## Target Name - Default is "Player"
@export var targetname : String = "player"
## Initial Spawn Direction
@export var spawndir : String = "forward"
## Mouse Sensitivity
@export_range(0,1) var mouseSens : float = 0.2

#BOBBING
var bobFreq = 1.0
var movebob = 0.2
var bobOffset = Vector3.ZERO
var tBob = 0
var headPosY = 0.0
var base_head_pos:= Vector3.ZERO

@export_group("Weapon Properties")
## Gun Bullet Distance
@export var bulletDistance : float = 2000.0
@export var meleeDistance : float = 1.5

@export_group("Speed")
## Default Movement Speed
@export_range(0,50) var spdDefault : float = 12.0
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
@export_range(0,50) var frictAccel : float = 0.0

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

var lava_hurt_timer := 0
var lava_hurt_time := 60

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
var flashlight = true

#amimation speeds
var runVal = 0.0
var runSpd = 0.0
var shootSpd = 0.0
var shootVal = 0.0



#STATE MACHINE
const DEFAULT  = 0
const CLIMBING = 1
const SWIMMING = 2
const WALKING = 3
const DEATH = 4
var state = DEFAULT
var direction = 0

#Load player data from mapping software
func _func_godot_apply_properties(props : Dictionary):
	if "spawndir" in props: spawndir = props.spawndir
	if "targetname" in props: targetname = props.targetname
		

func EmissionSet(amt:int):
	%WorldEnvironment.environment.background_energy_multiplier = amt

#READY EVENT
func _ready() -> void:
	Signals.EmissionSet.connect(EmissionSet)
	print("PLAYER OBJECT CREATED")
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
	### DONT FUCKING TOUCH
	InputMap.load_from_project_settings()	#IMPORTANT DONT REMOVE OR HELL WILL BREAK LOOSE! NOT JOKING THE MOUSE WILL DISAPPEAR AND 100000 ERRORS WILL SPIT OUT AND THE PROJECT WONT BE ABLE TO OPEN ANYMORE. IDEK WTF ITS A GODOT ERROR APPARENTLY WITH USING @TOOL
	### DONT FUCKING TOUCH
	
	#Game.ammoPool = Game.ammoPoolDefault.duplicate(true)
	#Game.weapons = Game.weaponsDefault.duplicate(true)
	ChangeWeapon(0)
	
	
	print("### WEAPONS: " + str(Game.weapons))
	print("### AMMO POOLS: " + str(Game.ammoPool))
	
	if Game.last_data != null: 
		print("GAME LAST_DATA WAS NOT NULL!!")
		var weaponIndex = Game.GetData(self)
		print("Changing weapon to : " + str(weaponIndex))
		ChangeWeapon(weaponIndex)
		
		
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED ## Hide the mouse
	
	#initiate head height
	headPosY = head.position.y
	SetHeadHeight(headPosY)
	
	Signals.UpdateHUD.connect(UpdateHUD)
	UpdateHUD()
	
	base_head_pos = camera_3d.transform.origin
	
	pass

func CheckIfImInLavaSoItCanBurnMe():
	if in_lava:
		lava_hurt_timer += 1
		if lava_hurt_timer >= lava_hurt_time:
			lava_hurt_timer = 0
			Hurt(30)
			
	else:
		if lava_hurt_timer != 0: lava_hurt_timer = 0
		
	pass

func CheckIfImDeadYet():
	if Game.hp.current <= 0 and state != DEATH:
		#finally
		state = DEATH

#STEP EVENT
func _process(delta): 
	if Engine.is_editor_hint(): return
	
	%fps.text = str(Engine.get_frames_per_second())
	
	CheckIfImInLavaSoItCanBurnMe()
	CheckIfImDeadYet()
	
	#set camera position if we are not in the console
	if Console != null: 
		if Console.is_visible(): return
		
	if Game.IsPaused(): return
	
	# If you want to see your arms or anything to make sense in 3d space basically
	svp_camera_3d.set_global_transform(camera_3d.get_global_transform())
	
	#game updates
	Exit() ## exit game function
	if dead: return
	
	# Interact sound effect
	if Input.is_action_just_pressed("Interact"): 
		MusicPlayer.Sound(currentSFX, MusicPlayer.AUDIO_CHANNEL.SFX, 1.0)
		#currentSFX.play()
	
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
			
		DEATH:
			
			if not in_gameover:
				ChangeWeapon(0)
				StateDefault()
				in_gameover = true
				Game.CreateGameOverScreen()
				
			
				
				
			return
	
	# Functions allowed for all states
	HandleReload()
	HandleJump()
	HandleFlashlight()
	HandleShoot()
	DamageEffect()
	AllowWeaponChange()
	HandleWeaponChange(delta)
	MovePlayer(delta)
	#HandlePlayerDirection(delta)
	ChangeCrosshair()
	
	if shoot_knocback_vel.length() > 0.01:
		camera_3d.position -= shoot_knocback_vel * delta
		shoot_knocback_vel.x = lerp(shoot_knocback_vel.x,0.0, delta*shoot_knockback_damping) 
		shoot_knocback_vel.y = lerp(shoot_knocback_vel.x,0.0, delta*shoot_knockback_damping) 
		shoot_knocback_vel.z = lerp(shoot_knocback_vel.x,0.0, delta*shoot_knockback_damping) 
	pass

var in_gameover = false

func ShootKnockback():
	var bckwrd = -camera_3d.global_transform.basis.z
	shoot_knocback_vel = lerp(shoot_knocback_vel, bckwrd * shoot_knockback_str,1.0)

#PHYSICS PROCESS
func _physics_process(delta):
	if Engine.is_editor_hint(): return
	if Console.is_visible(): return
	if Game.IsPaused(): return
	
	var lastVelocity = velocity
	if state != DEATH: push_rigid_bodies(lastVelocity,delta)
	HandleCrouch(delta)
	if state != DEATH: move_and_slide()
	
	HeadTilt(delta)
	
func HeadTilt(delta):	
	if state == DEATH: return
	
	# Get raw input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Strafe is just the x-axis of input (left/right)
	var strafe_input = input_dir.x
	
	# Deadzone
	if abs(strafe_input) < 0.05:
		strafe_input = 0.0

	# Target tilt is based only on input
	var target_tilt = -strafe_input * sway_tilt_max
	var return_tilt = 10.0
	# Faster return when idle
	var speed = sway_tilt_speed#return_tilt if strafe_input == 0.0 else sway_tilt_speed
	current_tilt = lerp(current_tilt, target_tilt, delta * speed)

	# Apply tilt to camera
	var camera_rot = camera_3d.rotation_degrees
	camera_rot.z = current_tilt
	camera_3d.rotation_degrees = camera_rot
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

var latest_x: String = ""
var latest_y: String = ""

func _find_other_x() -> String:
	if Game.IsPaused(): return ""
	if Console.is_visible(): return ""
	if Input.is_key_pressed(KEY_A):
		return "left"
	elif Input.is_key_pressed(KEY_D):
		return "right"
	return ""

func _find_other_y() -> String:
	if Game.IsPaused(): return ""
	if Console.is_visible(): return ""
	if Input.is_key_pressed(KEY_W):
		return "forward"
	elif Input.is_key_pressed(KEY_S):
		return "backward"
	return ""

func HandlePlayerDirection(delta) -> Vector3:
	var input_dir = Vector2.ZERO

	match latest_x:
		"left": input_dir.x = -1
		"right": input_dir.x = 1

	match latest_y:
		"forward": input_dir.y = -1
		"backward": input_dir.y = 1

	return (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


var strafe_boost = 0.0;
func ApplyVelocity(delta, dir):
	#var strafe_boost = 0
	
	var boost_spd = 0.1
	var y_strafe = 0.0

	if not is_on_floor():
		if (latest_x == "left" and last_mouse_dir < 0) or (latest_x == "right" and last_mouse_dir > 0):
			strafe_boost += boost_spd
	else:
		strafe_boost -= boost_spd * 2
		if (latest_x == "left" and last_mouse_dir < 0) or (latest_x == "right" and last_mouse_dir > 0):
			if Input.is_action_just_pressed("jump"):
				y_strafe = 0.5
		
	
	strafe_boost = clamp(strafe_boost, 0.0, 8.0)
		
	# Check if the player is on the floor
	# Ground movement: accelerate towards the desired direction
	if dir != Vector3.ZERO:
		# Apply movement direction
		velocity.x = lerp(velocity.x, dir.x * (spd + strafe_boost), delta * frictAccel)
		velocity.z = lerp(velocity.z, dir.z * (spd + strafe_boost), delta * frictAccel)
		velocity.y += y_strafe;
	
	else:
		if is_on_floor():
			# Apply friction when not moving
			velocity.x = lerp(velocity.x, 0.0, delta * frictDefault)
			velocity.z = lerp(velocity.z, 0.0, delta * frictDefault)
		
			#velocity.x += velocity.x * dir.x * (air_control_spd * (1.0 + strafe_boost)) * (delta * air_friction) ##lerp(velocity.x, dir.x * air_control_spd * (1.0 + strafe_boost), delta * air_friction)
			#velocity.z += velocity.z * dir.z * (air_control_spd * (1.0 + strafe_boost)) * (delta * air_friction)#velocity.z = ##lerp(velocity.z, dir.z * air_control_spd * (1.0 + strafe_boost), delta * air_friction)
#
#func ApplyVelocity(delta, dir):
	## Check if the player is on the floor
	#if is_on_floor():
		## Ground movement: accelerate towards the desired direction
		#if dir != Vector3.ZERO:
			#
			## Apply movement direction
			#velocity.x = lerp(velocity.x, dir.x * spd, delta * frictAccel)
			#velocity.z = lerp(velocity.z, dir.z * spd, delta * frictAccel)
		#else:
			## Apply friction when not moving
			#velocity.x = lerp(velocity.x, 0.0, delta * frictDefault)
			#velocity.z = lerp(velocity.z, 0.0, delta * frictDefault)
	#else:
		#if dir != Vector3.ZERO:
			## Apply reduced air control movemen
			#var air_control_spd = spd
			#var air_friction = 5.0
			#var strafe_boost = 0.0
			#
			#if (latest_x == "left" and last_mouse_dir < 0) or (latest_x == "right" and last_mouse_dir > 0):
				#strafe_boost = 0.25
			#
			#var rotated_dir = head.global_transform.basis * dir
			##rotated_dir.y = 0  # Ignore vertical component
			#var wish_dir = rotated_dir.normalized()
#
			#var current_speed = velocity.dot(wish_dir)
			#var max_air_speed = 20.0
			#var accel = air_control_spd * strafe_boost
			#var add_speed = max_air_speed - current_speed
#
			#if add_speed > 0:
				#var accel_speed = min(accel * delta * air_friction, add_speed)
				#velocity += wish_dir * accel_speed
				#
			##velocity.x += velocity.x * dir.x * (air_control_spd * (1.0 + strafe_boost)) * (delta * air_friction) ##lerp(velocity.x, dir.x * air_control_spd * (1.0 + strafe_boost), delta * air_friction)
			##velocity.z += velocity.z * dir.z * (air_control_spd * (1.0 + strafe_boost)) * (delta * air_friction)#velocity.z = ##lerp(velocity.z, dir.z * air_control_spd * (1.0 + strafe_boost), delta * air_friction)


	# Head Bobbing
	var speed := velocity.length()
	
	# Only increase bobbing time if moving and on floor
	if is_on_floor() and speed >= 0.1:
		tBob += delta * speed
		bobOffset = HeadBob(tBob)

	var cam_transform = camera_3d.transform
	cam_transform.origin = base_head_pos + bobOffset
	camera_3d.transform = cam_transform
	#tBob += delta * velocity.length() * float(is_on_floor())
	#camera_3d.transform.origin = HeadBob(tBob)

func MovePlayer(delta):
	## Stop moving player if paused or something 
	if Console.is_visible() or Game.IsPaused(): 
		direction = Vector3.ZERO
		velocity = Vector3.ZERO
		return
		
		
	direction = HandlePlayerDirection(delta)
	ApplyVelocity(delta, direction)

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
	if Input.is_action_just_pressed("jump"): Jump()

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
	%lblArmor.text = str(Game.armor.current)
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
	##Change to Weapon 1 [1]
	#if Input.is_action_pressed("Weapon1"):
		#ChangeWeapon(0)
	#
	##Change to Weapon 2 [2]
	#if Input.is_action_pressed("Weapon2"):
		#ChangeWeapon(1)	
	
	#Change Weapon Up [SCROLL WHEEL UP]
	if Input.is_action_just_released("ChangeWeaponUp"):
		ChangeWeaponScroll(true)	
	
	#Change Weapon Down [SCROLL WHEEL DOWN]
	if Input.is_action_just_released("ChangeWeaponDown"):
		ChangeWeaponScroll(false)	

var last_mouse_dir = 0
#INPUT
func _input(event):
	if dead:
		return
		
	if Console.is_visible() or Game.IsPaused():
		latest_x = ""
		latest_y = ""
		return
	
	if event is InputEventKey and not event.echo:
		var pressed = event.pressed
		match event.keycode:
			KEY_W:
				if pressed: latest_y = "forward"
				elif latest_y == "forward": latest_y = _find_other_y()
			KEY_S:
				if pressed: latest_y = "backward"
				elif latest_y == "backward": latest_y = _find_other_y()
			KEY_A:
				if pressed: latest_x = "left"
				elif latest_x == "left": latest_x = _find_other_x()
			KEY_D:
				if pressed: latest_x = "right"
				elif latest_x == "right": latest_x = _find_other_x()
	
	if event is InputEventMouseMotion:
		var _event = -event.relative
		var yRotationLimit = 90
		
		head.rotate_y(deg_to_rad(_event.x * mouseSens))
		camera_3d.rotation_degrees.x += _event.y * mouseSens
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -yRotationLimit, yRotationLimit)
		
		last_mouse_dir = sign(_event.x)
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
		
	if state == DEATH: crouching = true
	
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
	MusicPlayer.Sound(sfxReload, MusicPlayer.AUDIO_CHANNEL.SFX, 0.5)
	
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
	pass
		
#RESTART
func Restart():
	pass

#CHANGE WEAPON
func ChangeWeapon(_type):
	var type = int(_type)
	
	## make sure when we are dead we cannot switch to any weapon except NO WEAPON
	if state == DEATH:
		if type != 0: return 
	
	# Check if we can shoot (prevents changing weapons during animations like reloading and grenades, etc.)
	#if canShoot == false: return
	print("#### CHANGING WEAPON....... #####")
	#reset all gun models invisible initially
	modelPistol.visible = false
	modelCarbine.visible = false
	#modelPumpShotgun.visible = false
	modelRevolver.visible = false
	#modelCrowbar.visible = false
	modelSubMachineGun.visible = false
	modelKnife.visible = false
	modelMP.visible = false
	modelPump2.visible = false
	%NewPistol.visible = false
	
	#Update data for other entities
	canShoot = false
	changingWeapon = true
	
	#Stop Reloading Animation if we shoot
	anim_tree.set("parameters/Reload/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
	#set current weapon visible
	#set current sound effect of weapon
	#set current animationtree of the weapon (found in the weapon's scene)
	match type:
		#NO WEAPON - hands
		0:
			anim_tree = animPistol
			%MuzzleParticles.global_position = %Knife.get_node("WepBarrel").global_position
			pass
		#PISTOL
		1:
			weaponSFX = MusicPlayer.SFX.PISTOL_SHOT
			sfxReload = MusicPlayer.SFX.PISTOL_RELOAD
			anim_tree = animPistol
			modelPistol.visible = true
			%MuzzleParticles.global_position = %arms_pistol.get_node("WepBarrel").global_position
			pass
		#CARBINE
		2:
			weaponSFX = MusicPlayer.SFX.MACHINE_GUN_SHOT
			sfxReload = MusicPlayer.SFX.MACHINE_GUN_RELOAD
			anim_tree = animCarbine
			modelCarbine.visible = true
			%MuzzleParticles.global_position = %arms_carbine.get_node("WepBarrel").global_position
			pass		
		#PUMP SHOTGUN
		3:
			weaponSFX = MusicPlayer.SFX.SHOTGUN_SHOT
			sfxReload = MusicPlayer.SFX.SHOTGUN_RELOAD
			#anim_tree = animPumpShotgun
			#modelPumpShotgun.visible = true
			%MuzzleParticles.global_position = %PumpShotgun.get_node("WepBarrel").global_position
			pass		
		#REVOLVER
		4:
			weaponSFX = MusicPlayer.SFX.REVOLVER_SHOT
			sfxReload = MusicPlayer.SFX.REVOLVER_RELOAD
			anim_tree = animRevolver
			modelRevolver.visible = true
			%MuzzleParticles.global_position = %Revolver.get_node("WepBarrel").global_position
			pass		
		#CROWBAR
		5:
			weaponSFX = MusicPlayer.SFX.WHIP_1
			#anim_tree = animCrowbar
			#modelCrowbar.visible = true
			%MuzzleParticles.global_position = %Knife.get_node("WepBarrel").global_position
			pass	
		#SUB MACHINE GUN
		6:
			weaponSFX = MusicPlayer.SFX.MP_SHOT
			sfxReload = MusicPlayer.SFX.MP_RELOAD
			anim_tree = animSubMachineGun
			modelSubMachineGun.visible = true
			%MuzzleParticles.global_position = %Knife.get_node("WepBarrel").global_position
			pass	
		#KNIFE
		7:
			weaponSFX = MusicPlayer.SFX.WHIP_1
			anim_tree = animKnife
			modelKnife.visible = true
			%MuzzleParticles.global_position = %Knife.get_node("WepBarrel").global_position
			pass
		#MP
		8:
			weaponSFX = MusicPlayer.SFX.MP_SHOT
			sfxReload = MusicPlayer.SFX.MP_RELOAD
			anim_tree = animMP
			modelMP.visible = true
			%MuzzleParticles.global_position = %MP.get_node("WepBarrel").global_position
			pass
		#Pump 2
		9:
			weaponSFX = MusicPlayer.SFX.SHOTGUN_SHOT
			sfxReload = MusicPlayer.SFX.SHOTGUN_RELOAD
			anim_tree = animPump2
			modelPump2.visible = true
			%MuzzleParticles.global_position = %NewPump.get_node("WepBarrel").global_position
			pass		
		#Pistol 2
		10:
			print("Showing pistol 2")
			weaponSFX = MusicPlayer.SFX.PISTOL_SHOT
			sfxReload = MusicPlayer.SFX.PISTOL_RELOAD
			anim_tree = animPistol2
			%NewPistol.visible = true
			%MuzzleParticles.global_position = %NewPistol.get_node("WepBarrel").global_position
			pass
			
	
	# Get current weapon data
	print("GAME WEAPONS ON LOAD: " + str(Game.weapons))
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
			
			
			var push_force = mass_ratio
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)

#Changes the attack range of our weapon
func ChangeAttackRange(newRange : int):
	raycastRange = newRange
	%RayCast3D.target_position.z = newRange
	pass

#Use 2 buttons to cycle through all the current weapon inventory
func ChangeWeaponScroll(isUp):
	
	if reloading: return
	
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
	
	
@onready var current_grunt = MusicPlayer.SFX.PLAYER_GRUNT_1
#HURT
func Hurt(dmg):
	
	if Game.hp.current <= 0: return;
	
	# Check if were already being hurt or in god mode
	if isHurt || Game.godmode :
		return
	
	# Apply hurt, and damage calculations to player & Update HUD accordingly	
	isHurt = true
	
	if current_grunt == MusicPlayer.SFX.PLAYER_GRUNT_1:
		current_grunt = MusicPlayer.SFX.PLAYER_GRUNT_2
	else:
		current_grunt = MusicPlayer.SFX.PLAYER_GRUNT_1
		
	MusicPlayer.Sound(current_grunt, MusicPlayer.AUDIO_CHANNEL.VOICE, 1.0)
	
	## check if we have armor
	if Game.armor.current <= 0:
		## no armor -> decrease our health points
		Game.hp.current = Game.hp.current - dmg
		Game.hp.current = clamp(Game.hp.current,0,Game.hp.maximum)
	else:
		## we have armor -> we can decrease that instead of our health
		Game.armor.current = Game.armor.current - dmg
		Game.armor.current = clamp(Game.armor.current,0,Game.armor.maximum)
	
	
	UpdateHUD()
	
#INCREASE Armor useful for ARMOR?
func IncreaseArmor(amount):
	Game.armor.current = Game.armor.current + amount
	Game.armor.current = clamp(Game.armor.current,0,Game.armor.maximum)

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
			
		
		MusicPlayer.Sound(MusicPlayer.SFX.PLAYER_JUMP, MusicPlayer.AUDIO_CHANNEL.VOICE, 0.5)
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
		
		if "shoot_can_toggle" in target:
			if target.shoot_can_toggle == 1:
				target.on_trigger()
		
		## Create Bullet Hole Decal on the surface we just shot ##
		
		## get current weapon power &&
		## figure out if our current weapon is a melee weapon, shotgun, or explosive to apply correct bullet hole decals
		var weaponPower = 0
		var _weapon = Game.weapons[Game.currentWeapon]
		var isMelee = false
		var isShotgun = false
		for w in Game.weaponList:
			if w.index == _weapon.index:
				
				# get power & check if the weapon is melee
				weaponPower = w.power
				isMelee = w.melee
				
				# check if the weapon is a shotgun
				if w.ammoPool == "shotgun":
					isShotgun = true
				
				#TODO: check if the weapon is a rocket launcher
				
				break
		
		# Create Bullet Hole / Scratch Decal on walls when shooting		
		if target.is_in_group("Enemy") == false and target.is_in_group("Switch") == false:
			
			## We need to check if shot with shotgun so we can make a bunch of bullet holes
			## because just having one bullet hole after a shotgun shot
			## looked completely dumb and lame
			if isShotgun:
				for i in range(6):
					var offset_range = 0.5  # Spread radius

					# Generate random offset in a circle
					var angle = randf() * TAU
					var radius = randf() * offset_range
					var x = cos(angle) * radius
					var y = sin(angle) * radius

					# Generate surface-aligned tangent vectors
					var tangent1 = normal.cross(Vector3.UP).normalized()
					if tangent1.length() < 0.1:
						tangent1 = normal.cross(Vector3.FORWARD).normalized()  # handle vertical walls
					var tangent2 = normal.cross(tangent1).normalized()

					# Offset in surface plane
					var offset = tangent1 * x + tangent2 * y
					var offset_col_point = colPoint + offset

					CreateBulletHole(isMelee, target, offset_col_point, normal)
			else:
				CreateBulletHole(isMelee,target,colPoint,normal)
		
		#Do stuff when specific entities are shot
		#Enemies
		if target.is_in_group("Enemy"): 
			target.Hurt(weaponPower)
			
		if target.is_in_group("Switch"):
			var par = target.get_parent()
			if par.has_method("on_trigger"):
				par.on_trigger()
		
		#Breakables
		if target.is_in_group("Breakable"): target.Destroy()
		
		return target

func CreateBulletHole(isMelee,target,colPoint,normal):
	
	if target.is_in_group("Breakable"): return ## so we dont leave bullet holes in the damn air after it the breakable breaks
	
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
	
	#Check if we arent reloading/changing weapons
	if reloading || changingWeapon :
		return
	
	#If already shooting dont do the below stuff
	if canShoot == false: return
	
	## SHOOT CHECK SUCCEESS DO ANY SHOOT LOGIC AFTER HERE, ANY THING ABOVE SHOOTING HAS FAILED
	#Shooting checks succeeded, perform the shot
	canShoot = false
	
	ShootKnockback()
	#Play Shoot audio for the correct weapon
	
	## cycle the melee whip sound effect everytime it is swung
	if weaponSFX == MusicPlayer.SFX.WHIP_1: weaponSFX = MusicPlayer.SFX.WHIP_2
	elif weaponSFX == MusicPlayer.SFX.WHIP_2: weaponSFX = MusicPlayer.SFX.WHIP_1
	
	MusicPlayer.Sound(weaponSFX, MusicPlayer.AUDIO_CHANNEL.SFX, 0.3)
	
	#Display muzzle flash	
	%MuzzleParticles.restart()
	if not isMelee:
		%MuzzleFlashAnim.stop()
		%MuzzleFlashAnim.play("muzzle_flash")
	
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
	pos.y = sin(time * bobFreq) * movebob
	pos.x = cos(time * bobFreq / 2) * movebob
	return pos
	
#HIDE HUD INTERACT 
func _on_hide_hud_interact():
	#hudInteract.visible = false
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
	## blender keeps exporting the animation names all funky so idk here is a hack incase it changes your anim names like it kept doing for me
	if (anim_name == "Armature|Shoot_001" ||
		anim_name == "Armature|Shoot" ||
		anim_name == "Shoot" ||
		anim_name == "Armature|SHOOT" ||
		anim_name == "Armature|Shoot2"):
		ShootAnimDone()
		return
		
	#Finished Reloading
	if (anim_name == "Armature|Reload_001" ||
		anim_name == "Armature|Reload" ||
		anim_name == "Armature|RELOAD" ||
		anim_name == "Reload"):
		reloading = false
		ReloadAmmo()
		ShootAnimDone()
		return
	
	pass

var in_lava := false

func onLavaEntered(area):
	#WATER
	if area.is_in_group("Water"):
		if area.is_dangerous == "1":
			lava_hurt_timer = lava_hurt_time
			in_lava = true
	pass
	
func onLavaExited(area):
	#WATER
	if area.is_in_group("Water"):
		if state == CLIMBING: return
		if area.is_dangerous == "1":
			lava_hurt_timer = 0
			in_lava = false
		
		#state = DEFAULT
		#grvty = grvtyDefault

#ON COLLISION ENTERED CHECKS
func onAreaEntered(area):
	
	# Set sfx to the switch effect if the area is an interactable entity
	if area.is_in_group("Interact"):
		currentSFX = MusicPlayer.SFX.SWITCH_DIGITAL
	
	#WATER
	if area.is_in_group("Water"):
		
		#if area.is_dangerous == "1":
			#lava_hurt_timer = lava_hurt_time
			#in_lava = true
		
		## quick hack to prevent being able to hop on top of lava without being hurt
		if "is_dangerous" in area:
			if str(area.is_dangerous) == "1":
				return
				
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
		currentSFX = MusicPlayer.SFX.INTERACT_NO_WORK
	
	#WATER
	if area.is_in_group("Water"):
		if state == CLIMBING: return
		#if area.is_dangerous == "1":
			#lava_hurt_timer = 0
			#in_lava = false
		
		state = DEFAULT
		grvty = grvtyDefault
	
	#LADDER
	if area.is_in_group("Ladder"):
		state = DEFAULT
		currentLadder = null
		state = DEFAULT
		grvty = grvtyDefault
	pass 
