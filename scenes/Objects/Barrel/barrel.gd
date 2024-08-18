extends StaticBody3D

@onready var particle = $Smoke
@onready var model = $Model

var blownUp = false

# Called when the node enters the scene tree for the first time.
func _ready():
	name = "Barrel"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func BlowUp():
	if blownUp: return
	
	blownUp = true
	model.visible = false
	particle.emitting = true
	
func _on_smoke_finished():
	queue_free()
	pass # Replace with function body.
