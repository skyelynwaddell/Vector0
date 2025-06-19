@tool
extends Entity
class_name DestroyObject

@onready var model = self
@onready var ps = preload("res://scenes/Parents/breakable_particles.tscn")
@onready var breakableParticles = null
@onready var particle = null

# Contains the properties for the breakable object
@export_group("Breakable Object Properties")
@export_enum("Smoke", "Metal", "Wood") var particleType : String = "Smoke"
@export var explosive : bool = false

var destroy = false

func ready():
	model = self
	ps = preload("res://scenes/Parents/breakable_particles.tscn")
	breakableParticles = self.get_node_or_null("BreakableParticles")
	particle = breakableParticles.get_node_or_null(particleType)

	

## Called on level Build
func _func_godot_apply_properties(props : Dictionary):
	
	## Set props from map editor
	match(props.particleType):
		"0" : particleType = "Smoke"
		"1" : particleType = "Wood"
		"2" : particleType = "Metal"
	
	match(props.explosive):
		"0" : explosive = false
		"1" : explosive = true
	
	# Instantiate the particle system, particle type, and node group
	AddToGroup("Breakable")
	var new_ps = InstanceCreate(ps)
	particle = new_ps.get_node(particleType)
	
	# Remove un-used particle systems
	for node in new_ps.get_children():
		if node.name != particleType:
			node.queue_free()
	
	if Game.map_build == Game.MAP_BUILD.PREBUILD: return
	ready()

## Called when this object is destroyed
func Destroy():
	if destroy: return
	destroy = true
	
	## Damage the player if they are in the radius
	## and this is a Explosive breakable
	match(particleType):
		"Smoke":
			var player : Player = get_tree().get_first_node_in_group("Player")
			if player == null: 
				printerr("player is gonee")
				return
				
			var dist = global_position.distance_to(player.global_position)
			var damage_range = 5.0
			
			if dist <= damage_range:
				player.Hurt(50)
			pass
	
	# Remove the Model & Collision when it blows up
	for node in self.get_children():
		if node is MeshInstance3D or node is CollisionShape3D:
			node.queue_free()
	
	particle.emitting = true


func on_trigger(): Destroy() ## yaknow what why not be able to trigger explosives for cool stuff maybe a cutscene or something 😎


## Called when particles are finished emitting
func _on_smoke_finished():
	queue_free()
