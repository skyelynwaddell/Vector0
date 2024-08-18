extends CharacterBody3D
#NODE REFS
@onready var animated_sprite_2d = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var ray_cast_3d = $Head/RayCast3D
@onready var sndShoot = $sndShoot
@onready var camera_3d = $Head/Camera3D
@onready var svp_camera_3d = %Subviewport_camera
@onready var head = $Head
@onready var barrel = $Head/Camera3D/Barrel

#animation trees
@onready var animPistol = $Head/Camera3D/arms_pistol/AnimationTree
@onready var animM4A1 = $Head/Camera3D/arms_m4a1/AnimationTree
@onready var animPumpShotgun = $Head/Camera3D/PumpShotgun/AnimationTree
@onready var anim_tree = animPistol

#models
@onready var modelPistol = $Head/Camera3D/arms_pistol
@onready var modelM4A1 = $Head/Camera3D/arms_m4a1
@onready var modelPumpShotgun = $Head/Camera3D/PumpShotgun

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

signal UpdateHUDSignal(message)
signal HideHUDInteract

#VARIABLES
const mouseSens = 0.002
var spd = { current = 9, default = 9, run = 12 } 
var hp = { current = 100, maximum = 100 } 
var hpGoto = 0
var jumpHeight = 10
var grvty = 20
var frict = 7.0
var jumpFrict = 2.0
var canShoot = true
var dead = false
var runVal = 0.0
var runSpd = 0.0
var shootSpd = 0.0
var shootVal = 0.0
var reloading = false
var changingWeapon = false
var changingWeaponTimer = { current = 0, maximum = 0.2 }
var reloadTimer = { current = 0, maximum = 0.5 }
var shootTimer = 0
var shootTimerMax = 0.1

var keycardRed = false
var keycardYellow = false
var keycardBlue = false

var isHurt = false
var hurtTimer = { current=100, maximum=100 }

var bullet = load("res://scenes/Parents/bullet.tscn")
var instance

#BOBBING
var bobFreq = 2.0
var bobAmp = 0.08
var tBob = 0

#READY EVENT
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#animated_sprite_2d.animation_finished.connect(ShootAnimDone)
	UpdateHUD()
	ChangeWeapon(Game.currentWeapon)
	
	
func update_tree():
	anim_tree["parameters/RunBlend/blend_amount"] = runSpd
	#anim_tree["parameters/ShootBlend/blend_amount"] = shootSpd
	pass

func UpdateHUD():
	lblEnergy.text = str(hp.current)
	healthbar.value = hpGoto
	hudKeycardRed.visible = keycardRed
	hudKeycardYellow.visible = keycardYellow
	hudKeycardBlue.visible = keycardBlue

#INPUT
func _input(event):
	if dead:
		return
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * mouseSens)
		camera_3d.rotate_x(-event.relative.y * mouseSens)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad(90))

#STEP EVENT
func _process(delta): 
	update_tree()
	svp_camera_3d.set_global_transform(camera_3d.get_global_transform())
	
	hpGoto = lerpf(hpGoto,hp.current,0.1)
	UpdateHUD()
	
	Exit()
	Restart()
	
	if dead: return
	
	Run()
	DamageEffect()
	
	#shootSpd = lerp(shootSpd,shootVal,0.1)
	if Input.is_action_pressed("shoot"):
		Shoot()
	
	if Input.is_action_pressed("Weapon1"):
		ChangeWeapon(0)
	
	if Input.is_action_pressed("Weapon2"):
		ChangeWeapon(1)	
		
	if Input.is_action_just_released("ChangeWeaponUp"):
		ChangeWeaponScroll(true)	
		
	if Input.is_action_just_released("ChangeWeaponDown"):
		ChangeWeaponScroll(false)		
			
	if Input.is_action_just_pressed("Reload"):
	
		Reload()
	
	if changingWeapon:
		canShoot = false
		changingWeaponTimer.current -= delta
		if changingWeaponTimer.current <= 0:
			canShoot = true
			changingWeapon = false
			changingWeaponTimer.current = changingWeaponTimer.maximum

#RELOAD
func Reload():
	if reloading: return
	
	for w in Game.weapons:
		if w.index == Game.currentWeapon:
			if w.clip >= Game.weaponList[Game.currentWeapon].magSize:
				return
			if w.ammo <= 0: return
	
	reloading = true
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
	
#EXIT
func Exit():
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
#RESTART
func Restart():
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

#CHANGE WEAPON
func ChangeWeapon(type):
	#set all gun models invisible
	modelPistol.visible = false
	modelM4A1.visible = false
	modelPumpShotgun.visible = false
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
					
	Game.currentWeapon = type
	
	for w in Game.weapons:
		if w.index == Game.currentWeapon:
			
			if Game.currentWeapon == 0:
				sBullet.visible = false
				lblAmmo.text = ""
			else:
				sBullet.visible = true
				lblAmmo.text = str(w.clip, " | ", w.ammo)
			
	#shootTimerMax = Game.weaponList[type].cooldown
	canShoot = true
	reloading = false
	pass

#WEAPON CHANGE ON SCROLL WHEEL
func ChangeWeaponScroll(isUp):
	if isUp:
		Game.currentWeapon = (Game.currentWeapon + 1) % Game.weapons.size()
	else:
		Game.currentWeapon = (Game.currentWeapon - 1 + Game.weapons.size()) % Game.weapons.size()
	ChangeWeapon(Game.currentWeapon)
	pass

#HURT
func Hurt(dmg):
	if isHurt:
		return
	
	isHurt = true
	hp.current = hp.current - dmg
	hp.current = clamp(hp.current,0,hp.maximum)
	UpdateHUD()

#INCREASE HEALTH
func IncreaseHealth(amount):
	hp.current = hp.current + amount
	hp.current = clamp(hp.current,0,hp.maximum)

#DAMAGE EFFECT
func DamageEffect():
	if isHurt == false:
		return
	
	hudAnimPlayer.play("Pain")
	

#KILL
func Kill():
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

#RUN
func Run():
	if !reloading:
		runSpd = lerp(runSpd,runVal,0.1)
	
	if Input.is_action_pressed("run"):
		if is_on_floor:
			if !reloading:
				runVal = lerp(runVal,0.4,0.1)
		spd.current = spd.run
	else:
		if is_on_floor:
			if !reloading:
				runVal = lerp(runVal,0.2,0.1)
		spd.current = spd.default
	
	if !is_on_floor() || reloading:
		runVal = 0.0

#JUMP
func Jump():
	if is_on_floor():
		velocity.y = jumpHeight

#GRAVITY
func ApplyGravity(delta):
	if not is_on_floor():
		velocity.y -= grvty * delta

#SHOOT
func Shoot():
	
	for weapon in Game.weapons:
		if weapon.index == Game.currentWeapon:
			
			if weapon.clip <= 0:
				Reload()
				return
	
	if canShoot == false || reloading || changingWeapon :
		return
	canShoot = false
	instance = bullet.instantiate()
	instance.position = barrel.global_position
	instance.transform.basis = barrel.global_transform.basis
	get_parent().add_child(instance)
	anim_tree.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)	
	
	for weapon in Game.weapons:
		if weapon.index == Game.currentWeapon:
			
			#if weapon.clip <= 0: return
			
			weapon.clip -= 1
			lblAmmo.text = str(weapon.clip, " | ", weapon.ammo)
			if weapon.clip <= 0:
				Reload()
	
			print_debug('ammo: ' , weapon.clip , ' / ' , weapon.ammo)
	
	#if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("Kill"):
	#	ray_cast_3d.get_collider().Kill()

#SHOOT ANIM DONE
func ShootAnimDone():
	canShoot = true
	shootVal = 0.0
	#shootSpd = lerp(shootSpd,shootVal,0.1)

#PHYSICS PROCESS
func _physics_process(delta):
	# Gravity
	ApplyGravity(delta)
	
	# Jump
	if Input.is_action_just_pressed("jump"):
		Jump()
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		
		if direction:
			velocity.x = direction.x * spd.current
			velocity.z = direction.z * spd.current
		else:
			runVal = 0.0
			velocity.x = lerp(velocity.x,direction.x*spd.current, delta * frict)
			velocity.z = lerp(velocity.z,direction.z*spd.current, delta * frict)
	else:
		velocity.x = lerp(velocity.x,direction.x*spd.current, delta * jumpFrict)
		velocity.z = lerp(velocity.z,direction.z*spd.current, delta * jumpFrict)
	
	# Head Bobbing
	tBob += delta * velocity.length() * float(is_on_floor())
	camera_3d.transform.origin = HeadBob(tBob)
	
	move_and_slide()
	
func HeadBob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bobFreq) * bobAmp
	pos.x = cos(time * bobFreq / 2) * bobAmp
	return pos
	

func _on_update_hud_signal(message):
	hudInteract.text = message
	hudInteract.visible = true
	#print("update hud")
	pass # Replace with function body.

func _on_hide_hud_interact():
	hudInteract.visible = false
	#hudInteract.text = ""
	pass # Replace with function body.


func _on_animation_player_animation_changed(old_name, new_name):
	ShootAnimDone()
	#anim_tree.set("parameters/TimeSeek/seek_request", 0.0)
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name):
	#print_debug("sasdasadasdad")
	print_debug(anim_name)
	
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
