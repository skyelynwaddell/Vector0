@tool
extends Node3D

@export var targetname = ""
@export var target = ""

func _func_godot_apply_properties(props:Dictionary):
	if "targetname" in props: targetname = props["targetname"]
	if "target" in props: target = props["target"]
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Entity")
	pass # Replace with function body.
