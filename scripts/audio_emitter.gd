@tool
extends Node3D

@export var audio_filepath : String = ""
@export var volume = 1.0
@export var loops := 1

func _func_godot_apply_properties(props:Dictionary):
	if "audio_filepath" in props: audio_filepath = props.audio_filepath as String
	if "volume" in props: volume = props.volume as float
	if "loops" in props: loops = props.loops as int
	
func _ready() -> void:
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
	$AudioStreamPlayer3D.playing = true
	
	print("SET AUDIO TO :" + str(audio))

func _on_audio_stream_player_3d_finished() -> void:
	if loops == 1: return
	queue_free();
	pass # Replace with function body.
