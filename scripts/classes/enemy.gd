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

func _ready():
	if kia: state = DEATH

func Hurt(dmg):
	#if dead == true: return
	print_debug("hurt", hpcurrent)
	hpcurrent -= dmg
	if hpcurrent <= 0:
		Kill()

func Kill():
	state = DEATH
	dead = true
	self.remove_from_group("Enemy")
	if %Area3D: %Area3D.queue_free()
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
	
func AttemptToKillPlayer():
	if distToPlayer > collisionRange:
		return
		
	var eyeLine = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eyeLine, player.global_position+eyeLine, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		#state = ATTACK
		player.Hurt(power)
