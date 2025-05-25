extends Node3D

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
@onready var ProjectileScene = preload("res://scenes/projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.SpawnProjectile.connect(SpawnProjectile)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func SpawnProjectile(other:CharacterBody3D, direction:Vector3):
	var inst : CharacterBody3D = ProjectileScene.instantiate()
	inst.direction = direction
	%Projectiles_Throwables.add_child(inst)
	inst.global_position = other.global_position
	inst.global_position.y += 1
	print("Spawn projectile was called")
