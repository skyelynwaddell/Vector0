@tool
extends Node3D

@export var targetname = ""
@export var target = ""
@export var gravity = 0

func _func_godot_apply_properties(props:Dictionary):
	if "targetname" in props: targetname = props["targetname"] as String
	if "target" in props: target = props["target"] as String
	if "gravity" in props: gravity = props["gravity"] as int
	pass

func _ready():
	add_to_group("Entity")
	pass

func on_trigger():
	print_debug("triggrered gravity")
	for entity in get_tree().get_nodes_in_group(&"Entity"):
		if "targetname" in entity && "grvty" in entity:
			if entity.targetname == target:
				entity.grvty = gravity
	pass
	
