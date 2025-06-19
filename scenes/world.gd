extends Node3D

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
@onready var ProjectileScene = preload("res://scenes/projectile.tscn")
@export var level_filepath : String


# We need to wait for the build to finish before unwrapping mesh UV2s for lightmap baking.
# Currently lightmap baking cannot be performed at runtime, so it's not terribly useful yet.
# Consider creating a procedural Voxel GI solid class entity that can be baked at runtime instead.
func _build_complete() -> void:
	print("Success! Unwrapping UV2...")
	Signals.MapGenerated.emit()
	Console.enable()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED ## Hide the mouse	
	loading_map = false
	#%Game.unwrap_uv2()

func _build_failed() -> void:
	printerr("Failed to build the map file! :(")
	Console.print_line("Error generating map. Retrying...")
	get_tree().reload_current_scene()
	pass

func _unwrap_uv2_complete() -> void:
	pass

func ClearMap() -> void:
	for child in %Game.get_children():
		child.queue_free()

var load_map_timer := 0.0
var load_map_timer_max := 5.0
var loading_map := false
func LoadMap(map_filepath:String) -> void:
	loading_map = true
		
		
	Signals.MapGenerating.emit()
	Console.disable()
	ClearMap()
	Game.map_filepath = map_filepath
	
	%Game.connect("build_complete", _build_complete)
	%Game.connect("build_failed", _build_failed)
	%Game.connect("unwrap_uv2_complete", _unwrap_uv2_complete)
	%Game.local_map_file = Game.map_filepath
	%Game.verify_and_build()
	
func LoadMapPrebuilt(map_scenepath):
	ClearMap()
	var level_scene = load(map_scenepath)
	var level = level_scene.instantiate()
	%Game.add_child(level)
	
func UpdateWorldMapFile(map_name:String):
	var path = "res://maps/" + str(map_name) + ".map"
	
	if not FileAccess.file_exists(path):
		print_debug("Map file does not exist: " + map_name)
		Game.RoomGoto("res://scenes/main_menu.tscn")
		return null
	
	
	level_filepath = path
	
	LoadMap(level_filepath)
	
func MapGenerating():
	%GeneratingLevel.show()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	Signals.MapGenerating.connect(MapGenerating)
	
	level_filepath = Game.map_filepath
	
	if Game.map_build == Game.MAP_BUILD.PREBUILD:
		LoadMapPrebuilt("res://scenes/levels/level3.tscn")
		%GeneratingLevel.hide()
		Signals.MapGenerated.emit()
	elif Game.map_build == Game.MAP_BUILD.RUNTIME:
		LoadMap(level_filepath)
	
	
	Signals.SpawnProjectile.connect(SpawnProjectile)
	Signals.MapGenerated.connect(MapGenerated)
	Signals.UpdateWorldMapFile.connect(UpdateWorldMapFile)
	
	if Game.last_data != null: return ## dont update health/armor if there is a savefile being loaded
	
	match(Game.difficulty):
		Game.DIFFICULTY.EASY:
			Game.hp = { current=100, maximum=200 } 
			Game.armor = { current=0, maximum=200 }
		Game.DIFFICULTY.NORMAL:
			Game.hp = { current=100, maximum=100 } 
			Game.armor = { current=0, maximum=100 }
		Game.DIFFICULTY.HARD:
			Game.hp = { current=100, maximum=100 } 
			Game.armor = { current=0, maximum=50 }
		Game.DIFFICULTY.INSANE:
			Game.hp = { current=50, maximum=50 } 
			Game.armor = { current=0, maximum=0 }

	pass # Replace with function body.

func MapGenerated():
	%GeneratingLevel.hide()
	
	for node in %Game.get_children():
		print(str("NODE NAME: " + str(node.name)))
		
	for entity in Game.map_entities:
		print(str("ENTITY NAME: " + str(entity.targetname)))
		print(str("ENTITY COLLECTED: " + str(entity.collected)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if loading_map: load_map_timer += delta

	if load_map_timer >= load_map_timer_max:
		load_map_timer = 0.0
		get_tree().reload_current_scene()
	pass


#@export var power : int = 20
#@export var speed: float = 15.0
#@export var spin_speed : float = 10.0
#@export var destroy_distance: float = 1000.0
## spawn a projectile at will. its almost like a super power.
func SpawnProjectile(
	other:CharacterBody3D, 
	direction:Vector3, 
	style:Defs.PROJECTILE_TYPE=Defs.PROJECTILE_TYPE.ELECTRIC_BALL,
	power:int=20,
	speed:float=15.0,
	spin_speed:float=10.0,
	destroy_distance:float=1000.0
	):
		
	#print("Creating bullet")
	## create new projectile and add it to the game world in the Projectiles_Throwables node
	var inst : CharacterBody3D = ProjectileScene.instantiate()
	inst.direction = direction
	inst.power = power
	inst.speed = speed
	inst.spin_speed = spin_speed
	inst.destroy_distance = destroy_distance
	inst.current_projectile_type = style
	%Projectiles_Throwables.add_child(inst)
	
	## So things keep spawning projectiles inside of themselves
	## and theyre spawning in the ground so heres a hack to make it look less stupid
	var front_offset = -other.global_transform.basis.z.normalized() * 1.0 ## 1.0 unit in front of the spawner
	inst.global_position = other.global_position + front_offset
	inst.global_position.y += 1
	
	#print("proj created")
	#print(str(inst.global_position))
	
