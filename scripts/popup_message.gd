extends CanvasLayer

var message : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Label.text = str(message)
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
	pass # Replace with function body.
