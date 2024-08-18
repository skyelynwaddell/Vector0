extends "res://scripts/door.gd"

func _ready():
	message = "Door Red"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	AttemptToOpen(player.keycardRed)
	pass
