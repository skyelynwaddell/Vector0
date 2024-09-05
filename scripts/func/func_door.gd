@tool
extends StaticBody3D

## Target Name
@export var targetname = ""
## Type 0=UP 1=DOWN 2=LEFT 3=RIGHT
@export var direction = 0 
## Size of the Door, and how far it should be opened
@export var opensize = 2.0
## Set if the door should spawn opened or not
@export var open = 0
## Type of Door 0=Sliding 1=Rotating
@export var type = 0
## Should Automatically Close when Player is too far 0=FALSE 1=TRUE
@export var autoClose = 0
## Locked determines if this door needs to be opened by a trigger first | 0 = Unlocked | 1 = "Locked and can only open WHEN triggered" | 2 = "Locked and can only open on Interact AFTER triggered"
@export var locked = 0
var currentlyLocked = 0

## Determines which way the door should rotate (only applies to rotating doors)
@export var rotatedir = 0

@export var speed = 0.0

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
var distToPlayer = 0
var initPos = Vector3.ZERO
var rotAmt = 90
var timer = 0

func _func_godot_apply_properties(props:Dictionary):
	if "direction" in props: direction = props.direction as int
	if "opensize" in props: opensize = props.opensize as float
	if "open" in props: open = props.open as int
	if "targetname" in props: targetname = props.targetname as String
	if "type" in props: type = props.type as int
	if "autoclose" in props: autoClose = props.autoclose as int
	if "locked" in props: locked = props.locked as int
	if "speed" in props: speed = props.speed as float
	if "rotatedir" in props: rotatedir = props.rotatedir as int
	currentlyLocked = locked
	add_to_group("Entity")
	
	##Initial Spawn Location , useful for setting doors open by default
	if open == 1:
		match(direction):
			0: ## UP
				self.position.y += opensize
				pass
			1: ## DOWN
				self.position.y -= opensize
				pass
			2: ## LEFT
				self.position.z += opensize
				pass
			3: ## RIGHT
				self.position.z -= opensize
				pass
	pass

func _ready():
	if Engine.is_editor_hint(): return
	if type == 1:
		var og = global_transform.origin
		if rotatedir == 0:
			rotAmt = 90
			self.global_transform.origin = Vector3(og.x ,og.y,og.z + 1.0 )
		elif rotatedir == 1:
			rotAmt = -90
			self.global_transform.origin = Vector3(og.x + 1.0 ,og.y,og.z)
		var NewNode = Node3D.new()
		NewNode.set_name("Door")
		add_child(NewNode)
		reparent(NewNode)
		
		for mesh in $".".get_children():
			if mesh is MeshInstance3D || mesh is CollisionShape3D:
				mesh.global_transform.origin = Vector3(og.x,og.y,og.z)
				pass
			pass
		pass
	
	rotation = Vector3.ZERO
	initPos = position
	add_to_group("Entity")
	pass # Replace with function body.

func _physics_process(delta):
	if Engine.is_editor_hint(): return
	
	pass

func _process(delta):
	if Engine.is_editor_hint(): return
	distToPlayer = transform.origin.distance_to(player.position)
	
	var openRange = 3
	var closingRange = 6
	
	timer += delta
	
	print_debug(timer)
	
	if currentlyLocked == 0 && timer > 0.5:
		if distToPlayer <= openRange && Input.is_action_pressed("Interact"): 
			on_trigger()
		
	if autoClose and open and distToPlayer > closingRange:
		on_trigger()
	
	# Rotate or Slide the Door
	match(type):
		0: ## Sliding Door
			var moveSpd = speed * delta
			match(direction):
				## UP
				0:
					if open:
						if position.y < (initPos.y + opensize):
							self.translate(self.transform.basis.y * moveSpd) # Move along local UP
					else:
						if position.y > initPos.y:
							self.translate(self.transform.basis.y * -moveSpd) # Move along local DOWN
				## DOWN
				1:
					if open:
						if position.y > (initPos.y - opensize):
							self.translate(self.transform.basis.y * -moveSpd)
					else:
						if position.y < initPos.y:
							self.translate(self.transform.basis.y * moveSpd)
				## LEFT
				2:
					if open:
						if position.z > (initPos.z - opensize):
							self.translate(self.transform.basis.z * -moveSpd) # Move along local LEFT
					else:
						if position.z < initPos.z:
							self.translate(self.transform.basis.z * moveSpd) # Move along local RIGHT
				## RIGHT
				3:
					if open:
						if position.z < (initPos.z + opensize):
							self.translate(self.transform.basis.z * moveSpd) # Move along local RIGHT
					else:
						if position.z > initPos.z:
							self.translate(self.transform.basis.z * -moveSpd) # Move along local LEFT
				## BACKWARDS 
				4:
					if open:
						if position.x > (initPos.x - opensize):
							self.translate(self.transform.basis.x * -moveSpd) # Move along local LEFT
					else:
						if position.x < initPos.x:
							self.translate(self.transform.basis.x * moveSpd) # Move along local RIGHT
				5:
				## FORWARDS
					if open:
						if position.x > (initPos.x + opensize):
							self.translate(self.transform.basis.x * -moveSpd) # Move along local LEFT
					else:
						if position.x > initPos.x:
							self.translate(self.transform.basis.x * moveSpd) # Move along local RIGHT
		
		1: ## Rotating Door:
			var rotSpd = 200
			
			match(direction):
				0:
					if open:
						if self.rotation_degrees.x > -rotAmt:
							RotateX(-rotSpd * delta)
					else:
						if self.rotation_degrees.x < 0:
							RotateX(rotSpd * delta)
				1:
					if open:
						if self.rotation_degrees.y > -rotAmt:
							RotateY(-rotSpd * delta)
					else:
						if self.rotation_degrees.y < 0:
							RotateY(rotSpd * delta)
				2:
					if open:
						if self.rotation_degrees.z > -rotAmt:
							RotateZ(-rotSpd * delta)
					else:
						if self.rotation_degrees.z < 0:
							RotateZ(rotSpd * delta)				
	
	pass


func RotateY(rotSpd):
	if rotatedir == 0:
		self.rotation_degrees.y += rotSpd
	else:
		self.rotation_degrees.y -= rotSpd
	pass
	
func RotateZ(rotSpd):
	if rotatedir == 0:
		self.rotation_degrees.z += rotSpd
	else:
		self.rotation_degrees.z -= rotSpd
	pass
	
func RotateX(rotSpd):
	if rotatedir == 0:
		self.rotation_degrees.x += rotSpd
	else:
		self.rotation_degrees.x -= rotSpd
	pass

func on_trigger():
	
	##If this door is a "key" door it will be unlocked once its been unlocked once
	if locked == 2: currentlyLocked = 0
	
	##Reset timer so that player doesnt accidentally press the open button more than once at a time
	timer = 0
	
	open = !open as int

