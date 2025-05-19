@tool
extends PickUp
class_name PickupWeapon

@export_group("Weapon Properties")
## Ammo Amount this Pickup provides
@export var AmmoAmount : int = 100
## Select only one option (dont select NULL option!)

@export_enum(
	"No Weapon",
	"Pistol",
	"Carbine",
	"Pump Shotgun",
	"Revolver",
	"Crowbar",
	"Sub Machine Gun",
	"Knife",
	"MP"
) var weaponType : int = 1

@onready var sfxplayer
@onready var soundeffect : AudioStreamOggVorbis = preload("res://audio/pickup.ogg")

var shouldDestroy = false

func _ready():
	sfxplayer = AudioStreamPlayer2D.new()
	self.add_child(sfxplayer)
	SetSFX(soundeffect)
	pass
	
func SetSFX(sfx):
	sfxplayer.set_stream(sfx)
	sfxplayer.set_volume_db(-10)
	sfxplayer
	pass

func _func_godot_apply_properties(props:Dictionary):
	if "amount" in props: AmmoAmount = props.amount as int
	pass

func _on_body_entered(body):
	if body == null: return
	
	# Check if player collided with Ammo
	if body.is_in_group("Player"):
		
		self.visible = false
		
		print_debug("Picking up weapon!!")
		if sfxplayer.playing == false:
			shouldDestroy = true
			sfxplayer.play()
		
		var isMelee : bool = false
		var ammoPoolType = null
		
		match(weaponType):
			0: ammoPoolType = null
			1: ammoPoolType = "9mm"
			2: ammoPoolType = "carbine"
			3: ammoPoolType = "shotgun"
			4: ammoPoolType = "357"
			5: ammoPoolType = null
			6: ammoPoolType = "9mm"
			7: ammoPoolType = null
			8: ammoPoolType = "9mm"
		
		# check if the player has the weapon already
		var hasweapon = false
		for weapon in Game.weapons:
			if weapon.index == weaponType:
				hasweapon = true
				pass
				
		if (hasweapon == false):
			var newweapon = {
				index = weaponType,
				clip = Game.weaponList[weaponType].magSize # start with a full clip
			}
			Game.weapons.append(newweapon)
			print_debug("Player got: " + Game.weaponList[weaponType].title)
		
		#we dont need ammo if it was a melee weapon so return here
		if ammoPoolType == null: return
		
		#Get our current weapon equipped
		var weapon = Game.weapons[Game.currentWeapon]
		
		# Find our weapon index, and if the current weapon is a melee weapon
		for i in Game.weaponList:
			if i.index == weapon.index:
				isMelee = i.melee
				pass
		
		# Check if we have max ammo already
		for i in Game.ammoPool:
			#check if we have this ammo type in our inventory
			if i.type == ammoPoolType:
				print_debug("found type")
				var maxAmmo = 999
				if i.ammo >= maxAmmo: 
					print_debug("Max ammo already reached.")
					return
				
				# Increase ammo amount by pickup amount, and clamp ammo to max ammo
				i.ammo += AmmoAmount
				i.ammo = clamp(i.ammo,0,maxAmmo)
				print_debug(i.ammo)
				pass
		
		# Update HUD & Remove self from scene
		if isMelee == false: Signals.UpdateHUD.emit()
		#queue_free()
		pass

func _process(delta):
	if Engine.is_editor_hint() : return
	if shouldDestroy && sfxplayer.playing == false: queue_free()
	pass
