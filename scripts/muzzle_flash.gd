extends Node3D

func _ready():
	 # Connect the timer signals
	%Timer.timeout.connect(Stop) 
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func Start():
	if (%GPUParticles3D.emitting == true): return
	
	#%OmniLight3D.visible = true
	
	%GPUParticles3D.one_shot = true
	%GPUParticles3D.emitting = true	
	
	%Timer.stop()
	%Timer.start(%GPUParticles3D.lifetime)	
	#%GPUParticles3D.one_shot = false
	pass
	
func Stop():
	%GPUParticles3D.emitting = false
	%GPUParticles3D.one_shot = true		
	%OmniLight3D.visible = false
	pass
