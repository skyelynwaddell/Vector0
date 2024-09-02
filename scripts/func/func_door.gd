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

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
var distToPlayer = 0
var speed = 1
var initPos = Vector3.ZERO
var rotAmt = 90

func _func_godot_apply_properties(props:Dictionary):
	if "direction" in props: direction = props.direction as int
	if "opensize" in props: opensize = props.opensize as float
	if "open" in props: open = props.open as int
	if "targetname" in props: targetname = props.targetname as String
	if "type" in props: type = props.type as int
	if "autoclose" in props: autoClose = props.autoclose as int
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
		self.global_transform.origin = Vector3(og.x ,og.y,og.z + 1.0 )
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
	distToPlayer = global_transform.origin.distance_to(player.position)
	
	if autoClose && open && distToPlayer > 6:
		on_trigger()
	
	#Rotate or Slide the Door
	match(type):
		0: ## Sliding Door
			var pos = self.position
			var moveSpd = speed * delta
			match(direction):
				## UP
				0:
					if open:
						if pos.y < (initPos.y + opensize):
							self.global_position.y += moveSpd
					else:
						if pos.y > (initPos.y):
							self.global_position.y -= moveSpd
					pass
				## DOWN
				1:
					if open:
						if pos.y > (initPos.y - opensize):
							self.global_position.y -= moveSpd
					else:
						if pos.y < (initPos.y):
							self.global_position.y += moveSpd
					pass
				## LEFT
				2:
					if open:
						if pos.z > (initPos.z - opensize):
							self.global_position.z -= moveSpd
					else:
						if pos.z < (initPos.z):
							self.global_position.z += moveSpd
					pass
				## RIGHT
				3:
					if open:
						if pos.z < (initPos.z + opensize):
							self.global_position.z += moveSpd
					else:
						if pos.z > (initPos.z):
							self.global_position.z -= moveSpd
					pass
		1: ## Rotating Door:
			var rotSpd = 200
			if open:
				if self.rotation_degrees.y > -rotAmt:
					RotateY(-rotSpd * delta)
					pass
			else:
				if self.rotation_degrees.y < 0:
					RotateY(rotSpd * delta)
					pass
			pass
	
func RotateY(rotSpd):
	self.rotation_degrees.y += rotSpd
	pass

func on_trigger():
	open = !open
