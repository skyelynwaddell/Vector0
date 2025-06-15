@tool
extends Node3D
class_name Trigger

@onready var timer : Timer = null

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
var currentTriggered = false
var area3d : Area3D = null

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
		
	add_to_group("Entity", true)
	pass

func _ready():
	if Engine.is_editor_hint(): return
	area3d = Area3D.new()
		
	# Create Area3D collision area
	var coll = CollisionShape3D.new()
	var boxshape = BoxShape3D.new()
	var size = Vector3.ZERO
	for i in self.get_children():
		if i is MeshInstance3D:
			var aabb = i.get_aabb()
			size = aabb.size
	
	# Change collision size & set shape
	boxshape.size = size
	coll.shape = boxshape
	
	timer = Timer.new()
	
	# Add Area3D and CollisionShape3D to the scene
	area3d.add_to_group("Trigger", true)
	self.add_to_group("Trigger", true)
	area3d.add_child(coll) 
	self.add_child(area3d)
	self.add_child(timer)
	
	area3d.connect("area_entered",_on_area_3d_area_entered)
	area3d.connect("area_exited",_on_area_3d_area_exited)
	self.visible = false
	
	Game.UpdateEntity(self, 0)
	pass
	
# When Player Entity collides with this Trigger
func _on_area_3d_area_entered(area):
	if Engine.is_editor_hint(): return
	if area.is_in_group("Player") == false: return
	print_debug("trigger")
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
	
var spawn_wait = true
var spawn_timer = 0.0
var spawn_timer_max = 1.0
func SpawnWait(delta):
	if spawn_wait == false: return
	
	if spawn_timer < spawn_timer_max:
		spawn_timer+=delta
		
	if spawn_timer >= spawn_timer_max:
		spawn_wait = false
		
	
#Trigger this entity, check if ChainTrigger needs to be triggered, and destroy self if not permanent
func Trigger():
	if spawn_wait == true: return
	
	if countMax != null:
		counter += 1
		if counter < countMax: return
		
	#print_debug("Init trigger")
	GetTriggerEffect(function)
	self.triggered = true
	#if chaintrigger != null && chaintrigger != "" && chaintrigger != "0":
	if permanent == "0": 
		Game.UpdateEntity(self,1)
		queue_free()

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
	if currentTriggered: return
	currentTriggered = true
	if waittime > 0:
		for i in self.get_children():
			if i is Timer: timer = i
			
		print_debug("Starting timer ", timer )
		timer.connect("timeout",timer_finished)
		timer.one_shot = true
		timer.start(waittime)
		print_debug("Time Left: " , timer.time_left)
		
			
		#print_debug(timer)
		#print_debug("Calling Timer")
		
			
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


func timer_finished():
	print_debug("method succesfully awaited")
	pass

func _on_area_3d_area_exited(area):
	if area.is_in_group("Player"): inArea = false
	pass # Replace with function body.

func _process(delta):
	if Engine.is_editor_hint(): return
	SpawnWait(delta)
	
	#print_debug(inArea)
	if inArea == false: return
	#Interact Type
	if type == "2" || type == "3":
		if Input.is_action_just_pressed("Interact"):
			Trigger()
			pass
