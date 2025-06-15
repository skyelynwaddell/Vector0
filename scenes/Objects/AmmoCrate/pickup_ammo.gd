extends "res://scripts/pickup.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.UpdateEntity(self,0)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	SpawnWait(delta)
	pass
	
func _on_body_entered(body):
		if spawn_wait == true: return

		if body.name == "Player":
			if body.hp.current > 99:
				return
			body.IncreaseHealth(50)
			body.UpdateHUD()
			Game.UpdateEntity(self,1)
			queue_free()
