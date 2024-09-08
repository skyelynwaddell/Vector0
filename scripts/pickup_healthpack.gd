extends "res://scripts/pickup.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_body_entered(body):
		if body.is_in_group("Player"):
			if Game.hp.current > 99:
				return
			body.IncreaseHealth(50)
			body.UpdateHUD()
			queue_free()
