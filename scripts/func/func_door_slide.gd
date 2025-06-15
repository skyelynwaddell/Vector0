@tool
extends CharacterBody3D

## Target Name
@export var targetname : String = ""

## Target
@export var target : String = ""

## Sets if the door is currently open or not
@export var open : bool = false

## Set the collision area the player can detect Interact button with
## FIXME : Door when too large, the player can crouch and will detect the player is too far away and close on them
## this is because we are hard coding the door size and need to dynamically get the size + say like 3 units
@export var doorsize : Vector3 = Vector3(5, 5, 5)

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
var send_crusher_signal := false

@export var lockmessage : String = ""

@export var sound_locked_str : String = "res://audio/door_locked.ogg"
@export var sound_opened_str : String = "res://audio/door_metal.ogg"

var sound_opened : AudioStream
var sound_locked : AudioStream
@export var secret := 0

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
	
	if "sound_locked" in props: sound_locked_str = props.sound_locked as String
	if "sound_opened" in props: sound_opened_str = props.sound_opened as String
	
	if "lockmessage" in props: lockmessage = props.lockmessage as String
	
	if "secret" in props: secret = props.secret as int
	
	pass
	
func GetDoorData():
	var data = {
		"targetname" : str(name),
		"origin" : { "x":global_transform.origin.x,"y":global_transform.origin.y,"z":global_transform.origin.z},
		"pos": { "x": global_position.x,"y": global_position.y,"z": global_position.z},
		"open" : open,
	}
	return data
	
func UpdateDoor():
	var data = GetDoorData()
	
	for i in range(Game.doors.size()):
		var d = Game.doors[i]
		
		if str(d.targetname) == str(name):
			Game.doors[i] = data.duplicate(true)
			return
		
	Game.doors.push_back(data.duplicate(true))
	pass
	
func SetDoorProperties():
	call_deferred("SetDoorPropertiesDeferred")
	
func SetDoorPropertiesDeferred():
	var data = null
	##loop through all doors
	for i in range(Game.doors.size()):
		var d = Game.doors[i]
		## validate this door isnt already registered
		if str(d.targetname) == str(name):
			data = d
			
	if data == null: return
	global_transform.origin = Vector3(data.origin.x, data.origin.y, data.origin.z)
	#global_position = Vector3(data.pos.x, data.pos.y, data.pos.z)
	open = data.open as bool
	
	
	print("Set door props: " + str(data))

func RegisterDoor():
	
	##loop through all doors
	for i in range(Game.doors.size()):
		var d = Game.doors[i]
		## validate this door isnt already registered
		if str(d.targetname) == str(name):
			return ## skip adding this door already exist
		
	##register the door
	var data = GetDoorData()
	Game.doors.push_back(data.duplicate(true))

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): return
	ReadyDoor()
	
	Signals.DoorUpdateEntity.connect(UpdateDoor)
	
func ReadyDoor():
	if sound_opened_str != "" : sound_opened = load(sound_opened_str)
	if sound_locked_str != "" : sound_locked = load(sound_locked_str)
	
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

			
	
	# Define the target position for when the door is open
	match(direction):
		## X Direction
		0: targetPos = initPos + (global_transform.basis.x * opensize)
		## Y Direction
		1: targetPos = initPos + (global_transform.basis.y * opensize)
		## Z Direction
		2: targetPos = initPos + (global_transform.basis.z * opensize)
		
	if open == true:
		global_transform.origin = targetPos
		
	
	
	# Add Area3D and CollisionShape3D to the scene
	area3d.add_child(coll) 
	self.add_child(area3d)

	# Connect the area entered & exited signals
	area3d.connect("area_entered", _on_area_entered)
	area3d.connect("area_exited", _on_area_exited)
	
	# Check if the door should be initially locked on spawn
	if lockstatus == 1 || lockstatus == 2: locked = true
	
	if locked == false:
		area3d.add_to_group("Interact",true)
	
	add_to_group("Entity",true)
	add_to_group("Door",true)
	RegisterDoor()


func _process(delta):
	if Engine.is_editor_hint(): return
	if Game.IsPaused(): return
	# Check if the player is within the area and can interact
	if canOpen and Input.is_action_just_pressed("Interact"):
		
		
		match(targetname):
			"door_red": if Game.keycard.red: locked = false
			"door_yellow": if Game.keycard.yellow: locked = false
			"door_blue": if Game.keycard.blue: locked = false
		
		## UNLOCKED DOOR --- OPEN IT
		if locked == false:
			on_trigger()
		else:
		
		## DOOR IS LOCKED
			if sound_locked != null and secret != 1:
				MusicPlayer.Sound(sound_locked, MusicPlayer.AUDIO_CHANNEL.SFX, 0.2)
				if lockmessage != "":
					Game.PopupMessageCreate(lockmessage)
				else:
					Console.print_line("Door is locked.")
	
	# Slide the door to the target position if open, or back to its initial position if closed
	if open:
		# Move the door towards the open position
		slide_door(targetPos,delta)
	else:	
		slide_door(initPos,delta)

signal DoorReachedDestination

func slide_door(targetPosition: Vector3, delta: float):
	if global_transform.origin == targetPosition: return
	
	var move_step = speed * delta
	var new_pos = global_transform.origin.move_toward(targetPosition, move_step) #(targetPosition - global_transform.origin).normalized()
	
	global_transform.origin = new_pos
	
	if new_pos.distance_to(targetPosition) < 0.01:
		global_transform.origin = targetPosition
		
		if not send_crusher_signal and targetPosition == initPos:
			send_crusher_signal = true
			Signals.CrusherZone_CrusherEntered.emit(target)
		
		DoorReachedDestination.emit()
		
	## Check if the remaining distance is larger than the step size
	#if global_transform.origin.distance_to(targetPosition) > move_step:
		#global_transform.origin += direction * move_step
	#else:
		## Snap to the target position if the step size would overshoot
		#global_transform.origin = targetPosition
		#
		#if send_crusher_signal == true: return
		#if global_transform.origin == initPos:
			#send_crusher_signal = true
			#Signals.CrusherZone_CrusherEntered.emit(target)

	area3d.global_transform.origin = initPos
	#area3d.global_position = global_position

func on_trigger():
	# Toggle the door's open/closed state
	open = not open
	
	if sound_opened != null:
		MusicPlayer.Sound(sound_opened, MusicPlayer.AUDIO_CHANNEL.SFX, 0.2)
	
	if open:
		send_crusher_signal = false
		Signals.CrusherZone_CrusherExited.emit(target)
	
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
