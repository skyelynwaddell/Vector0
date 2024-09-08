## FUNC SWITCH
@tool
extends Node3D
class_name func_switch

## Textures
@export_group("Textures")
## Texture Directory to look for the images
@export_dir var texture_dir : String = "res://textures/textures/"
## Texture that is used when the switch is ON
@export var texture_on : String = "+1_switch_brown"
## Texture that is used when the switch is ON
@export var texture_off : String = "-1_switch_brown"
## Texture that is used when the switch has NO POWER
@export var texture_nopower : String = "-1_switch_brown"
## Choose the file extension type of the textures
@export_flags("png","jpg","jpeg","bmp","tga","webp","tif","tiff","dds") var file_ext : int = 1

## Switch Properties
@export_group("Switch Properties")
## Target Name
@export var targetname : String = ""
## Target
@export var target : String = ""
## Controls if the switch is intially turned on.
@export var on : int = 0
## Controls if this switch intially has power to be turned on.
@export var power : int = 0

## Internal properties
var ext : String = "png"
var currentTexture : Texture2D = null
var mesh : MeshInstance3D = null
var material : StandardMaterial3D = null
var area3d : Area3D = null
var inArea : bool = false

# Apply properties from mapping software
func _func_godot_apply_properties(props:Dictionary):
	if "target" in props: target = props.target as String
	if "targetname" in props: targetname = props.targetname as String
	if "texture_on" in props: texture_on = props.texture_on as String
	if "texture_off" in props: texture_off = props.texture_off as String
	if "texture_nopower" in props: texture_nopower = props.texture_nopower as String
	if "on" in props: on = props.on as int
	if "power" in props: power = props.power as int
	
	MatchExtension()
	LoadMesh()
	SetTextures()
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): return
	SetTextures()
	
	# Create Area3D
	area3d = Area3D.new()
	area3d.name = "area3d"
	
	# Create Area3D collision area
	var coll = CollisionShape3D.new()
	var boxshape = BoxShape3D.new()
	
	# Change collision size & set shape
	var s = 2 ## Area 3D Size of Switch
	boxshape.size = Vector3(s,s,s)
	coll.shape = boxshape

	# Add Area3D and CollisionShape3D to the scene
	area3d.add_child(coll) 
	self.add_child(area3d)

	# Connect the area entered & exited signals
	area3d.connect("area_entered", _on_area_entered)
	area3d.connect("area_exited", _on_area_exited)
	
	if power == 1: area3d.add_to_group("Interact")
	pass # Replace with function body.

# Process
func _process(delta):
	if inArea and Input.is_action_just_pressed("Interact"):
		on_trigger()
	pass

# Match Extension
func MatchExtension():
	match(file_ext):
		1: SetExtension("png")
		2: SetExtension("jpg")
		3: SetExtension("jpeg")
		4: SetExtension("bmp")
		5: SetExtension("tga")
		6: SetExtension("webp") 
		7: SetExtension("tif")
		8: SetExtension("tiff") 
		9: SetExtension("dds")
	pass

# Load Mesh
func LoadMesh():
	# Get child mesh and its material
	for i in self.get_children():
		if i is MeshInstance3D:
			mesh = i
			material = mesh.get_active_material(0)
			pass
		pass
	pass

# On Area 3d Entered
func _on_area_entered(area):
	if area.is_in_group("Player"): 
		inArea = true
		#print_debug("in area")
	pass

# On Area 3d Exited
func _on_area_exited(area):
	if area.is_in_group("Player"): inArea = false
	pass

# Set Extension Type
func SetExtension(type : String):
	ext = type
	pass

# Get Texture
func GetTexture(texture : String):
	var texture_path = texture_dir + texture + "." + ext
	var _tex = load(texture_path)
	if _tex and _tex is Texture2D:
		return _tex as Texture2D
	else:
		print_debug("Error! Failed to load func_switch texture at path: " + texture_path)
		return null
	pass

# Set Texture
func SetTexture(texture : String):
	var _texture = GetTexture(texture)
	
	LoadMesh()
	
	if _texture != null and mesh != null:
		var mat = mesh.get_active_material(0)
		mat.set_texture(BaseMaterial3D.TEXTURE_ALBEDO,_texture)
		mesh.set_surface_override_material(0,mat)
		#print_debug("texture set : " , _texture )
	else:
		print_debug("Error! Texture was null!")
	pass

#Set Textures
func SetTextures():
	if on: SetTexture(texture_on)
	else: SetTexture(texture_off)
	pass

# On Trigger
func on_trigger():
	on = not on
	SetTextures()
	
	if target != "":
		for i in get_tree().get_nodes_in_group("Entity"):
			if "targetname" in i:
				if i.targetname == target:
					if i.has_method("on_trigger"): 
						i.on_trigger()
					
	#print_debug("Triggered Status: " , on)
	pass
