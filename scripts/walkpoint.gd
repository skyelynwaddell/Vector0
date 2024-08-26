@tool
extends Node3D

@export var targetname = ""
@export var target = ""
@export var waittime = 0

func _func_godot_apply_properties(props : Dictionary):
	targetname = props.targetname
	target = props.target
	waittime = float(props.waittime)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
