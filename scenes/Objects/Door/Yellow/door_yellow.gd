extends "res://scripts/door.gd"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	AttemptToOpen(player.keycardYellow)
