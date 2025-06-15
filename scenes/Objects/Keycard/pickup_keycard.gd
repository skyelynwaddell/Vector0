@tool
extends "res://scripts/pickup.gd"
class_name Pickup_Keycard

enum KEY_TYPE {
	RED, YELLOW, BLUE
}

@export var key_type : KEY_TYPE = KEY_TYPE.RED
var target := "door_red"

func _func_godot_apply_properties(props:Dictionary):
	if "key_type" in props: key_type = props.key_type as int
	ApplyProperties()

func ApplyProperties():
	%keycard_red.hide()
	%keycard_yellow.hide()
	%keycard_blue.hide()
	
	match(key_type):
		KEY_TYPE.RED : 
			%OmniLight3D.light_color = Color(1.0, 0.36, 0.835)
			%keycard_red.show()
			target = "door_red"
			add_to_group("Keycard_Red", true)
		KEY_TYPE.YELLOW : 
			%OmniLight3D.light_color = Color(0.94, 0.804, 0.003)
			%keycard_yellow.show()
			target = "door_yellow"
			add_to_group("Keycard_Yellow", true)
		KEY_TYPE.BLUE : 
			%OmniLight3D.light_color = Color(0.367, 0.685, 0.989)
			%keycard_blue.show()
			target = "door_blue"
			add_to_group("Keycard_Blue", true)
	pass

func _ready() -> void:
	ApplyProperties()
	Game.UpdateEntity(self,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint(): return
	SpawnWait(delta)
	Spin(delta)
	pass
	
var has_entered := false
func _on_body_entered(body:Area3D):
	if spawn_wait == true: return
	
	if body.is_in_group("Player"):
		if has_entered: return
		has_entered = true
		
		var key_string = "RED"
		match(key_type):
			KEY_TYPE.RED: Game.keycard.red = true; key_string = "RED";
			KEY_TYPE.YELLOW: Game.keycard.yellow = true; key_string = "YELLOW";
			KEY_TYPE.BLUE: Game.keycard.blue = true; key_string = "BLUE";
		
		Signals.UpdateHUD.emit()
		
		for entity in get_tree().get_nodes_in_group(&"Entity"):
			if "targetname" in entity:
				if entity.targetname == target:
					entity.locked = false
					entity.lockstatus = 0
		
		MusicPlayer.Sound(MusicPlayer.SFX.KEYCARD, MusicPlayer.AUDIO_CHANNEL.SFX, 0.3)
		Console.print_line("Picked up a " + str(key_string) + " Key.")
		Game.UpdateEntity(self,1)
		queue_free()
	
