extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready():
	#self.add_to_group("Ladder")
	# Find the existing CollisionShape3D with a ConvexPolygonShape3D
	var original_shape : ConvexPolygonShape3D = null
	for child in get_children():
		if child is CollisionShape3D:
			var shape = child.shape
			if shape is ConvexPolygonShape3D:
				original_shape = shape
				break
	
	if original_shape == null:
		print("No ConvexPolygonShape3D found")
		return
	
	# Duplicate and extend the shape
	var extended_shape = original_shape.duplicate() as ConvexPolygonShape3D
	var points = extended_shape.points
	
	# Extend all points upward on Y-axis by a certain amount (e.g., 2.0 units)
	#var offset_y = 0
	#for i in points.size():
		#var p = points[i]
		#if p.y > 0:
			#points[i].y += offset_y
		#else:
			#points[i].y -= offset_y
#
	#extended_shape.points = points
	
	# Create a new Area3D with the extended shape
	var new_area = Area3D.new()
	var new_col = CollisionShape3D.new()
	new_col.shape = extended_shape
	new_area.add_child(new_col)
	new_area.add_to_group("Ladder", true)
	add_child(new_area)
	
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
