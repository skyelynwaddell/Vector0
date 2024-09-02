@tool
extends Node3D
class_name Trigger

@onready var timer = $Timer

## Function that is called when Triggered.
@export var function = "0"
## Is triggered by default ? 0=false 1=true
@export var triggered = "0"
## Does this trigger destroy after being triggered? 0=false 1=true
@export var permanent = "0"
## Trigger Type. Defines how the Player should Interact with this Trigger. 0=none 1=collide 2=interact 3=collide/interact
@export var type = "0"
## How long should the function wait until being called once triggered.
@export var waittime = 0.0
## Trigger Chain to sequence Trigger Events in succession.
@export var chaintrigger = ""
## Trigger Target, is the Entity we call the Function parameter on. Make sure the Entity has this method!
@export var target = ""
## Target Name
@export var targetname = ""
## Sound Effect played when Triggered
@export var sounds = 0
## Count Max
@export var countMax = 0 as int

@export var counter = 0 as int
var targetOrigin = 0
var TriggerEffect = null
var inArea = false

# Get Properties from Trenchbroom Entities
func _func_godot_apply_properties(props : Dictionary):
	#print_debug(props)
	if "func" in props: function = props["func"] as String
	if "triggered" in props: triggered = props["triggered"] as String
	if "permanent" in props: permanent = props["permanent"] as String
	if "type" in props: type = props["type"] as String
	if "waittime" in props: waittime = props["waittime"] as float
	if "chaintrigger" in props: chaintrigger = props["chaintrigger"] as String
	if "targetname" in props: targetname = props["targetname"] as String
	if "target" in props: target = props["target"] as String
	if "countmax" in props: countMax = props["countmax"].to_int()
		
	print_debug(countMax)
	# Set trigger scale to match the scale set in Trenchbroom
	if "scale" in props:
		var _scaleStr = props["scale"] as String
		var _scaleVals = _scaleStr.split(" ")
		var conversion = 0.0313
		var _scale = Vector3(
			_scaleVals[1].to_float() * conversion,
			_scaleVals[2].to_float() * conversion,
			_scaleVals[0].to_float() * conversion)
		scale = _scale
	pass

func _ready():
	if Engine.is_editor_hint(): return
	#self.visible = false
	pass
	
# When Player Entity collides with this Trigger
func _on_area_3d_area_entered(area):
	if Engine.is_editor_hint(): return
	
	##  Trigger Typing : 
	## 0 = Can't Trigger
	## 1 = Collision
	## 2 = Interact Pressed
	## 3 = Interact Hold
	
	#Collision Type
	inArea = true		
	if type == "1" || type == "3": Trigger()
	pass
	pass # Replace with function body.
	
#Trigger this entity, check if ChainTrigger needs to be triggered, and destroy self if not permanent
func Trigger():
	if countMax != null:
		counter += 1
		if counter < countMax: return
		
	#print_debug("Init trigger")
	GetTriggerEffect(function)
	self.triggered = true
	#if chaintrigger != null && chaintrigger != "" && chaintrigger != "0":
	if permanent == "0": queue_free()

# Get Trigger Effect Depending on Type of Trigger
func GetTriggerEffect(fn):
	if Engine.is_editor_hint(): return
	match(fn):
		# on_trigger
		"0":
			on_trigger(target)
			#print_debug("Found Function")
			pass
	pass

#On Trigger Effect
func on_trigger(target):
	if waittime > 0:
		timer.wait_time = waittime
		timer.one_shot = true
		timer.start()
		#print_debug(timer)
		#print_debug("Calling Timer")
		await timer.timeout
		
	if chaintrigger:
		for trigger in get_tree().get_nodes_in_group(&"Trigger"):
			#print_debug(trigger)
			if "targetname" in trigger:
				if trigger.targetname == chaintrigger:
					#print_debug("found trigger " , trigger.targetname)
					trigger.Trigger() #on_trigger(trigger.target)
	
	#print_debug("Checking entities")
	for entity in get_tree().get_nodes_in_group(&"Entity"):
		#print_debug(entity)
		if "targetname" in entity:
			if entity.targetname == target:
				#print_debug("found entity target ", entity.targetname)
				if entity.has_method("on_trigger"):
					entity.on_trigger()
					#print_debug("calling " , entity, " func")


func _on_area_3d_area_exited(area):
	if area.is_in_group("Player"): inArea = false
	pass # Replace with function body.

func _process(delta):
	if Engine.is_editor_hint(): return
	#print_debug(inArea)
	if inArea == false: return
	#Interact Type
	if type == "2" || type == "3":
		if Input.is_action_just_pressed("Interact"):
			Trigger()
			pass
