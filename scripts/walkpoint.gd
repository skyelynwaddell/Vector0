@tool
extends Node3D

@export var targetname = ""
@export var target = ""
@export var waittime = 0

func _func_godot_apply_properties(props : Dictionary):
	if "targetname" in props: targetname = props.targetname
	if "target" in props: target = props.target
	if "waittime" in props: waittime = float(props.waittime)
	
	add_to_group("WalkPoint", true)

# Called when the node enters the scene tree for the first time.
func _ready( ):
	add_to_group("WalkPoint", true)
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
