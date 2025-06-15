extends Resource
class_name SaveData

@export var SAVEFILE = Game.filename
var godmode = Game.godmode
var keycard = Game.keycard
var weapons = Game.weapons
var currentWeapon = Game.currentWeapon

func SaveGame():
	#ResourceSaver.save(SAVEFILE,self)
	pass

func LoadGame():
	pass
