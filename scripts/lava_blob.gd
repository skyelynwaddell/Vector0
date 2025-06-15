extends CharacterBody3D

@export var jump_velocity := 15.0
@export var gravity := -24.8
@export var max_jump_height := 2.0
@export var jump_interval := 3.0

var jump_timer := 0.0
@onready var start_pos := global_position

func _ready() -> void:
	velocity = Vector3.ZERO
	
	jump_interval = randf_range(3.0,7.0)

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null: return
	var distToPlayer = transform.origin.distance_to(player.global_position)
	if distToPlayer > 100: return
	
	jump_timer += delta
	if jump_timer >= jump_interval:
		jump_timer = 0.0
		Jump()

	# Apply gravity
	velocity.y += gravity * delta

	# Apply motion
	move_and_slide()

	# Reset if blob falls below lava surface
	if global_position.y < start_pos.y - max_jump_height:
		ResetBlob()

func Jump():
	velocity.y = jump_velocity

func ResetBlob():
	global_position = start_pos
	velocity = Vector3.ZERO
