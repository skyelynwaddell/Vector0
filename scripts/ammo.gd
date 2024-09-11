extends PickUp
class_name Ammo

@export_group("Ammo Properties")
## Ammo Amount this Pickup provides
@export var AmmoAmount = 100
## Select only one option (dont select NULL option!)
@export_enum(
	"NULL",
	"Pistol", 
	"Carbine",	
	"Shotgun",	 
	"365 Revolver",
	"NULL", 
	"Submachine Gun"
) var ammoType = 1

func _on_body_entered(body):
	print_debug(ammoType)
	# Prevent increases of ammo on melee weapons
	if ammoType == 0 || ammoType == 5: 
		print_debug("Invalid ammo type for pickup!")
		return
	
	# Check if player collided with Ammo
	if body.is_in_group("Player"):
		var isMelee = false
		var ammo = body.GetCurrentWeaponAmmoCount()
		var ammoPoolType = ""
		
		var SwitchAmmoType = func(type):
			ammoPoolType = type
			pass
			
		match(ammoType):
			0: SwitchAmmoType.call("null")
			1: SwitchAmmoType.call("9mm")
			2: SwitchAmmoType.call("carbine")
			3: SwitchAmmoType.call("shotgun")
			4: SwitchAmmoType.call("365")
			5: SwitchAmmoType.call("null")
			6: SwitchAmmoType.call("9mm")
			7: SwitchAmmoType.call("null")
		
		#Get our current weapon equipped
		var weapon = Game.weapons[Game.currentWeapon]
		
		# Find our weapon index, and if the current weapon is a melee weapon
		for i in Game.weaponList:
			if i.index == weapon.index:
				isMelee = i.melee
				pass
			
		# Check if we have max ammo already
		for i in Game.ammoPool:
			if i.type == ammoPoolType:
				var maxAmmo = 999
				if i.ammo >= maxAmmo: 
					print_debug("Max ammo already reached.")
					return
				
				# Increase ammo amount by pickup amount, and clamp ammo to max ammo
				i.ammo += AmmoAmount
				i.ammo = clamp(i.ammo,0,maxAmmo)
				pass
		
		# Update HUD & Remove self from scene
		if isMelee == false: body.UpdateHUDSignal.emit()
		queue_free()
		
		pass
