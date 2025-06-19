@tool
extends Node3D

@export var damage = 0
@export var targetname = ""
@export var target = ""
@export var map = ""
@export var landmark = 0

func _func_godot_apply_properties(props:Dictionary):
	if "targetname" in props: targetname = props["targetname"] as String
	if "target" in props: target = props["target"] as String
	if "map" in props: map = props["map"] as String
	if "landmark" in props: landmark = props["landmark"] as int
	
	add_to_group("Entity", true)
	if Game.map_build == Game.MAP_BUILD.PREBUILD: return
	ready()
	pass

func _ready():
	if Game.map_build == Game.MAP_BUILD.RUNTIME: return
	ready()
	
func ready():
	add_to_group("Entity", true)
	Game.UpdateEntity(self,0)
	pass
	
func _process(delta: float) -> void:
	pass
	
func on_trigger():
	if str(landmark) == "1":
		var player = get_tree().get_first_node_in_group("Player")
		var last_pos = player.global_position
		## TODO : Update the players position after room load and stuff
		## if you want landmark to work finish this
		## im too lazy to do this right now and i probably wont even use it anyways
		
	Game.RoomGoto(map)
	pass
	
