@tool
extends Node3D

@export var targetname := ""
@export var duration := 1.0
@export var intensity := 2.0
@export var decay := 1.0


# default screenshake values
# duration:float=0.2,_intensity:float=0.1, _decay:float=1.5
func _func_godot_apply_properties(props:Dictionary):
	if "targetname" in props: targetname = props.targetname as String
	if "duration" in props: duration = props["duration"] as float
	if "intensity" in props: intensity = props["intensity"] as float
	if "decay" in props: decay = props["decay"] as float
	
	add_to_group("Entity",true)


func on_trigger():
	Signals.ScreenShake.emit(duration, intensity, decay)
	pass
