extends Node2D
## GLOBAL MusicPlayer

enum AUDIO_CHANNEL { MUSIC, SFX, VOICE, AMBIENT, UI }
const SFX_POOL_SIZE := 4; ## How many SFX can be played at once, all other channels only support 1 sound playing at a time...

var sfx_players : Array[AudioStreamPlayer]
var music_player : AudioStreamPlayer
var voice_player : AudioStreamPlayer
var ui_player : AudioStreamPlayer
var ambient_player : AudioStreamPlayer

var volume_master := 1.0;
var volume_music := 1.0;
var volume_voice := 1.0;
var volume_sfx := 1.0;

## 2D Sound System Sounds
@onready var SFX = {
	"PLAYER_JUMP" : preload("res://audio/player/player_jump.ogg"),
	"KNIFE_STAB" : preload("res://audio/weapons/knife_stab.ogg"),
	"KNIFE_SWING_1" : preload("res://audio/weapons/knife_swing1.ogg"),
	"KNIFE_SWING_2" : preload("res://audio/weapons/knife_swing2.ogg"),
	"MACHINE_GUN_RELOAD" : preload("res://audio/weapons/machinegun_reload.ogg"),
	"MACHINE_GUN_SHOT" : preload("res://audio/weapons/machinegun_shot.ogg"),
	"MP_RELOAD" : preload("res://audio/weapons/mp_reload.ogg"),
	"MP_SHOT" : preload("res://audio/weapons/mp_shot.ogg"),
	"PISTOL" : preload("res://audio/weapons/pistol.ogg"),
	"PISTOL_RELOAD" : preload("res://audio/weapons/pistol_reload.ogg"),
	"PISTOL_SHOT" : preload("res://audio/weapons/pistol_shot.ogg"),
	"REVOLVER_RELOAD" : preload("res://audio/weapons/revolver_reload.ogg"),
	"REVOLVER_SHOT" : preload("res://audio/weapons/revolver_shot.ogg"),
	"SHOTGUN_SHOT" : preload("res://audio/weapons/shotgun.ogg"),
	"SHOTGUN_RELOAD" : preload("res://audio/weapons/shotgun_reload.ogg"),
	"SUB_MACHINE_GUN" : preload("res://audio/weapons/submachinegun.ogg"),
	"SWITCH_WEAPON" : preload("res://audio/weapons/switch_weapon.ogg"),
	"WHIP_1" : preload("res://audio/weapons/whip1.ogg"),
	"WHIP_2" : preload("res://audio/weapons/whip2.ogg"),
	"DOOR_LOCKED" : preload("res://audio/door_locked.ogg"),
	"DOOR_METAL" : preload("res://audio/door_metal.ogg"),
	"PICKUP" : preload("res://audio/pickup.ogg"),
	"INTERACT_NO_WORK" : preload("res://audio/sfxInteractNowork.ogg"),
	"SWITCH_DIGITAL" : preload("res://audio/switch_digital.ogg"),
	"PLAYER_GRUNT_1" : preload("res://audio/player/grun1.ogg"),
	"PLAYER_GRUNT_2" : preload("res://audio/player/grunt2.ogg"),
	"KEYCARD" : preload("res://audio/keycard.ogg"),
	"FLASHLIGHT" : preload("res://audio/click.ogg"),
}

func IsSFXPlaying() -> bool : 
	for _sfxplayer in sfx_players:
		if _sfxplayer.playing:
			return true
	return false
	
func IsMusicPlaying() -> bool: return music_player.playing
func IsVoicePlaying() -> bool: return voice_player.playing

func ResetSettings():
	volume_master = 1.0;
	volume_music = 1.0;
	volume_sfx = 1.0;
	volume_voice = 1.0;
	
func VolumeSetMaster(new_db:float=1.0): 
	SetStreamPlayerVolume(MusicPlayer.AUDIO_CHANNEL.MUSIC, new_db)
	SetStreamPlayerVolume(MusicPlayer.AUDIO_CHANNEL.AMBIENT, new_db)
	SetStreamPlayerVolume(MusicPlayer.AUDIO_CHANNEL.VOICE, new_db)
	SetStreamPlayerVolume(MusicPlayer.AUDIO_CHANNEL.SFX, new_db)
	SetStreamPlayerVolume(MusicPlayer.AUDIO_CHANNEL.UI, new_db)
	
func VolumeSetMusic(new_db:float=1.0):
	SetStreamPlayerVolume(MusicPlayer.AUDIO_CHANNEL.MUSIC, new_db)
	SetStreamPlayerVolume(MusicPlayer.AUDIO_CHANNEL.AMBIENT, new_db)
	
func VolumeSetVoice(new_db:float=1.0):
	SetStreamPlayerVolume(MusicPlayer.AUDIO_CHANNEL.VOICE, new_db)	
	
func VolumeSetSFX(new_db:float=1.0):
	SetStreamPlayerVolume(MusicPlayer.AUDIO_CHANNEL.SFX, new_db)
	SetStreamPlayerVolume(MusicPlayer.AUDIO_CHANNEL.UI, new_db)
	

	
func SetStreamPlayerVolume(audio_channel, volume):
	var channel_volume = 1.0;
	var sound_player : AudioStreamPlayer;
	
	match(audio_channel):
		MusicPlayer.AUDIO_CHANNEL.MUSIC: 
			channel_volume = volume_music;
			sound_player = music_player;
		
		MusicPlayer.AUDIO_CHANNEL.SFX: 
			channel_volume = volume_sfx;
			
		MusicPlayer.AUDIO_CHANNEL.VOICE: 
			channel_volume = volume_voice;
			sound_player = voice_player
			
		MusicPlayer.AUDIO_CHANNEL.AMBIENT: 
			channel_volume = volume_music;
			sound_player = ambient_player
			
		MusicPlayer.AUDIO_CHANNEL.UI: 
			channel_volume = volume_sfx;
			sound_player = ui_player
	pass
	
	var final_volume = GetFinalVolume(volume,channel_volume,volume_master)
	
	if sound_player == null: 
		for sp in sfx_players:
			sp.volume_db = final_volume
			pass
		pass
	else:
		sound_player.volume_db = final_volume;


func GetFinalVolume(volume, channel_volume, volume_master):
	var clamped_volume = clamp(volume * channel_volume * volume_master, 0.0, 1.0);
	var final_volume = linear_to_db(clamped_volume);
	return final_volume;

## Spawns the Audio Stream Players
func SpawnAudioPlayers():
	
	for child in self.get_children(): child.queue_free()
	
	music_player = AudioStreamPlayer.new()
	voice_player = AudioStreamPlayer.new()
	ui_player = AudioStreamPlayer.new()
	ambient_player = AudioStreamPlayer.new()
	
	for i in range(SFX_POOL_SIZE):
		var _sfxplayer = AudioStreamPlayer.new()
		_sfxplayer.bus = "SFX"
		add_child(_sfxplayer)
		sfx_players.push_back(_sfxplayer)
	
	music_player.bus = "Music"
	ambient_player.bus = "Music"
	voice_player.bus = "Voices"
	ui_player.bus = "SFX"
	
	
	add_child(music_player)
	add_child(voice_player)
	add_child(ambient_player)
	add_child(ui_player)
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	SpawnAudioPlayers()
	pass # Replace with function body.


## Play a sound
## You can pass the loaded AudioStream, or the string filepath to the sound parameter
## Preffered to use preloaded audiostreams from the SFX dictionary above
## But also has the option to just play any sound at command, may be of use for mods or something idek cause then you dont need to add the sound to the enum evrytime
func Sound(sound:Variant, audio_channel:MusicPlayer.AUDIO_CHANNEL=MusicPlayer.AUDIO_CHANNEL.SFX, volume:float=1.0):
	
	var final_sound : AudioStream = null
	if sound is String: final_sound = load(sound);
	elif sound is AudioStream: final_sound = sound;
	
	if final_sound == null: return
	var channel_volume = 1.0;
	
	var sound_player : AudioStreamPlayer;
	match(audio_channel):
		MusicPlayer.AUDIO_CHANNEL.MUSIC: 
			sound_player = music_player;
			channel_volume = volume_music;
			sound_player.set("parameters/looping",true)
		
		MusicPlayer.AUDIO_CHANNEL.SFX: 
			channel_volume = volume_sfx;
			
			## find free sfx player
			for _sfxplayer in sfx_players:
				## check if this player is currently playing a sound
				if !_sfxplayer.playing:
					## it wasnt, we can use this sound player
					sound_player = _sfxplayer
					break
				## there were no available sound players (they were all playing a sound already!)
				if sound_player == null:
					## use the oldest sound player if they are all busy
					sound_player = sfx_players[0] 
					sound_player.set("parameters/looping",false)
			
		MusicPlayer.AUDIO_CHANNEL.VOICE: 
			sound_player = voice_player;
			channel_volume = volume_voice;
			sound_player.set("parameters/looping",false)
			
		MusicPlayer.AUDIO_CHANNEL.AMBIENT: 
			sound_player = ambient_player;
			channel_volume = volume_music;
			sound_player.set("parameters/looping",true)
			
		MusicPlayer.AUDIO_CHANNEL.UI: 
			sound_player = ui_player;
			channel_volume = volume_sfx;
			sound_player.set("parameters/looping",false)
	pass
	
	if sound_player == null: return;
	var final_volume = GetFinalVolume(volume,channel_volume,volume_master)
	
	##sound_player.stop();
	sound_player.stream = final_sound;
	sound_player.volume_db = final_volume;
	sound_player.play();
