@tool
extends Area3D

@export var damage := 10

func _func_godot_apply_properties(props:Dictionary):
	if "damage" in props: damage = props.damage as int


func _ready() -> void:
	self.connect("area_entered", _on_area_entered)
	#self.connect("area_exited", _on_area_exited)
	
func _on_area_entered(area):
	if area == null: return
	
	var parent = area.get_parent()
	if parent == null: return
	
	if parent.has_method("Hurt") == false: return
	
	parent.Hurt(damage)
	
