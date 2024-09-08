@tool
extends CharacterBody3D
class_name NPC

signal findtarget

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
@onready var navAgent = $NavigationAgent3D
## The name of this entity
@export var targetname = name
## The target of this entity
@export var target = ""
## Max collision range between self and Player
@export var collisionRange = 2
## Movement Speed
@export var speed = 2
## Velocity
@export var vel = Vector3.ZERO
## Gravity
@export var grvty = 100
## The Max HP of this entity
@export var hp = 100
## The current HP of this entity on spawn.
@export var hpcurrent = 100

func _func_godot_apply_properties(props:Dictionary):
	rotation_degrees.y -= 90
	if "targetname" in props:
		targetname = props["targetname"] as String
	pass

var targetOrigin = null

var distToPlayer = 0
var direction = 0
var waittime = 1
var timer = 0.0

func MoveToTarget(delta):
	if targetOrigin == null: return
	timer += delta
	
	if timer < float(waittime): return
	
	var direction = position.direction_to(targetOrigin)
	direction.y = 0
	
	var distance = transform.origin.distance_to(targetOrigin)
	
	if distance > 0.1:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		move_and_slide()
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, delta * 5)  # Adjust the '5' to control rotation speed
	
	else:
		velocity = Vector3.ZERO 
	pass
	
func FacePlayer(delta):
	if player == null: return
	var direction = position.direction_to(player.position)
	direction.y = 0
	var target_rotation = atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, delta * 5)  # Adjust the '5' to control rotation speed

func GetTarget(area):
	if area.is_in_group("WalkPoint"):
		var _target = area.target
		waittime = area.waittime
		timer = 0.0
		
		for walkPoint in get_tree().get_nodes_in_group(&"WalkPoint"):
			if walkPoint.targetname == _target:
				target = _target
				targetOrigin = walkPoint.position
	pass
	
func on_trigger():
	print_debug("Triggered!")
	
func ApplyGravity(grvty,delta):
	if not is_on_floor():
		self.velocity.y -= grvty * delta
