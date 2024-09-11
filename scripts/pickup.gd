extends Area3D
class_name PickUp

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")

@export_category("Pickup Properties")
var rotateSpeed = 1
	
func Spin(delta):
	rotate_y(rotateSpeed * delta)
