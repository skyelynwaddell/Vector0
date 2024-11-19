extends Resource
class_name SaveData

@export var SAVEFILE = Game.filename
@export var godmode = Game.godmode
@export var keycard = Game.keycard
@export var weapons = Game.weapons
@export var currentWeapon = Game.currentWeapon

func SaveGame():
	#ResourceSaver.save(SAVEFILE,self)
	pass

func LoadGame():
	pass
