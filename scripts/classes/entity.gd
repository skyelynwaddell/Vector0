extends Node3D

class_name Entity 
# Entities must be of the type RigidBody3D

# String name of the Type of Object
	# Available Options:
	# Breakable
	
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func AddToGroup(groupname : String):
	add_to_group(groupname, true)
	pass

func InstanceCreate(scene : PackedScene):
	var newScene = scene.instantiate()
	self.add_child(newScene)
	newScene.set_owner(get_tree().get_edited_scene_root())
	return newScene
	pass
