@tool
extends Area3D

## I Actually love this water a lot. <3

@onready var waterMaterial = preload("res://materials/water.tres")
@onready var fog = preload("res://scenes/WaterMaker3D/FogVolume.tscn")

@export var color = Vector4.ZERO
@export var color2 = Vector4.ZERO
@export var colorString = ""
@export var alpha := 0.6
@export var is_dangerous := "0"
@export var glows := "0"
@export var duplicateMaterial = Resource
@export var texture = Resource

var mySize = Vector3.ZERO

func _func_godot_apply_properties(props:Dictionary):
	if "color" in props: colorString = props.color
	if "alpha" in props: alpha = float(props.alpha)
	if "is_dangerous" in props: is_dangerous = props.is_dangerous
	if "glows" in props: glows = props.glows
	
	var colors = colorString.split(" ")
	var colorLimit = 255.0
	var r = colors[0].to_float() / colorLimit
	var g = colors[1].to_float() / colorLimit
	var b = colors[2].to_float() / colorLimit
	var factor = 0.8 #Darken the second color by 80%
	color = Vector4(r,g,b,1.0)
	color2 = Vector4(r*factor,g*factor,b*factor,1.0)
	SetMaterial()
	
	if glows == "1":
		var light = OmniLight3D.new()
		add_child(light)
		light.global_position = global_position

	pass

func SetMaterial():
	var setmesh = null
	var uvscale = Vector2(1,1)
	var uvoffset = Vector2(0, 0)
	
	for mesh in self.get_children():
		if mesh is MeshInstance3D:
			mySize = mesh.get_aabb().size
			var mat = mesh.get_active_material(0)
			
			if mat is StandardMaterial3D:
				texture = mat.albedo_texture
				uvscale = mat.uv1_scale
				uvoffset = mat.uv1_offset
				setmesh = mesh
			break
			
	duplicateMaterial = waterMaterial.duplicate(true)	
	duplicateMaterial.set_shader_parameter("water_transparency", float(alpha))
	
	print("alpha: " , float(alpha))
	if float(alpha) == 1.0: 
		duplicateMaterial.set_shader_parameter("is_opaque", true)
	else:
		duplicateMaterial.set_shader_parameter("is_opaque", false)
	
	duplicateMaterial.set_shader_parameter("WATER_COL", color)
	duplicateMaterial.set_shader_parameter("WATER2_COL", color2)
	duplicateMaterial.set_shader_parameter("tex", texture)
	duplicateMaterial.set_shader_parameter("uv_scale", uvscale)
	duplicateMaterial.set_shader_parameter("uv_offset", uvoffset)
	
	if setmesh != null:
		setmesh.material_override = duplicateMaterial
		pass
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("Water")
	SetMaterial()
	var fogInstance = fog.instantiate()
	add_child(fogInstance)
	$"FogVolume/FogVolume".set_size(mySize)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
