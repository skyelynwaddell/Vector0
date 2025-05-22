@tool
extends Node3D

## Target Name
@export var targetname : String = ""
## Target
@export var target : String = ""
## Sets if the door is currently open or not
@export var open : bool = false
## Set the collision area the player can detect Interact button with
@export var doorsize : Vector3 = Vector3(4, 4, 4)
## The distance the door should open
@export var opensize : float = 2.0
## Door speed
@export var speed : int = 6
## Door open direction 0=X 1=Y 2=Z
@export var direction : int = 0
## Controls the Lock status of the door | 0 = Unlocked | 1 = Locked and can only open WHEN triggered | 3 = Locked and can only open on Interact AFTER triggered
@export var lockstatus : int = 0 
## Controls if the door is locked currently
@export var locked = false
## Controls if door closes automatically when the player walks away
@export var autoclose = true

## True if the player can open the door
var canOpen : bool = false
## The initial position of the door
var initPos : Vector3 = Vector3.ZERO
## The target position the door moves to when open
var targetPos : Vector3 = Vector3.ZERO
## Mesh instance of the door (the model)
var mesh : MeshInstance3D = null
## Area3D of the door 
var area3d : Area3D = null

func _func_godot_apply_properties(props:Dictionary):
	# Set props from trenchbroom
	if "targetname" in props: targetname = props.targetname as String
	if "target" in props: target = props.target as String
	if "open" in props: open = props.open as int
	if "opensize" in props: opensize = props.opensize as float
	if "speed" in props: speed = props.speed as int
	if "direction" in props: direction = props.direction as int
	if "lockstatus" in props: lockstatus = props.lockstatus as int
	if "autoclose" in props: autoclose = props.autoclose as int
	pass

func set_import_value(key:String, value:String) -> bool:
	if (key == "targetname"): targetname = value
	if (key == "target"): target = value
	if (key == "open"): open = value.to_int();
	if (key == "opensize"): opensize = value.to_float();
	if (key == "speed"): speed = value.to_int();
	if (key == "direction"): direction = value.to_int();
	if (key == "lockstatus"): lockstatus = value.to_int();
	if (key == "autoclose"): autoclose = value.to_int();
	return true;
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): return
	# Create Area3D
	area3d = Area3D.new()
	area3d.name = "area3d"
	
	# Create Area3D collision area
	var coll = CollisionShape3D.new()
	var boxshape = BoxShape3D.new()
	
	# Change collision size & set shape
	boxshape.size = doorsize
	coll.shape = boxshape
	
	# Set the initial position of the door
	initPos = global_transform.origin
	
	# Define the target position for when the door is open (move right relative to door's rotation)
	match(direction):
		## X Direction
		0: targetPos = initPos + (global_transform.basis.x * opensize)
		## Y Direction
		1: targetPos = initPos + (global_transform.basis.y * opensize)
		## Z Direction
		2: targetPos = initPos + (global_transform.basis.z * opensize)
	
	# Add Area3D and CollisionShape3D to the scene
	area3d.add_child(coll) 
	self.add_child(area3d)

	# Connect the area entered & exited signals
	area3d.connect("area_entered", _on_area_entered)
	area3d.connect("area_exited", _on_area_exited)
	
	# Check if the door should be initially locked on spawn
	if lockstatus == 1 || lockstatus == 2: locked = true
	
	if locked == false:
		area3d.add_to_group("Interact")
	
	self.add_to_group("Entity")
	

func _process(delta):
	if Engine.is_editor_hint(): return
	# Check if the player is within the area and can interact
	if canOpen and Input.is_action_just_pressed("Interact"):
		if locked == false:
			on_trigger()
		else:
			MusicPlayer.Sound(MusicPlayer.SFX.DOOR_LOCKED, MusicPlayer.AUDIO_CHANNEL.SFX, 0.5)
		
	
	
	# Slide the door to the target position if open, or back to its initial position if closed
	if open:
		# Move the door towards the open position
		slide_door(targetPos,delta)
	else:
		# Move the door towards the closed position
		slide_door(initPos,delta)

func slide_door(targetPosition: Vector3, delta: float):
	var move_step = speed * delta
	var direction = (targetPosition - global_transform.origin).normalized()
	
	# Check if the remaining distance is larger than the step size
	if global_transform.origin.distance_to(targetPosition) > move_step:
		global_transform.origin += direction * move_step
	else:
		# Snap to the target position if the step size would overshoot
		global_transform.origin = targetPosition
	
	if area3d != null:
		area3d.global_transform.origin = initPos

func on_trigger():
	# Toggle the door's open/closed state
	open = not open
	MusicPlayer.Sound(MusicPlayer.SFX.DOOR_METAL, MusicPlayer.AUDIO_CHANNEL.SFX, 0.5)
	
	# Check if this door unlocks after being triggered
	if lockstatus == 2: locked = false
	
	if locked == false:
		area3d.add_to_group("Interact")

func _on_area_entered(area):
	# If the player enters the area, allow them to open the door
	if area.is_in_group("Player"):
		canOpen = true

func _on_area_exited(area):
	# If the player leaves the area, disallow opening and automatically close the door
	if area.is_in_group("Player"):
		canOpen = false
	
	# Automatically close the door when the player leaves
	if open && autoclose:
		on_trigger()
