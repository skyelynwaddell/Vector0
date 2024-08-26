extends NPC

@onready var animated_sprite_3d = $AnimatedSprite3D
@onready var sndDeath = $sndDeath
@onready var col = $CollisionShape3D
@export var power = 10
@export var hp = { current = 100, maximum = 100 }

var runSpd = 1.0
var attackSpd = 0.0
var deathSpd = 0.0

@onready var animTree = $alien1/AnimationTree

var dead = false

var IDLE = 0
var RUN = 1
var ATTACK = 2
var DEATH = 3
var state = IDLE

func State(delta):
	#state manager
	if state == IDLE:
		if distToPlayer < 10:
			state = RUN
	
	#state machine
	match(state):
		IDLE:
			runSpd = lerp(runSpd,.0,.1)
			attackSpd = lerp(attackSpd,.0,.1)
		RUN:
			AttemptToKillPlayer()
			runSpd = lerp(runSpd,1.0,.1)
			attackSpd = lerp(attackSpd,.0,.1)
			MoveToTarget(delta)
		ATTACK:
			runSpd = 0.0
			AttemptToKillPlayer()
			attackSpd = lerp(attackSpd,1.0,.2)
		DEATH:
			runSpd = 0.0
			deathSpd = lerp(deathSpd,1.0,.1)
			
func _process(delta):
	if player == null: return
	
	animTree["parameters/RunBlend/blend_amount"] = runSpd
	animTree["parameters/AttackBlend/blend_amount"] = attackSpd
	animTree["parameters/DeathBlend/blend_amount"] = deathSpd
		
	State(delta)
	
func Hurt(dmg):
	hp.current -= dmg
	if hp.current <= 0:
		Kill()

func Kill():
	state = DEATH
	dead = true
	sndDeath.play()
	animated_sprite_3d.play("death")
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
