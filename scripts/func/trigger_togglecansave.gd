@tool
extends Node3D

@export var can_save = "0"
@export var targetname := ""

func _func_godot_apply_properties(props:Dictionary):
	if "can_save" in props: can_save = props.can_save
	if "targetname" in props: targetname = props.targetname
	add_to_group("Entity",true)
	pass

func on_trigger():
	if str(can_save) == "1":
		#Console.print_line("Can Save!")
		Game.can_save = true
	else:
		#Console.print_line("Cant Save!")
		Game.can_save = false
	pass
	
