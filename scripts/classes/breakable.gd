extends Entity

class_name DestroyObject
# If the Entity inherits from this class:
	# Must add a Node3D named Model
	# Must add GPUParticles3D called Smoke

@onready var particleSmoke = $"BreakableParticles/Smoke"
@onready var particleWood = $"BreakableParticles/Wood"
@onready var particlePaper = $"BreakableParticles/Paper"
@onready var particleMetal = $"BreakableParticles/Metal"

@export var particleType = "Smoke"
@onready var model = $Model

var destroy = false
var particle = null

# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug(name, " ", particleType)
	match(particleType):
		# Smoke
		"Smoke": 
			particle = particleSmoke
		# Wood
		"Wood": 
			particle = particleWood
		# Paper
		"Paper": 
			particle = particlePaper
		# Metal
		"Metal": 
			particle = particleMetal
		
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Called when this object is destroyed
func Destroy():
	if destroy: return
	
	destroy = true
	model.visible = false
	particle.emitting = true

#Called when partiles are finished emitting
func _on_smoke_finished():
	queue_free()
	pass # Replace with function body.
