@tool
extends Node3D
class_name Switch

@onready var mesh = $RootNode/Cube

@export var matOn = preload("res://models/objects/panel/on.tres")
@export var matOff = preload("res://models/objects/panel/off.tres")
@export var matNoPower = preload("res://models/objects/panel/nopower.tres")

var OFF = 1
var ON = 2
var NOPOWER = 3
@export var state = OFF
@export var targetname = ""
@export var target = ""

func _func_godot_apply_properties(props:Dictionary):
	if "targetname" in props: targetname = props["targetname"]
	if "target" in props: target = props["target"]
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): return
	SetMaterial()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint(): return
	pass

func on_trigger():
	if state == NOPOWER: return
	
	if state == ON: state = OFF
	elif state == OFF: state = ON
	SetMaterial()
	print_debug("switch triggered")
	pass
	
func SetMaterial():
	match(state):
		ON:
			mesh.set_surface_override_material(0,matOn)
			pass
		OFF:
			mesh.set_surface_override_material(0,matOff)
			pass
		NOPOWER:
			mesh.set_surface_override_material(0,matNoPower)
			pass
	pass
