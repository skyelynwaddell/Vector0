extends Node3D

@export var power = 0
@export var timer := 0.0
@export var time_until_destroy := 0.2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	##Console.print_line("ive been created duhhhhh")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer >= time_until_destroy:
		queue_free()


func _on_area_3d_area_entered(area) -> void:
	print("touch area")
	print(area.get_groups())
	if area.is_in_group("Player"):
		if area.has_method("Hurt"):
			area.Hurt(power)
