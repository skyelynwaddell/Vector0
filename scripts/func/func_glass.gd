@tool
extends StaticBody3D

@export var targetname = ""
@export var target = ""

var matGlass = preload("res://materials/glass.tres")

func _func_godot_apply_properties(props:Dictionary):
	if "targetname" in props: targetname = props["targetname"]
	if "target" in props: target = props["target"]
	for child in $".".get_children():
		if child is MeshInstance3D:
			child.set_surface_override_material(0,matGlass)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): return
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint(): return
	pass
