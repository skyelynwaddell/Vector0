@tool
extends Node3D

@export var targetname = ""
@export var target = ""
@export var teleporttarget = ""

func _func_godot_apply_properties(props:Dictionary):
	if "targetname" in props: targetname = props["targetname"] as String
	if "target" in props: target = props["target"] as String
	if "teleporttarget" in props: teleporttarget = props["teleporttarget"] as String
	pass

func _ready():
	add_to_group("Entity")
	pass

func on_trigger():
	print_debug("trigger teleport")
	var _target = null
	var _teleporttarget = null
	
	for entity in get_tree().get_nodes_in_group(&"Entity"):
		print_debug("looping through entities")
		if "targetname" in entity:
			if entity.targetname == target: 
				_target = entity
			elif entity.targetname == teleporttarget: 
				_teleporttarget = entity
	
	if _target != null && _teleporttarget != null:
		if _target is CharacterBody3D && _teleporttarget is Node3D:
			_target.global_position = _teleporttarget.global_position
			print_debug("teleported")
		pass			

	#if _target is CharacterBody3D && _teleporttarget is Node3D:
		#_target.position = _teleporttarget.position
		#print_debug("teleported")
	#pass
	
	pass
