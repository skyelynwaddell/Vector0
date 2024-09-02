@tool
extends Node3D

@export var damage = 0
@export var targetname = ""
@export var target = ""

func _func_godot_apply_properties(props:Dictionary):
	if "targetname" in props: targetname = props["targetname"] as String
	if "target" in props: target = props["target"] as String
	if "damage" in props: damage = props["damage"] as int
	pass

func _ready():
	add_to_group("Entity")
	pass

func on_trigger():
	print_debug("triggrered hurt")
	for entity in get_tree().get_nodes_in_group(&"Entity"):
		if "targetname" in entity:
			if entity.targetname == target:
				if entity.has_method("Hurt"): entity.Hurt(damage)
	pass
	
