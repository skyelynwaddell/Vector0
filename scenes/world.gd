extends Node3D

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
@onready var ProjectileScene = preload("res://scenes/projectile.tscn")
@export var level_filepath : String

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.map_filepath = level_filepath
	Signals.SpawnProjectile.connect(SpawnProjectile)
	
	var level_scene = load(level_filepath)
	var level = level_scene.instantiate()
	%Game.add_child(level)
	
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	
