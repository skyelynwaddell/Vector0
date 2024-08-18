#BULLET
extends Node3D

var spd   = Game.weaponList[Game.currentWeapon].spd
var power = Game.weaponList[Game.currentWeapon].power

@onready var mesh = $MeshInstance3D
@onready var raycast = $RayCast3D
@onready var enemy = load("res://enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0,0, -spd) * delta

func _on_area_3d_body_entered(body):
	
	print_debug(body)
	
	if body.name == "Enemy":
		print_debug("enemy")
		body.Hurt(power)
	if body.name == "Wall":
		print_debug("wall")
	
	if body.name == "Barrel":
		body.BlowUp()
	
	if body.name != "Player":
		queue_free()
	
