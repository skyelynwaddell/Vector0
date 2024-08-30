extends NPC
class_name Enemy

@onready var col = $CollisionShape3D
## The Power/Strength of this Enemy
@export var power = 10


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

func Hurt(dmg):
	print_debug("hurt", hpcurrent)
	hpcurrent -= dmg
	if hpcurrent <= 0:
		Kill()

func Kill():
	state = DEATH
	dead = true
	#sndDeath.play()
	col.disabled = true
	
func AttemptToKillPlayer():
	if distToPlayer > collisionRange:
		state = IDLE
		return
		
	var eyeLine = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eyeLine, player.global_position+eyeLine, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		state = ATTACK
		player.Hurt(power)
