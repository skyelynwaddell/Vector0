@tool
extends Area3D

@onready var waterMaterial = preload("res://materials/water.tres")
@onready var fog = preload("res://scenes/WaterMaker3D/FogVolume.tscn")

@export var color = Vector4.ZERO
@export var color2 = Vector4.ZERO
@export var colorString = ""
@export var alpha = 0.6
@export var duplicateMaterial = Resource

var mySize = Vector3.ZERO

func _func_godot_apply_properties(props:Dictionary):
	if "color" in props: colorString = props.color
	if "alpha" in props: alpha = props.alpha
	var colors = colorString.split(" ")
	var colorLimit = 255.0
	var r = colors[0].to_float() / colorLimit
	var g = colors[1].to_float() / colorLimit
	var b = colors[2].to_float() / colorLimit
	var factor = 0.8 #Darken the second color by 80%
	color = Vector4(r,g,b,1.0)
	color2 = Vector4(r*factor,g*factor,b*factor,1.0)
	SetMaterial()
	
	pass

func SetMaterial():
	duplicateMaterial = waterMaterial.duplicate()	
	duplicateMaterial.set_shader_parameter("WATER_COL", color)
	duplicateMaterial.set_shader_parameter("WATER2_COL", color2)
	duplicateMaterial.set_shader_parameter("water_transparency", alpha)
	
	for mesh in self.get_children():
		if mesh is MeshInstance3D:
			mesh.material_override = duplicateMaterial
			mySize = mesh.get_aabb().size
			break
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
