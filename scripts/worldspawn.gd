@tool
extends StaticBody3D

@export_group("Map Properties")
@export var map_name : String = "E1M1"
@export var enter_text : String = "E1M1 - Escape the Laboratory"
@export var starting_song_str : String = ""
@export var starting_song_volume : float = 1.0

#Load player data from mapping software
func _func_godot_apply_properties(props : Dictionary):
	if "map_name" in props: map_name = props.map_name as String
	if "starting_song" in props: starting_song_str = props.starting_song as String
	if "starting_song_volume" in props: starting_song_volume = props.starting_song_volume as float
	if "enter_text" in props: enter_text = props.enter_text as String

func _ready():
	if Engine.is_editor_hint(): return
	Game.map_name = map_name
	if starting_song_str != "":
		var starting_song = load(starting_song_str)
		MusicPlayer.Sound(starting_song, MusicPlayer.AUDIO_CHANNEL.MUSIC, starting_song_volume)
	
	Console.print_line("Loaded map: " + str(map_name))
	
	## TODO: Send signal to display map name and stuffs with enter_text
	Game.EnterLevelTextCreate(enter_text);
