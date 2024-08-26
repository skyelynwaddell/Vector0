extends CharacterBody3D
class_name NPC

signal findtarget

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
@onready var navAgent = $NavigationAgent3D
@export var targetname = name
@export var target = ""
@export var collisionRange = 2
@export var speed = { current=2, walk=2, run=5 }
@export var vel = Vector3.ZERO
@export var grvty = 100

var targetOrigin = null

var distToPlayer = 0
var direction = 0
var waittime = 1
var timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func MoveToTarget(delta):
	if targetOrigin == null: return
	timer += delta
	
	if timer < float(waittime): return
	
	var direction = global_position.direction_to(targetOrigin)
	var playerDirection = global_position.direction_to(player.position)
	direction.y = 0
	
	var distance = global_transform.origin.distance_to(targetOrigin)
	distToPlayer = global_transform.origin.distance_to(player.position)
	
	if distance > 0.1:
		velocity = direction * speed.current
		move_and_slide()
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, delta * 5)  # Adjust the '5' to control rotation speed
	
	else:
		velocity = Vector3.ZERO 
	pass
	
func FacePlayer(delta):
	if player == null: return
	var direction = global_position.direction_to(player.position)
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
	
