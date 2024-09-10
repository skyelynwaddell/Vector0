extends Node3D

@onready var bullethole1 = %BulletHole1
@onready var scratch1 = %Scratch1
@export_flags("Bullet","Scratch") var type = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	bullethole1.visible = false;
	scratch1.visible = false;
	
	match(type):
		1: bullethole1.visible = true
		2: scratch1.visible = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
