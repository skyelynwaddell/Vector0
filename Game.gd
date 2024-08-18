extends Node

#Player Save Data
var playerData = {}

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
		power     = 100,
		magSize = 8,
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
	  clip = 30,
	},
	{ index = 2,
	  ammo = 100,
	  clip = 30
	},	
	{ index = 3,
	  ammo = 80,
	  clip = 8
	},
	]

#Current weapon index, according to weaponList index order
var currentWeapon = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
