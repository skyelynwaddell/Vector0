@tool
extends Switch

## Valves are special Entities, since they 
## have to be interacted with directly without a trigger,
## When the rotation amount is all the way Left (ON)
## It will tell it's Target Trigger Entity to be triggered.
## If it goes back all the way left, it will trigger the Trigger again.
## For example you can have pipe steam, when the valve is turned all the way to the left
## the steam will go away. If you turn it back all the way to the right,
## the valve will open and steam/smoke will start up again.

var rotAmt = 90
var distToPlayer = 0
var rotated = 0
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
# Ready
func _ready():
	if Engine.is_editor_hint(): return
	
	## Set default rotation to all the way right (off)
	rotation_degrees.z = rotAmt
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint(): return
	
	distToPlayer = transform.origin.distance_to(player.position)
	#print_debug(distToPlayer)
	if distToPlayer > 2: return
	
	## Toggle Turning Direction when Interact key pressed
	if Input.is_action_just_pressed("Interact"): 
		rotated = 0
		if state == ON: state = OFF 
		else: state = ON
	
	## If interact key is held down, Rotate the valve
	if Input.is_action_pressed("Interact"): rotateValve()
	pass

# Called when holding the Interact key to Rotate the valve
func rotateValve():
	## Check if the valve has power
	if state == NOPOWER: return
	
	if state == ON:
		## Rotate the valve counter clock-wise
		if rotation_degrees.z > -rotAmt: 
			rotation_degrees.z -= 1
			rotated -= 1
	else:
		## Rotate the valve clock-wise
		if rotation_degrees.z < rotAmt: 
			rotation_degrees.z += 1
			rotated += 1
	rotation_degrees.z = clamp(rotation_degrees.z, -rotAmt, rotAmt)
	
	## Turned the valve all the way on
	if (rotation_degrees.z <= -rotAmt && state == ON) || (rotation_degrees.z >= rotAmt && state == OFF): 
		#print_debug("trigger")
		if target and (rotated >= rotAmt || rotated <= -rotAmt):
			for _target in get_tree().get_nodes_in_group(&"Trigger"):
				#print_debug(_target)
				if "targetname" in _target:
					if _target.targetname == target:
						#print_debug("found trigger " , _target.targetname)
						_target.Trigger()
						rotated = 0
						break
	pass

func on_trigger():
	pass
