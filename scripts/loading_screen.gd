extends Node3D

enum LOADING_STATE {
	LOAD_SHADERS,
	FINISHED,
}
var state = LOADING_STATE.LOAD_SHADERS

## Put all .tres material files that have a shader on them here
@onready var shaders = [
	preload("res://shaders/projectile_electric.tres"),
	preload("res://shaders/projectile_slime.tres"),
	preload("res://materials/water.tres")
]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match(state):
		LOADING_STATE.LOAD_SHADERS:
			%LoadingText.text = "Loading shaders..."
			for i in range(shaders.size()):
				%Mesh.set_surface_override_material(0, shaders[i])
				
			%LoadingText.text = "Loading Map..."
			
			state = LOADING_STATE.FINISHED
			
		LOADING_STATE.FINISHED:
			Game.RoomGoto("res://scenes/world.tscn")
			queue_free()
