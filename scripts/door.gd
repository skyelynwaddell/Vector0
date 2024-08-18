extends CharacterBody3D

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
var openRange = 6
var open = false
var openTimer = { current = 0, maximum = 100 }
var posY = position.y
var openHeight = 4
var openSpd = 0.2
var showLabel = false
var message = "Door Locked"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	AttemptToOpen(false)
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if open:
		if position.y <= posY + openHeight:
			position.y += openSpd
	else:
		if position.y > posY :
			position.y -= openSpd
		
func AttemptToOpen(haskeycard):
	var distToPlayer = global_position.distance_to(player.global_position)
	
	if distToPlayer > openRange:
		player.HideHUDInteract.emit()
		open = false
		return
			
	player.UpdateHUDSignal.emit(message)
	if haskeycard == false: return
	
	var eyeLine = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eyeLine, player.global_position+eyeLine, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty() && !open && Input.is_action_just_pressed("Interact"):
		print("open", position.x)
		open = true
