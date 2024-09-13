extends Node

#Player Save Data
var filename = "user://savefile.sav"
var godmode = false
var keycard = { red=false, yellow=false, blue=false }
var hp = { current=100, maximum=100 } 

#List of all weapons in game
var weaponList = [
	# 0 - NO WEAPON
	{
		index = 0,
		title = "No Weapon",
		melee = true,
		power = 0,
		magSize = 0,
		ammoPool = "null",
		spd = 0,
	},
	# 1 - PISTOL
	{
		index = 1,
		title     = "Pistol",
		melee = false,
		power     = 10,
		magSize = 15,
		ammoPool = "9mm",
		spd = 100
	},
	# 2 - Carbine
	{
		index = 2,
		title     = "Carbine",
		melee = false,
		power     = 20,
		magSize = 30,
		ammoPool = "carbine",
		spd = 200
	},
	# 3 - PUMP SHOTGUN
	{
		index = 3,
		title     = "Pump Shotgun",
		melee = false,
		power     = 50,
		magSize = 8,
		ammoPool = "shotgun",
		spd = 200
	},	
	# 4 - REVOLVER
	{
		index = 4,
		title     = "Revolver",
		melee = false,
		power     = 100,
		magSize = 6,
		ammoPool = "357",
		spd = 200
	},	
	  #5 - CROWBAR
	{
		index = 5,
		title     = "Crowbar",
		melee = true,
		power     = 100,
		magSize = 6,
		ammoPool = "null",
		spd = 200
	},	
	# 6 - SUB MACHINE GUN
	{
		index = 6,
		title     = "Sub Machine Gun",
		melee = false,
		power     = 20,
		magSize = 30,
		ammoPool = "9mm",
		spd = 200
	},	
	# 7 - KNIFE
	{
		index = 7,
		title     = "Knife",
		melee = true,
		power     = 100,
		magSize = 30,
		ammoPool = "null",
		spd = 200
	},	
	# 8 - MP
	{
		index = 8,
		title     = "MP",
		melee = false,
		power     = 100,
		magSize = 30,
		ammoPool = "9mm",
		spd = 200
	},
]

#List of players currently collected weapons, referencing index's of weaponList
#Each weapon in the array is an object and must contain
	#index [int] - Weapon index relative to weaponList array index order
	#ammo [int] - Current total ammo for the weapon the player currently has
var weapons = [
	{ index = 0,
	  clip = 0,
	},
	{ index = 1,
	  clip = 15,
	},
	{ index = 2,
	  clip = 30
	},	
	{ index = 3,
	  clip = 8
	},	
	{ index = 4,
	  clip = 6
	},	
	#{ index = 5,
	  #ammo = 80,
	  #clip = 6
	#},	
	{ index = 8,
	  clip = 6
	},		
	{ index = 7,
	  clip = 6
	},	
	]

#Current weapon index, according to weaponList index order
var currentWeapon = 0

var ammoPool = [
	{
		type = "9mm",
		ammo = 200
	},
	{
		type = "carbine",
		ammo = 100
	},
	{
		type = "shotgun",
		ammo = 100
	},
	{
		type = "357",
		ammo = 100
	},
	{
		type = "grenades",
		ammo = 10
	},
	{
		type = "rockets",
		ammo = 5
	}
	
]

func SaveGame():
	var file: FileAccess = FileAccess.open(filename, FileAccess.WRITE)
	var data = {
		hp = Game.hp,
		godmode = Game.godmode,
		keycard = Game.keycard,
		weapons = Game.weapons,
		currentWeapon = Game.currentWeapon
	}
	file.store_string(JSON.stringify(data))
	file.close()
	pass

func LoadGame():
	var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
	if FileAccess.file_exists(filename):
		var file = FileAccess.open(filename, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		print_debug(data)
		Game.hp = data.hp
		Game.godmode = data.godmode
		Game.keycard = data.keycard
		Game.weapons = data.weapons
		Game.currentWeapon = data.currentWeapon
		player.ChangeWeapon(data.currentWeapon)
		
	pass 
