extends Enemy

@onready var animated_sprite_3d = $AnimatedSprite3D
@onready var sndDeath = $sndDeath
@onready var animTree = $alien1/AnimationTree

var RUN = 10

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
