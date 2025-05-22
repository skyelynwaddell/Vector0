extends PickUp

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Spin(delta)
	pass
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if Game.hp.current > 99:
			return
		body.get_parent().IncreaseHealth(100)
		
		Signals.UpdateHUD.emit()
		queue_free()
