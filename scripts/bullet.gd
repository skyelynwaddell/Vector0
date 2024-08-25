#BULLET
extends Node3D

var spd   = Game.weaponList[Game.currentWeapon].spd
var power = Game.weaponList[Game.currentWeapon].power
var life = 0

@onready var mesh = $MeshInstance3D
@onready var raycast = $RayCast3D
@onready var enemy = load("res://enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	life = 0
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0,0, -spd) * delta
	print_debug(life)
	life += delta
	if life >= 1:
		queue_free()
	
func _on_area_3d_body_entered(body):
	
	print_debug(body)
	
	match(body.name):
		"Enemy":
			print_debug("enemy")
			body.Hurt(power)
		"Wall":
			print_debug("Wall")
		"Barrel":
			body.BlowUp()
		
	if body.name != "Player":
		queue_free()
	
