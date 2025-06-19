@tool
extends CharacterBody3D
class_name NPC

signal findtarget

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
#@onready var navAgent = $NavigationAgent3D
## The name of this entity
@export var targetname := name
## The target of this entity
@export var target = ""
## Max collision range between self and Player
@export var collisionRange = 3
## Movement Speed
@export var speed = 1
## Velocity
@export var vel = Vector3.ZERO
## Gravity
@export var grvty = 100
## The Max HP of this entity
@export var hp = 100
## The current HP of this entity on spawn.
@export var hpcurrent = 100

@export var difficulty_spawn := 0
@export var monster_group = ""

var stop_processing := false

var lag_timer_max = 1
var lag_timer = 0.0

func LagTimer(delta) -> bool:
	print("Lag Timer")
	if lag_timer >= lag_timer_max:
		lag_timer = 0.0
		return true
	return false
		

func _func_godot_apply_properties(props:Dictionary):
	print("applying parent props")
	rotation_degrees.y -= 90
	if "targetname" in props: targetname = props["targetname"] as String
	if "target" in props: target = props["target"] as String
	if "difficulty_spawn" in props: difficulty_spawn = props.difficulty_spawn as int
	if "monster_group" in props: monster_group = props.monster_group
	
	pass

var targetOrigin = null

var distToPlayer = 0
var direction = 0
var waittime = 0.1
var timer = 0.0

func GetTargetWalkPointOrigin():
	for walkPoint in get_tree().get_nodes_in_group(&"WalkPoint"):
		if str(walkPoint.targetname) == str(target): ## see if the walkpoint matches our current target walkpoint we are walking towards
			#print("Updated target origin to: " + str(walkPoint.position))
			target = walkPoint.targetname ## if it was update our target, to the walkpoint we just reached's target
			targetOrigin = walkPoint.position
	pass

func MoveToTarget(delta):
	print("Move To Target")
	if targetOrigin == null: 
		GetTargetWalkPointOrigin()
		if targetOrigin == null:
			return
		
	print("MOVE_TO_TARGET ---- Target Origin: " + str(targetOrigin))
	#timer += delta
	
	#if timer < float(waittime): return
	
	var direction = position.direction_to(targetOrigin)
	direction.y = 0
	
	var distance = transform.origin.distance_to(targetOrigin)
	if distance > 0.1:
		#print("moving to target")
		
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, delta * 5)  # Adjust the '5' to control rotation speed
	else:
		pass
		print("Distanced reached")
	#else:
		#velocity = Vector3.ZERO 
		#print("Reached target")
		#
	
func FacePlayer(delta, wait=true):
	print("Face Player")
	if wait==true and LagTimer(delta) == false: return
	if player == null: return
	var direction = position.direction_to(player.position)
	direction.y = 0
	var target_rotation = atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, delta * 5)  # Adjust the '5' to control rotation speed

func GetTarget(area):
	if area.is_in_group("WalkPoint"):
		#print("touched walkpoint")
		
		var _target = area.target ## this is the walkpoints target
		waittime = area.waittime
		timer = 0.0
		
		for walkPoint in get_tree().get_nodes_in_group(&"WalkPoint"):
			if str(walkPoint.targetname) == str(_target): ## see if the walkpoint matches our current target walkpoint we are walking towards
				print("Updated target origin to: " + str(walkPoint.position))
				target = _target ## if it was update our target, to the walkpoint we just reached's target
				targetOrigin = walkPoint.position
	pass
	
func on_trigger():
	print_debug("Triggered!")
	
func ApplyGravity(grvty,delta):
	print("Apply Gravity")
	if not is_on_floor():
		self.velocity.y -= grvty * delta
	else: self.velocity.y = 0
