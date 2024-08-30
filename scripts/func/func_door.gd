@tool
extends StaticBody3D

## Target Name
@export var targetname = ""
## Type 0=Horizontal 1=Vertical
@export var type = 0 
## Size of the Door, and how far it should be opened
@export var opensize = 2.0
## Set if the door should spawn opened or not
@export var open = 0

var speed = 0.1
var initPos = Vector3.ZERO

func _func_godot_apply_properties(props:Dictionary):
	if "type" in props: type = props.type as int
	if "opensize" in props: opensize = props.opensize as float
	if "open" in props: open = props.open as int
	if "targetname" in props: targetname = props.targetname as String
	add_to_group("Entity")
	
	if open == 1:
		match(type):
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
	initPos = position
	add_to_group("Entity")
	pass # Replace with function body.

func _process(delta):
	if Engine.is_editor_hint(): return
	pass
	
func _physics_process(delta):
	if Engine.is_editor_hint(): return
	
	match(type):
		## UP
		0:
			if open:
				if self.position.y < (initPos.y + opensize):
					self.global_position.y += 0.1
			else:
				if self.position.y > (initPos.y):
					self.global_position.y -= 0.1
			pass
		## DOWN
		1:
			if open:
				if self.position.y > (initPos.y - opensize):
					self.global_position.y -= 0.1
			else:
				if self.position.y < (initPos.y):
					self.global_position.y += 0.1
			pass
		## LEFT
		2:
			if open:
				if self.position.z > (initPos.z - opensize):
					self.global_position.z -= 0.1
			else:
				if self.position.z < (initPos.z):
					self.global_position.z += 0.1
			pass
		## RIGHT
		3:
			if open:
				if self.position.z < (initPos.z + opensize):
					self.global_position.z += 0.1
			else:
				if self.position.z > (initPos.z):
					self.global_position.z -= 0.1
			pass
	

func on_trigger():
	open = !open
