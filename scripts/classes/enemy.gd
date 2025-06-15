extends NPC
class_name Enemy

@onready var col = $CollisionShape3D
## The Power/Strength of this Enemy
@export var power = 10
## killed in action (already dead at spawn)
@export var kia = false

var runSpd = 1.0
var attackSpd = 0.0
var deathSpd = 0.0
var dead = false
var shouldChase = false

var CHASEPLAYER = -50
var IDLE = -40
var WALK = -30
var DEATH = -20
var ATTACK = -10

var state = IDLE

var emitted_once = false

func _ready():
	Signals.UpdateEnemyStats.connect(UpdateEnemyStats)
	if kia: state = DEATH

func Hurt(dmg):
	#if dead == true: return
	print_debug("hurt", hpcurrent)
	hpcurrent -= dmg
	if hpcurrent <= 0:
		Kill()
		
		
		
func UpdateEnemyStats():
	if targetname == "": return
	
	var data = GetEnemyData()
	
	for i in range(Game.enemies_in_map.size()):
		var e = Game.enemies_in_map[i]
		
		if str(e.targetname) == str(name):
			#print("updating " + str(name) + "'s stats to " + str(data))
			Game.enemies_in_map[i] = data.duplicate(true)
			return
			
	Game.enemies_in_map.push_back(data)
	
func LoadEnemy():
	for e in Game.enemies_in_map:
		if str(e.targetname) == str(name):
		
			global_position = Vector3(e.position.x, e.position.y, e.position.z)
			state = int(e.state)
			hpcurrent = int(e.hp)
			hp = int(e.hp_max)
			speed = float(e.speed)
			global_rotation = Vector3(e.rot.x, e.rot.y, e.rot.z)
			
			if state == DEATH: Kill()
			
			return
	
	var data = GetEnemyData()
	Game.enemies_in_map.push_back(data)

func GetEnemyData():
	var data = {
		"targetname" : name,
		"state" : state,
		"position" : { "x" : global_position.x, "y" : global_position.y, "z" : global_position.z, },
		"rot" : { "x": global_rotation.x, "y": global_rotation.y, "z": global_rotation.z, },
		"hp" : hpcurrent,
		"hp_max" : hp,
		"speed": speed,
	}
	return data

@onready var area = %Area3D
func Kill():
	state = DEATH
	dead = true
	self.remove_from_group("Enemy")
	if area != null and area is not bool: area.queue_free()
	#sndDeath.play()
	
	self.set_collision_layer_value(1, false)
	self.set_collision_layer_value(2, false)
	self.set_collision_layer_value(3, false)
	self.set_collision_layer_value(4, false)
	self.set_collision_mask_value(2,false)
	self.set_collision_mask_value(3,false)
	self.set_collision_mask_value(4,false)
	
	for node in self.get_children():
		if node is Area3D:
			node.set_collision_layer_value(2, false)
			node.set_collision_layer_value(3, false)
			node.set_collision_layer_value(4, false)
			node.set_collision_mask_value(1,false)
			node.set_collision_mask_value(2,false)
			node.set_collision_mask_value(3,false)
			node.set_collision_mask_value(4,false)
	
	#w
	pass

var should_attack = false
func AttemptToKillPlayer():
	if distToPlayer > collisionRange:
		return
		
	var eyeLine = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eyeLine, player.global_position+eyeLine, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		#state = ATTACK
		player.Hurt(power)
		should_attack = true
