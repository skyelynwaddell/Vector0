@tool
extends Node3D

@export var targetname = ""
@export var target = ""
@export var newtarget = ""

func _func_godot_apply_properties(props:Dictionary):
	SetAlpha()
	pass

func SetAlpha():
	for mesh in self.get_children():
		if mesh is MeshInstance3D:
			var mat = mesh.get_active_material(0)
			mat.transparency = 1
			pass
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
	
