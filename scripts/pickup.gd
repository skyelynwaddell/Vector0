@tool
extends Node3D
class_name PickUp

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
@export_category("Pickup Properties")
@export var rotateSpeed = 1
@export var can_collect = false

var spawn_wait = true
var spawn_timer = 0.0
var spawn_timer_max = 1.0
func SpawnWait(delta):
	if spawn_wait == false: return
	
	if spawn_timer < spawn_timer_max:
		spawn_timer+=delta
		
	if spawn_timer >= spawn_timer_max:
		spawn_wait = false

	
func Spin(delta):
	if Engine.is_editor_hint(): return
	rotate_y(rotateSpeed * delta)
	
