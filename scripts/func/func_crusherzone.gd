@tool
extends StaticBody3D

@export var targetname : String = ""
@export var target : String = ""
@export var crush_damage : int  = 100

var crusher_in_vacinity := false
var player_in_vacinity := false
var my_area : Area3D

func CreateArea3D():
	var mesh_instance = null
	for node in self.get_children():
		if node is MeshInstance3D: 
			mesh_instance = node
			break
			
	if mesh_instance == null: 
		printerr("Mesh is null DUDE")
		return
	var mesh = mesh_instance.mesh
	if mesh == null:
		printerr("ITS STILL NULL HOW DID WE EVEN GET HERE")
		return
		
	var aabb = mesh.get_aabb() # i will pretend like i know what the aabb is
	
	var area := Area3D.new()
	var colshape := CollisionShape3D.new()
	var boxshape := BoxShape3D.new()
	
	boxshape.size = aabb.size
	colshape.shape = boxshape
	colshape.transform.origin = aabb.position + (aabb.size / 2.0)
	area.add_child(colshape)
	add_child(area)
	
	area.area_entered.connect(CrusherZone_PlayerEntered)
	area.area_exited.connect(CrusherZone_PlayerExited)
	
	return area
		

func _func_godot_apply_properties(props:Dictionary):
	if "targetname" in props: targetname = props.targetname as String
	if "crush_damage" in props: crush_damage = props.crush_damage as int
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.CrusherZone_CrusherEntered.connect(CrusherZone_CrusherEntered)
	Signals.CrusherZone_CrusherExited.connect(CrusherZone_CrusherExited)
	Signals.CrusherZone_PlayerEntered.connect(CrusherZone_PlayerEntered)
	Signals.CrusherZone_PlayerExited.connect(CrusherZone_PlayerExited)
	
	my_area = CreateArea3D()
	pass # Replace with function body.


func CrusherZone_CrusherEntered(crusherzone_targetname:String):
	if crusherzone_targetname == targetname: crusher_in_vacinity = true
	#print("crusher in vacinity")
	if crusher_in_vacinity and player_in_vacinity:
		var player = get_tree().get_first_node_in_group("Player")
		if player == null: return
		if player.has_method("Hurt") == false: return
		
		player.Hurt(crush_damage)


func CrusherZone_CrusherExited(crusherzone_targetname:String):
	if crusherzone_targetname == targetname: crusher_in_vacinity = false
	#print("crusher left the vacinity nowwww")
	

func CrusherZone_PlayerEntered(area:Area3D):
	if crusher_in_vacinity: return
	if area.is_in_group("Player") == false: return
	
	player_in_vacinity = true
	#print("Player entered crusherzone")


func CrusherZone_PlayerExited(area:Area3D):
	if crusher_in_vacinity: return
	if area.is_in_group("Player") == false: return
	
	player_in_vacinity = false
	#print("player left crusher zone")
