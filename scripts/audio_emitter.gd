@tool
extends Node3D

@export var target : String = ""
@export var targetname : String = ""
@export var audio_filepath : String = ""
@export var volume = 1.0
@export var loops := 1
@export var autoplay := 1

func _func_godot_apply_properties(props:Dictionary):
	if "target" in props: target = props.target as String
	if "targetname" in props: targetname = props.targetname as String
	if "audio_filepath" in props: audio_filepath = props.audio_filepath as String
	if "volume" in props: volume = props.volume as float
	if "loops" in props: loops = props.loops as int
	if "autoplay" in props: autoplay = props.autoplay as int
	
	add_to_group("Entity",true)
	
	if Game.map_build == Game.MAP_BUILD.PREBUILD: return
	ready()

func _ready() -> void:
	if Game.map_build == Game.MAP_BUILD.RUNTIME: return
	ready()
	
func ready():
	if audio_filepath == "":
		print("no audio file attached to this audio emitter.")
		return
		
	var audio = load(audio_filepath)
	SetAudio(audio, self, volume)
	
func SetAudio(audio, caller, volume_db=5.0):
	global_position = caller.global_position
	
	$AudioStreamPlayer3D.max_db = volume_db
	$AudioStreamPlayer3D.volume_db = volume_db
	$AudioStreamPlayer3D.stream = audio
	
	if str(autoplay) == "1":
		$AudioStreamPlayer3D.playing = true
	
	print("SET AUDIO TO :" + str(audio))


func _on_audio_stream_player_3d_finished() -> void:
	
	if target != "":
		for i in get_tree().get_nodes_in_group("Entity"):
			if "targetname" in i:
				if i.targetname == target:
					if i.has_method("on_trigger"): 
						i.on_trigger()
	
	if loops == 1: return
	queue_free();
	pass # Replace with function body.
	

func on_trigger():
	$AudioStreamPlayer3D.playing = !$AudioStreamPlayer3D.playing
