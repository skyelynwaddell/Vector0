@tool
extends Node3D

@export var targetname = ""
@export var target = ""
@export var newtarget = ""

func _func_godot_apply_properties(props:Dictionary):
	if "targetname" in props: targetname = props["targetname"] as String
	if "target" in props: target = props["target"] as String
	if "newtarget" in props: newtarget = props["newtarget"] as String
	pass

func _ready():
	add_to_group("Entity")
	pass

func on_trigger():
	for entity in get_tree().get_nodes_in_group(&"Entity"):
		if "targetname" in entity && "target" in entity:
			if entity.targetname == target:
				entity.target = newtarget
	pass
	
