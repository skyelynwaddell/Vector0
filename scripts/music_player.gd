extends Node2D

var music_player : AudioStreamPlayer
var voice_player : AudioStreamPlayer
var sfx_player : AudioStreamPlayer

func SpawnAudioPlayers():
	music_player = AudioStreamPlayer.new()
	voice_player = AudioStreamPlayer.new()
	sfx_player = AudioStreamPlayer.new()
	
	add_child(music_player)
	add_child(voice_player)
	add_child(sfx_player)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	SpawnAudioPlayers()
	pass # Replace with function body.


func Sound(sound_filepath:String, audio_channel:Defs.AUDIO_CHANNEL=Defs.AUDIO_CHANNEL.SFX, volume:float=1.0):
	var sound = load(sound_filepath);
	
	if sound == null: return;
	
	var sound_player : AudioStreamPlayer;
	match(audio_channel):
		Defs.AUDIO_CHANNEL.MUSIC: sound_player = music_player;
		Defs.AUDIO_CHANNEL.SFX: sound_player = sfx_player;
		Defs.AUDIO_CHANNEL.VOICE: sound_player = voice_player;
	pass
	
	if sound_player == null: return;
	
	sound_player.stream = sound;
	sound_player.volume_db = volume;
	sound_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
