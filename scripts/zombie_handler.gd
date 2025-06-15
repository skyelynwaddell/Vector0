extends Node3D
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta):
	#if Engine.is_editor_hint(): return
	#
	#var zombies = get_tree().get_nodes_in_group("Zombie")
	#
	#for z in zombies:
		##z.distToPlayer = z.transform.origin.distance_to(z.player.position)
		#
		#if z.attackDuration > z.attackDurationMax:
			#z.hasSpit = false
			#z.attackDuration = 0.0
			#z.ChangeState(z.CHASEPLAYER)
		#
		#match(z.state):
			#z.IDLE:
				#if z.distToPlayer > z.chaseDistance: 
					#z.GibsStop()
					#return
				#if not z.is_on_floor(): z.velocity.y -= z.grvty * delta
				#z.move_and_slide()
				#z.animTree.set("parameters/Walk/blend_amount", 0.0)
				#if z.distToPlayer <= z.chaseDistance && z.shouldChase:
					#z.ChangeState(z.CHASEPLAYER)
				#pass
				#
			#z.WALK:
				#if z.distToPlayer > z.chaseDistance: 
					#z.GibsStop()
					#return
				#z.ApplyGravity(z.grvty,delta)
				#z.move_and_slide()
				#z.animTree.set("parameters/Walk/blend_amount", 1.0)
				#pass
			#z.ATTACK:
				#if z.distToPlayer > z.chaseDistance: 
					#z.GibsStop()
					#return
				#z.state = z.CHASEPLAYER
				#
				#z.ApplyGravity(z.grvty,delta)
				#z.move_and_slide()
				#z.animTree.set("parameters/Attack/blend_amount", 1.0)
				#z.FacePlayer(delta)
				#pass
			#z.DEATH:
				#if z.get_node("Breath").playing: z.get_node("Breath").playing = false
				#
				### Destroy our attack hitbox when the zombie dies so we cant cheeze the player out  a free shot after its already dead
				#if z.current_hb != null:
					#if z.current_hb.has_method("queue_free"):
						#z.current_hb.queue_free()
				#
				#z.EmitGibs()
				#z.ApplyGravity(z.grvty,delta)
				#
				#z.velocity.x = 0
				#z.velocity.z = 0
				#z.move_and_slide()
				#
				#z.animTree["parameters/Walk/blend_amount"] = 0.0
				#z.animTree["parameters/Attack/blend_amount"] = 0.0
				#z.animTree["parameters/Death/blend_amount"] = 1.0
				#
				#pass
			#z.CHASEPLAYER:
				#if z.distToPlayer > z.chaseDistance: 
					#z.GibsStop()
					#return
				#z.AttemptToKillPlayer()
				#if z.hpcurrent <= 0: z.ChangeState(z.DEATH)
				#
				#z.target = z.player
				#z.targetOrigin = z.target.position
				#z.animTree.set("parameters/Walk/blend_amount", 1.0)
				#z.ApplyGravity(z.grvty,delta)
				#z.FacePlayer(delta)
				#z.MoveToTarget(delta)
				#
				#z.attackTimer += delta
				#if z.attackTimer >= z.attackTimerMax and z.distToPlayer <= z.attackDistance:
					#z.ChangeState(z.DO_ATTACK)
					#z.attackTimer = 0
					#
				#pass
			#z.DO_ATTACK:
				#if z.distToPlayer > z.chaseDistance: 
					#z.GibsStop()
					#return
				#z.AttemptToKillPlayer()
				#z.attackBlend = lerp(z.attackBlend,1.0,0.1)
				#z.animTree.set("parameters/Attack/blend_amount",z.attackBlend)
				#
				#z.ApplyGravity(z.grvty,delta)
				#z.FacePlayer(delta)
				#
				#z.attackDuration += delta
			#
				#
				#if z.attackDuration >= 0.6 and not z.hasSpit:
					#z.hasSpit = true
					#z.get_node("Growl").stop()
					#z.get_node("Growl").play()
					##var player_dir = Game.GetDirectionToPlayer(z)
