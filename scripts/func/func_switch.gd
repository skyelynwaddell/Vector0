## FUNC SWITCH
@tool
extends Node3D
class_name func_switch

## Textures
@export_group("Textures")
## Texture Directory to look for the images
@export_dir var texture_dir : String = "res://textures/"
## Texture that is used when the switch is ON
@export var texture_on : String = "textures/+1_switch_brown"
## Texture that is used when the switch is ON
@export var texture_off : String = "textures/-1_switch_brown"
## Texture that is used when the switch has NO POWER
@export var texture_nopower : String = "textures/-1_switch_brown"
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

@export var toggles := 1
@export var toggle_triggers := 0
@export var toggle_time := 0.1
var toggle_timer := 0.0

## Internal properties
var ext : String = "png"
var currentTexture : Texture2D = null
var mesh : MeshInstance3D = null
var material : StandardMaterial3D = null
var area3d : Area3D = null
var inArea : bool = false

var static_body := StaticBody3D.new()
var static_shape := CollisionShape3D.new()
var static_box := BoxShape3D.new()

var start_toggle_timer := false
@export var shoot_can_toggle := 0 ## whether or not the switch can be toggled by shooting it

# Apply properties from mapping software
func _func_godot_apply_properties(props:Dictionary):
	if "target" in props: target = props.target as String
	if "targetname" in props: targetname = props.targetname as String
	if "texture_on" in props: texture_on = props.texture_on as String
	if "texture_off" in props: texture_off = props.texture_off as String
	if "texture_nopower" in props: texture_nopower = props.texture_nopower as String
	if "on" in props: on = props.on as int
	if "power" in props: power = props.power as int
	
	if "toggles" in props: toggles = props.toggles as int
	if "toggle_time" in props: toggle_time = props.toggle_time as float
	if "toggle_triggers" in props: toggle_triggers = props.toggle_triggers as int
	
	if "shoot_can_toggle" in props: shoot_can_toggle = props.shoot_can_toggle as int
	
	MatchExtension()
	LoadMesh()
	SetInitialTexture()
	
	
	if Game.map_build == Game.MAP_BUILD.PREBUILD: return
	ready()


# Called when the node enters the scene tree for the first time.
func _ready():
	if Game.map_build == Game.MAP_BUILD.RUNTIME: return
	ready()


func ready():
	SetInitialTexture()
	
	if shoot_can_toggle == 1:
		static_box.size = Vector3(1,1,1)
		static_shape.shape = static_box
		static_body.add_child(static_shape)
		add_child(static_body)
		static_body.collision_layer = 4
		static_body.collision_mask = 2
		static_body.name = "SwitchCollision"
		#static_body.add_to_group("Enemy", true)
		static_body.add_to_group("Entity", true)
		static_body.add_to_group("Switch", true)
	
	# Create Area3D
	area3d = Area3D.new()
	area3d.name = "area3d_" + str(name)
	
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


# Process
func _process(delta):
	if self.inArea == true and Input.is_action_just_pressed("Interact"):
		self.on_trigger()
	
	if str(toggle_time) == "-1": return
	if start_toggle_timer == true and toggles == 0:
		toggle_timer += delta
		
		if toggle_timer >= toggle_time:
			toggle_timer = 0.0
			start_toggle_timer = false
			
			if toggle_triggers == 1:
				retrigger()
				
			SetTexture(texture_off)
			


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


# Load Mesh
func LoadMesh():
	# Get child mesh and its material
	for i in self.get_children():
		if i is MeshInstance3D:
			mesh = i
			var _mat = mesh.get_active_material(0)
			material = _mat.duplicate() ## Duplicate this or else it will change ALL the switches in the map 
			break


# On Area 3d Entered
func _on_area_entered(area):
	if area.is_in_group("Player"): 
		self.inArea = true


# On Area 3d Exited
func _on_area_exited(area):
	if area.is_in_group("Player"): 
		self.inArea = false


# Set Extension Type
func SetExtension(type : String):
	ext = type


# Get Texture
func GetTexture(texture : String):
	var texture_path = texture_dir + texture + "." + ext
	
	## if cant find texture, try searching again in textures/textures
	if not FileAccess.file_exists(texture_path):
		texture_path = texture_dir + "textures/" + texture + "." + ext
		
	if not FileAccess.file_exists(texture_path):
		print_debug("Texture file does not exist: " + texture_path)
		return null
		
	var _tex = load(texture_path)
	if _tex and _tex is Texture2D:
		return _tex as Texture2D



# Set Texture
func SetTexture(texture : String):
	var _texture = GetTexture(texture)
	
	LoadMesh()
	
	if _texture != null and mesh != null:
		var mat = self.mesh.get_active_material(0)
		
		if mat == null:
			printerr("switch matrial was null")
			return
		
		mat = mat.duplicate() ## Duplicate this or else it will change ALL the switches in the map 
		mat.set_texture(BaseMaterial3D.TEXTURE_ALBEDO,_texture)
		self.mesh.set_surface_override_material(0,mat)
		#print_debug("texture set : " , _texture )
	else:
		print_debug("Error! Texture was null!")


#Set Textures
func SetTextures():
	if toggles == 0:
		print("switch doesnt toggle")
		#Console.print_line("switch doesnt toggle")
		SetTexture(texture_on)
		start_toggle_timer = true
	else:
		print("switch toggles")
		start_toggle_timer = false
		if on: SetTexture(texture_on)
		else: SetTexture(texture_off)


func SetInitialTexture():
	start_toggle_timer = false
	if on: SetTexture(texture_on)
	else: SetTexture(texture_off)

func retrigger():
	print(str(name))
	on = not on
	
	if target != "":
		for i in get_tree().get_nodes_in_group("Entity"):
			if "targetname" in i:
				if i.targetname == target:
					if i.has_method("on_trigger"): 
						i.on_trigger()

# On Trigger
func on_trigger():
	
	if start_toggle_timer == true and toggles == 0: return
	
	print(str(name))
	on = not on
	SetTextures()
	
	if target != "":
		for i in get_tree().get_nodes_in_group("Entity"):
			if "targetname" in i:
				if i.targetname == target:
					if i.has_method("on_trigger"): 
						i.on_trigger()
