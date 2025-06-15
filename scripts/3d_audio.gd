extends Node3D

func SetAudio(audio, caller, volume_db=5.0):
	print("Set Audio called...")
	global_position = caller.global_position
	
	$AudioStreamPlayer3D.max_db = volume_db
	$AudioStreamPlayer3D.volume_db = volume_db
	$AudioStreamPlayer3D.stream = audio
	$AudioStreamPlayer3D.stop()
	$AudioStreamPlayer3D.playing = true
	
	print("SOUND PLAYED: " + str(audio))
	
	var player = get_tree().get_first_node_in_group("Player")
	print("player position: " + str(player.global_position))
	print("sound position: " + str(global_position))

func _on_audio_stream_player_3d_finished() -> void:
	queue_free();
	pass # Replace with function body.
