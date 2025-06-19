@tool
extends Node3D

@export var targetname = ""
@export var target = ""

func _func_godot_apply_properties(props:Dictionary):
	if "targetname" in props: targetname = props["targetname"]
	if "target" in props: target = props["target"]
	
	if Game.map_build == Game.MAP_BUILD.PREBUILD: return
	ready()
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	if Game.map_build == Game.MAP_BUILD.RUNTIME: return
	ready()
	
func ready():
	add_to_group("Entity")
	pass # Replace with function body.
