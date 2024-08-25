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
		title = "No Weapon",
		power = 0,
		magSize = 0,
		spd = 0,
	},
	# 1 - PISTOL
	{
		title     = "Pistol",
		power     = 10,
		magSize = 15,
		spd = 100
	},
	# 2 - M4A1
	{
		title     = "M4A1",
		power     = 20,
		magSize = 30,
		spd = 200
	},
	# 3 - PUMP SHOTGUN
	{
		title     = "Pump Shotgun",
		power     = 50,
		magSize = 8,
		spd = 200
	},	
	# 4 - REVOLVER
	{
		title     = "Revolver",
		power     = 100,
		magSize = 6,
		spd = 200
	},
]

#List of players currently collected weapons, referencing index's of weaponList
#Each weapon in the array is an object and must contain
	#index [int] - Weapon index relative to weaponList array index order
	#ammo [int] - Current total ammo for the weapon the player currently has
var weapons = [
	{ index = 0,
	  ammo = 0,
	  clip = 0,
	},
	{ index = 1,
	  ammo = 100,
	  clip = 15,
	},
	{ index = 2,
	  ammo = 100,
	  clip = 30
	},	
	{ index = 3,
	  ammo = 80,
	  clip = 8
	},	
	{ index = 4,
	  ammo = 80,
	  clip = 6
	},
	]

#Current weapon index, according to weaponList index order
var currentWeapon = 0

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
