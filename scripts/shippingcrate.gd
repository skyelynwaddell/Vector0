extends Node3D

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
@onready var animTree = $AnimationTree
var open = false
var inRange = false
var aOpen = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if inRange && Input.is_action_just_pressed("Interact"):
			open = true
	
	if open: aOpen = lerp(aOpen,1.0, .1)
	else: aOpen = lerp(aOpen,0.0, .1)
		
	animTree.set("parameters/Open/blend_amount",aOpen)
	
	pass


func _on_area_3d_body_entered(body):
	if body.name == "PlayerArea": inRange = true
	pass # Replace with function body.


func _on_area_3d_area_exited(body):
	if body.name == "PlayerArea": inRange = false
	pass # Replace with function body.
