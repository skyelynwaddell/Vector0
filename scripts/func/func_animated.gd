@tool
extends func_switch

@export var textures : Array = []
@export var fps : float = 15.0
var frame_accum : float = 0.0
var frame : int = 0

# Apply properties from mapping software
func _func_godot_apply_properties(props:Dictionary):
	if "fps" in props: fps = props.fps as float
	for i in range(10):
		if "texture" + str(i) in props:
			textures.resize(i + 1)
			textures[i] = props["texture" + str(i)] as String
	
	MatchExtension()
	LoadMesh()
	SetTextures()
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): return
	SetTextures()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint(): return
	
	if textures.size() <= 0: return
	
	frame_accum += delta * fps
	frame = int(frame_accum) % textures.size()
	SetTextures()
	pass
	
func SetTextures():
	if textures[frame] == "" or textures[frame] == null: 
		frame = 0 
		return
	SetTexture(textures[frame])
	pass
