extends Node

enum DIFFICULTY {
	EASY=1, 
	NORMAL=2, 
	HARD=4, 
	INSANE=8
}
@export var difficulty = DIFFICULTY.NORMAL

#Player Save Data
var game_name := "vector0"
var map_name := "e1m1"
var map_filepath := "" ## current level
var next_map_filepath = "" ## next level once we hit a changelevel trigger

var secrets := { current = 0, total = 3 }
var filename = "user://savefile.sav"
var godmode = false
var keycard = { red=false, yellow=false, blue=false }
var hp = { current=100, maximum=200 } 
var armor = { current=0, maximum=200 }
var in_game := false
var paused := false
var enemies_in_map = []
var map_entities = [] ## all the entities not including the enemies --- any static item, pickup, etc
var doors = []
var texture_mode := Defs.TEXTURE_MODE.LINEAR
@onready var gamefont = preload("res://fonts/hunter.ttf")

@onready var PopupMessageScene = preload("res://scenes/popup_message.tscn")
@onready var LevelEnterTextScene = preload("res://scenes/map_intro_text.tscn")

signal UpdateHUD

func IsPaused(): return paused

func RoomGoto(scene_path:String):
	get_tree().change_scene_to_file(scene_path);

@onready var LoadingScreenScene = preload("res://scenes/loading_screen.tscn")
func CreateLoadingScreen():
	var loading_screen = LoadingScreenScene.instantiate()
	add_child(loading_screen)
	
@onready var GameOverScene = preload("res://scenes/game_over.tscn")
func CreateGameOverScreen():
	var go = GameOverScene.instantiate()
	add_child(go)
	
var lights_on := true
func LightsToggle():
	var lights = get_tree().get_nodes_in_group("Light")
	
	for light in lights:
		if lights_on:
			light.hide()
		else:
			light.show()
	
	if lights_on:
		Signals.EmissionSet.emit(4)
	else:
		Signals.EmissionSet.emit(2)
	

func GetDirectionToPlayer(other) -> Vector3:
	var player = get_tree().get_first_node_in_group("Player")
	var playerpos = player.global_transform.origin
	var currentpos = other.global_transform.origin
	var dir = (Vector3(playerpos.x, currentpos.y, playerpos.z) - currentpos).normalized()
	return dir

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
		spd = 300
	},
	# 3 - PUMP SHOTGUN
	{
		index = 3,
		title     = "Pump Shotgun",
		melee = false,
		power     = 50,
		magSize = 8,
		ammoPool = "shotgun",
		spd = 500
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
		spd = 400
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
		spd = 400
	},	
	# 9 - Pump 2
	{
		index = 9,
		title     = "Pump Shotgun",
		melee = false,
		power     = 50,
		magSize = 6,
		ammoPool = "shotgun",
		spd = 400
	},	
	# 10 - Pistol 2
	{
		index = 10,
		title     = "9mm Pistol",
		melee = false,
		power     = 20,
		magSize = 15,
		ammoPool = "9mm",
		spd = 400
	},
]
var weaponListDefault = weaponList.duplicate(true)

#List of players currently collected weapons, referencing index's of weaponList
#Each weapon in the array is an object and must contain
	#index [int] - Weapon index relative to weaponList array index order
	#ammo [int] - Current total ammo for the weapon the player currently has
var weapons = [
	{ index = 0, ## Give the player hands 
	  clip = 0,
	},	
	
	{ index = 7, ## Give the playe a knoife
	  clip = 0,
	},

	{
		index = 10,
		clip = 15,
	},	
	
	#{
		#index = 10,
		#clip = 15,
	#},
	
	#{ index = 1,
	  #clip = 15,
	#},
	#{ index = 2,
	  #clip = 30
	#},	
	#{ index = 3,
	  #clip = 8
	#},	
	#{ index = 4,
	  #clip = 6
	#},	
	##{ index = 5,
	  ##ammo = 80,
	  ##clip = 6
	##},	
	#{ index = 8,
	  #clip = 6
	#},		
	#{ index = 7,
	  #clip = 6
	#},	
	]
var weaponsDefault = weapons.duplicate(true)

#Current weapon index, according to weaponList index order
var currentWeapon = 0

var ammoPool = [
	{
		type = "9mm",
		ammo = 100
	},
	{
		type = "carbine",
		ammo = 0
	},
	{
		type = "shotgun",
		ammo = 0
	},
	{
		type = "357",
		ammo = 0
	},
	{
		type = "grenades",
		ammo = 0
	},
	{
		type = "rockets",
		ammo = 0
	}
	
]
var ammoPoolDefault = ammoPool.duplicate(true)

func _ready() -> void:
	ammoPoolDefault = ammoPool.duplicate(true)
	weapons = weaponsDefault.duplicate(true)
	weaponList = weaponListDefault.duplicate(true)

#var map_name := "e1m1"
#var secrets := { current = 0, total = 3 }
#var filename = "user://savefile.sav"
#var godmode = false
#var keycard = { red=false, yellow=false, blue=false }
#var hp = { current=100, maximum=200 } 
#var armor = { current=0, maximum=200 }

func RestartLevel():
	last_data = null
	currentWeapon = 0
	weapons = weaponsDefault.duplicate(true)
	ammoPool = ammoPoolDefault.duplicate(true)
	weaponList = weaponListDefault.duplicate(true)

	
	Game.in_game = true; 
	Game.paused = false;
	enemies_in_map = []
	map_entities = []
			
	print("Going to level1 for now")
			
	Game.CreateLoadingScreen()


## Deletes all saves 
func DeleteSaves():
	var file: FileAccess = FileAccess.open(filename, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"saves":[]
	}))
	file.close()


var current_save_name = ""
func CreateSaveName() -> String:
	var _savename = Time.get_datetime_string_from_system()
	_savename = _savename.replace(":", "-").replace("/", "_").replace("T","_")
	return _savename
	

## Creates a new save game + save name if save_name is left blank, or else it overwrites the save file with the specified name
func SaveGame(save_name:=""):
	Signals.UpdateEnemyStats.emit()
	Signals.DoorUpdateEntity.emit()

	var player = get_tree().get_first_node_in_group("Player")
	
	var _file = null
	var _data = null
	if FileAccess.file_exists(filename):
		_file = FileAccess.open(filename, FileAccess.READ)
		_data = JSON.parse_string(_file.get_as_text())
		_file.close()
		
	else:
		var file = FileAccess.open(filename, FileAccess.WRITE)
		_data = {"saves":[]}
	
	## We are going to create a new save slot in this instance
	if save_name == "":
		## Save the new save file with the current date time
		current_save_name = CreateSaveName()
		#print("Save Data Recording to slot... " + str(current_save_name))
		
	else:
		current_save_name = save_name
	
	var current_save = null
	var sc = await Game.ScreenshotTake(current_save_name)
	
	var data = {
		"save_name" = Game.current_save_name,
		"screenshot" = sc,
		"map_filepath" = Game.map_filepath,
		"hp" = Game.hp,
		"godmode" = Game.godmode,
		"keycard" = Game.keycard,
		"weapons" = Game.weapons,
		"currentWeapon" = Game.currentWeapon,
		"ammoPool" = Game.ammoPool,
		
		"map_name" = Game.map_name,
		"armor" = Game.armor,
		"secrets" = Game.secrets,
		
		"enemies_in_map" = Game.enemies_in_map,
		"map_entities" = Game.map_entities,
		"doors" = Game.doors,
		
		"player_pos" = { "x" : player.global_position.x, "y": player.global_position.y, "z": player.global_position.z },
		"player_rot" = { "x" : player.get_node("HeadOGPosition/Head").rotation_degrees.x, "y": player.get_node("HeadOGPosition/Head").rotation_degrees.y, "z": player.get_node("HeadOGPosition/Head").rotation_degrees.z }
		
		## TODO: Save current level
		## TODO: Save current player position
	}
	
	#print("Enemies in map: " + str(enemies_in_map))
	
	if _data == null: _data = { "saves":[] }
	if not _data.has("saves") or _data["saves"] == null:
		_data["saves"] = []
	
	for i in range(_data.saves.size()):
		
		if _data.saves[i].has("save_name") == false: continue
		if str(_data.saves[i].save_name) == str(save_name): 

			#print("Saved game")
			#print(current_save)
			##update save date + time
			var _savename = CreateSaveName()
			data.save_name = _savename
			save_name = _savename
			Game.current_save_name = _savename
			
			## take another screen shot unfortunately
			sc = await Game.ScreenshotTake(current_save_name)
			data.screenshot = sc
			
			_data.saves[i] = data ## Update the save because we already have a save file
			current_save = data
			#print("updated save")
			break
	
	if current_save == null:
		## No save was found add the data to the array
		_data.saves.push_front(data)
	
	
	#print("Saved Weapons: " + str(data.weapons))
	#print("Saved Current Weapon: " + str(data.currentWeapon))
	
	if _file != null:
		_file.close()
	
	var file: FileAccess = FileAccess.open(filename, FileAccess.WRITE)
	file.store_string(JSON.stringify(_data))
	file.close()
	Console.print_line("Game Saved.")
	pass


var last_data = null ## last loaded data from save
func LoadGame(save_name:String=""):
	var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
	if FileAccess.file_exists(filename):
		var file = FileAccess.open(filename, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		#print("LOADED DATA: " + str(data))
		
		
		for save in data.saves:
			#print("LOADED SAVE DATA : " + str(save))
			if save.has("save_name") == false: continue
			
			if str(save.save_name) == str(save_name):
				last_data = save.duplicate(true)
		
		file.close()
		#print_debug(data)
		
		Console.disable()
		Console.enable()
		Game.in_game = true

		Console.print_line("Save File Loaded.")
		Game.CreateLoadingScreen()
		
func GetSaveData() -> Dictionary:
	if FileAccess.file_exists(filename):
		var file = null
		file = FileAccess.open(filename, FileAccess.READ)
		
		if file == null:
			file = FileAccess.open(filename, FileAccess.WRITE)
			file.close()
			return {"saves": []}
		
		var raw_text = file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(raw_text)
		if data == null:
			return {"saves": []}
			
		return data.duplicate(true)
	else:
		var file = FileAccess.open(filename, FileAccess.WRITE)
		file.close()
	return {"saves":[]}
		

## After LoadGame is called and the map is loaded and everything initializes
## The player calls this to update the data to the last_data 
func GetData(player):
	var data = null
	
	print("Loading Save")
	
	data = last_data.duplicate(true)
			
	if data == null:
		printerr("Cannot find any save data")
		return
	
	Game.map_filepath = data.map_filepath
	Game.hp = data.hp if "hp" in data else { current=100, maximum=100 } 
	Game.godmode = data.godmode if data.has("godmode") else false
	Game.keycard = data.keycard if data.has("keycard") else { red=false, yellow=false, blue=false }
	Game.weapons = data.weapons if data.has("weapons") else weaponsDefault.duplicate(true)
	Game.currentWeapon = data.currentWeapon if data.has("currentWeapon") else 0
	
	var _weapon = Game.weapons[Game.currentWeapon]
	var weaponIndex = _weapon.index
	
	#print("Loaded Weapon Index: " + str(weaponIndex))
	
	#print("Loaded Weapons: " + str(Game.weapons))
	#print("Loaded Current Weapon: " + str(Game.currentWeapon))
	#if Game.keycard.red == true: UnlockKeyDoor("door_red")
	#if Game.keycard.yellow == true: UnlockKeyDoor("door_yellow")
	#if Game.keycard.blue == true: UnlockKeyDoor("door_blue")
	
	Game.map_name = data.map_name if "map_name" in data else "E1M1"
	Game.armor = data.armor if "armor" in data else { current=0, maximum=200 }
	Game.secrets = data.secrets if "secrets" in data else { current = 0, total = 3 }
	Game.ammoPool = data.ammoPool if data.has("ammoPool") else ammoPoolDefault.duplicate(true)
	
	if data.has("enemies_in_map"): Game.enemies_in_map = data.enemies_in_map
	if data.has("map_entities"): Game.map_entities = data.map_entities
	if data.has("doors"): Game.doors = data.doors
	
	var map = get_tree().get_first_node_in_group("Map")

	### load all the entities
	if map_entities.is_empty() == false:
		for entity in map_entities:
			
			for child in map.get_children():
				if child.is_in_group("Entity") == false or child.is_in_group("Enemy") or child.is_in_group("Door"): continue
				
				print("Entity: " + str(child.name) + "\n")
				
				if str(child.name) == str(entity.targetname):
					if str(entity.collected) == "1": child.queue_free()
					
					child.global_position = Vector3(entity.position.x,entity.position.y,entity.position.z)
					child.global_rotation = Vector3(entity.rotation.x,entity.rotation.y,entity.rotation.z)
					

	
	## make sure we have killed some enemies
	if Game.enemies_in_map.is_empty() == false:
		## find each enemy in the list we have killed
		for enemy in Game.enemies_in_map:
			
			#print("Attempting to destroy monster: " + str(enemy.targetname))
			## find each enemy with the same name in the map as one from the list
			
			for child in map.get_children():
				if child is CharacterBody3D == false: continue ## make sure this is a character body
				if child.is_in_group("Enemy") == false: continue
				if "targetname" not in child: continue
				
				#print("Passed checks!, comparing " + str(child.targetname) + " vs " + str(enemy.targetname))
				
				##find matching enemy
				if str(child.name) == str(enemy.targetname):		
					if child.has_method("LoadEnemy"): child.LoadEnemy()
					
		
	for d in map.get_children():
		if d.has_method("SetDoorProperties") == false: continue
		d.SetDoorProperties()
	
	## TODO Set player position
	if "player_pos" in data: 
		player.global_position = Vector3(
			float(data.player_pos.x),
			float(data.player_pos.y),
			float(data.player_pos.z),
		)
		
	if "player_rot" in data:
		player.get_node("HeadOGPosition/Head").rotation_degrees = Vector3(
			float(data.player_rot.x),
			float(data.player_rot.y),
			float(data.player_rot.z),
		)
		
		
	return weaponIndex

func EntityData(node:Node3D, collected:=0):
	var data = {
		"targetname" = node.name,
		"position" = { "x":node.global_position.x,"y":node.global_position.y,"z":node.global_position.z},
		"rotation" = { "x":node.global_rotation.x,"y":node.global_rotation.y,"z":node.global_rotation.z},
		"collected" = collected,
	}
	return data

func UpdateEntity(node:Node3D, collected:=0):
	var data = EntityData(node, collected)
	
	for i in range(map_entities.size()):
		var e = map_entities[i]
		if str(e.targetname) == str(data.targetname):
			if str(collected) != "0":
				map_entities[i] = data.duplicate(true)
			return
	
	map_entities.push_back(data.duplicate(true))

func UnlockKeyDoor(door_name:String):
	
	## unlock the doors for the keys we already have
	for entity in get_tree().get_nodes_in_group(&"Entity"):
		if "targetname" in entity:
			if entity.targetname == door_name:
				entity.locked = false
				entity.lockstatus = 0
				break
	
	var node_group = "Keycard_Red"
	match(door_name):
		"door_red": node_group = "Keycard_Red"
		"door_yellow": node_group = "Keycard_Yellow"
		"door_blue": node_group = "Keycard_Blue"
		
	## delete the keys from the map so we dont have to collect them again
	for entity in get_tree().get_nodes_in_group(&"Entity"):
		if entity.is_in_group(node_group):
			entity.queue_free()
	
	Signals.UpdateHUD.emit()
	
	
func PopupMessageCreate(message:String):
	var popup_scene = PopupMessageScene.instantiate()
	popup_scene.message = message
	
	add_child(popup_scene)
	
	
func EnterLevelTextCreate(message:String):
	var entertext_scene = LevelEnterTextScene.instantiate()
	entertext_scene.get_node("Label").text = message
	
	add_child(entertext_scene)

@onready var Audio3DScene = preload("res://scenes/3d_audio.tscn")
func Audio3DCreate(audio, caller, volume_db=5.0):
	print("Creating audio stream player 3d...")
	var audioplayer = Audio3DScene.instantiate()
	var player = get_tree().get_first_node_in_group("Player")
	player.add_child(audioplayer)
	audioplayer.SetAudio(audio, caller, volume_db)
	

func ShouldDestroyIfDifficultyFlagSet(difficulty_spawn) -> bool:
	var should_destroy = false
	match(difficulty):
		DIFFICULTY.EASY:
			if (difficulty_spawn == 1 or
				difficulty_spawn == 3 or
				difficulty_spawn == 5 or
				difficulty_spawn == 9 or
				difficulty_spawn == 7 or
				difficulty_spawn == 11 or
				difficulty_spawn == 15
			): 
				should_destroy = true 
			
		DIFFICULTY.NORMAL:
			if (difficulty_spawn == 2 or
				difficulty_spawn == 3 or
				difficulty_spawn == 6 or
				difficulty_spawn == 7 or
				difficulty_spawn == 10 or
				difficulty_spawn == 14 or
				difficulty_spawn == 15
			): 
				should_destroy = true 
				
		DIFFICULTY.HARD:
			if (difficulty_spawn == 4 or
				difficulty_spawn == 5 or
				difficulty_spawn == 6 or
				difficulty_spawn == 12 or
				difficulty_spawn == 7 or
				difficulty_spawn == 15 or
				difficulty_spawn == 13
			):
				should_destroy = true
				
		DIFFICULTY.INSANE:
			if (difficulty_spawn == 8 or
				difficulty_spawn == 12 or
				difficulty_spawn == 10 or
				difficulty_spawn == 9 or
				difficulty_spawn == 14 or
				difficulty_spawn == 13 or
				difficulty_spawn == 11 or
				difficulty_spawn == 15
			
			):
				should_destroy = true
				
	return should_destroy

func DestroyOnDifficultyFlag(difficulty_spawn, caller):
	#print("difficulty spawn: ", str(difficulty_spawn))
		
	var should_destroy = Game.ShouldDestroyIfDifficultyFlagSet(difficulty_spawn)
	if should_destroy: caller.queue_free()
	
func ScreenshotTake(save_name: String) -> String:
	
	var save_dir = "user://saves"
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_absolute(save_dir)

	var sc_path = save_dir + "/" + save_name + "-sc.png"
	var image = get_viewport().get_texture().get_image()
	var err = image.save_png(sc_path)

	if err != OK:
		push_error("Failed to save screenshot to: " + sc_path)
	else:
		print("Screenshot saved to: ", sc_path)
		
	Signals.HUDShow.emit()

	return sc_path
