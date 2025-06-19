extends Node

func AddCommands():
	#Console.add_command("command_name", <function>, <num_parameters>)
	add_command("quit", quit, 0)
	add_command("exit", quit, 0)
	add_command("restart", restart, 0)
	add_command("clear", clear, 0)
	add_command("delete_history", delete_history, 0)
	add_command("help", help, 0)
	add_command("commands_list", commands_list, 0)
	add_command("commands", commands, 0)
	add_command("calc", calculate, 1)
	add_command("godmode", godmode, 0)
	add_command("save", savegame, 0)
	add_command("load", loadgame, 0)
	add_command("texturemode", texturemode, 1)
	add_command("sound", MusicPlayer.Sound, 3)
	add_command("map", map, 1)
	add_command("lights_toggle", Game.LightsToggle,0)
	add_command("delete_saves", Game.DeleteSaves,0)

var helpLabel = "	[color=medium_orchid]Built in commands[/color]:
		[color=light_green]calc[/color]: Calculates a given expresion
		[color=light_green]clear[/color]: Clears the registry view
		[color=light_green]commands[/color]: Shows a reduced list of all the currently registered commands
		[color=light_green]commands_list[/color]: Shows a detailed list of all the currently registered commands
		[color=light_green]delete_hystory[/color]: Deletes the commands history
		[color=light_green]restart[/color]: Restarts the current level
		[color=light_green]quit[/color]: Quits the game
		[color=light_green]save[/color]: Creates a new save file
		[color=light_green]load[/color]: Loads the most recent save file
		[color=light_green]delete_saves[/color]: Delete all save files
		[color=light_green]sound[/color]: Plays a sound from string filepath ie. \"res://audio/player/player_jump.ogg\"
		[color=light_green]map[/color]: Load a .map file from the \"/maps\" folder.
		[color=light_green]lights_toggle[/color]: Toggle lights in the map.
		
		
	[color=medium_orchid]Cheats[/color]:
		[color=orange]godmode[/color]: Infinite health
		
	[color=medium_orchid]Controls[/color]:
		[color=dodger_blue]Up[/color] and [color=dodger_blue]Down[/color] arrow keys to navigate commands history
		[color=dodger_blue]PageUp[/color] and [color=dodger_blue]PageDown[/color] to scroll registry
		[[color=dodger_blue]Ctr[/color] + [color=dodger_blue]~[/color]] to change console size between half screen and full screen
		[color=dodger_blue]~[/color] or [color=dodger_blue]Esc[/color] key to close the console
		[color=dodger_blue]Tab[/color] key to autocomplete, [color=dodger_blue]Tab[/color] again to cycle between matching suggestions\n\n"

var enabled := true
var enable_on_release_build := false : set = set_enable_on_release_build
var pause_enabled := false
var was_paused_already := false

signal console_opened
signal console_closed
signal console_newline
signal console_unknown_command

class ConsoleCommand:
	var function : Callable
	var arguments : PackedStringArray
	var required : int
	var description : String
	func _init(in_function : Callable, in_arguments : PackedStringArray, in_required : int = 0, in_description : String = ""):
		function = in_function
		arguments = in_arguments
		required = in_required
		description = in_description


@onready var control := Control.new()
@onready var rich_label := RichTextLabel.new()
@onready var line_edit := LineEdit.new()

var console_commands := {}
var console_history := []
var console_history_index := 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("QuickSave"):
		savegame()
	
	if Input.is_action_just_pressed("QuickLoad"):
		loadgame()

func _ready() -> void:
	var canvas_layer := CanvasLayer.new()
	canvas_layer.layer = 3
	add_child(canvas_layer)
	control.anchor_bottom = 1.0
	control.anchor_right = 1.0
	canvas_layer.add_child(control)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("000000d7")
	setfont()
	rich_label.selection_enabled = true
	rich_label.context_menu_enabled = true
	rich_label.bbcode_enabled = true
	rich_label.scroll_following = true
	rich_label.anchor_right = 1.0
	rich_label.anchor_bottom = 0.5
	rich_label.add_theme_stylebox_override("normal", style)
	setfont()
	control.add_child(rich_label)
	rich_label.append_text(str(Game.game_name) + "\n")
	var empty_style = StyleBoxEmpty.new()
	line_edit.add_theme_stylebox_override("focus", empty_style)

	line_edit.anchor_top = 0.5
	line_edit.anchor_right = 1.0
	line_edit.anchor_bottom = 0.5
	line_edit.placeholder_text = "Enter \"help\" for instructions"
	control.add_child(line_edit)
	line_edit.text_submitted.connect(on_text_entered)
	line_edit.text_changed.connect(on_line_edit_text_changed)
	control.visible = false
	process_mode = PROCESS_MODE_ALWAYS
	AddCommands()
	
	setfont()
	line_edit.add_theme_font_override("font", Game.gamefont)
	control.add_theme_font_override("font", Game.gamefont)

#region Custom Commands

## restart - restarts current level
func restart():
	get_tree().reload_current_scene()


## load a map
func map(map_name:String):
	if Game.map_build == Game.MAP_BUILD.PREBUILD:
		Game.RoomGoto("res://scenes/levels/" + str(map_name) + ".tscn")
		
	if Game.map_build == Game.MAP_BUILD.RUNTIME:
		Signals.UpdateWorldMapFile.emit(map_name)
	

## savegame - saves the current game
func savegame():
	Game.SaveGame()

## loadgame - load the most recent save file
func loadgame():
	Game.LoadGame()

## godmode - infinite health
func godmode():
	Game.godmode = !Game.godmode
	var _txt = ""
	if Game.godmode:
		_txt = "God Mode Enabled"
	else:
		_txt = "God Mode Disabled"
		
	print_line(_txt,false)


## texturemode - sets linear/nearest texture filtering
## _tm [Defs.TEXTURE_MODE [int]] - filtering mode. 0=LINEAR 1=NEAREST
func texturemode(_tm : Defs.TEXTURE_MODE):
	
	if _tm == Defs.TEXTURE_MODE.LINEAR:
		get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
	elif _tm == Defs.TEXTURE_MODE.NEAREST:
		get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	
	pass

#endregion


func _input(event : InputEvent) -> void:
	if (event is InputEventKey):
		if (event.get_physical_keycode_with_modifiers() == KEY_QUOTELEFT): # ~ key.
			if (event.pressed):
				toggle_console()
			get_tree().get_root().set_input_as_handled()
		elif (event.physical_keycode == KEY_QUOTELEFT and event.is_command_or_control_pressed()): # Toggles console size or opens big console.
			if (event.pressed):
				if (control.visible):
					toggle_size()
				else:
					toggle_console()
					toggle_size()
			get_tree().get_root().set_input_as_handled()
		elif (event.get_physical_keycode_with_modifiers() == KEY_ESCAPE && control.visible): # Disable console on ESC
			if (event.pressed):
				toggle_console()
				get_tree().get_root().set_input_as_handled()
		if (control.visible and event.pressed):
			if (event.get_physical_keycode_with_modifiers() == KEY_UP):
				get_tree().get_root().set_input_as_handled()
				if (console_history_index > 0):
					console_history_index -= 1
					if (console_history_index >= 0):
						line_edit.text = console_history[console_history_index]
						line_edit.caret_column = line_edit.text.length()
						reset_autocomplete()
			if (event.get_physical_keycode_with_modifiers() == KEY_DOWN):
				get_tree().get_root().set_input_as_handled()
				if (console_history_index < console_history.size()):
					console_history_index += 1
					if (console_history_index < console_history.size()):
						line_edit.text = console_history[console_history_index]
						line_edit.caret_column = line_edit.text.length()
						reset_autocomplete()
					else:
						line_edit.text = ""
						reset_autocomplete()
			if (event.get_physical_keycode_with_modifiers() == KEY_PAGEUP):
				var scroll := rich_label.get_v_scroll_bar()
				var tween := create_tween()
				tween.tween_property(scroll, "value",  scroll.value - (scroll.page - scroll.page * 0.1), 0.1)
				get_tree().get_root().set_input_as_handled()
			if (event.get_physical_keycode_with_modifiers() == KEY_PAGEDOWN):
				var scroll := rich_label.get_v_scroll_bar()
				var tween := create_tween()
				tween.tween_property(scroll, "value",  scroll.value + (scroll.page - scroll.page * 0.1), 0.1)
				get_tree().get_root().set_input_as_handled()
			if (event.get_physical_keycode_with_modifiers() == KEY_TAB):
				autocomplete()
				get_tree().get_root().set_input_as_handled()


var suggestions := []
var current_suggest := 0
var suggesting := false
func autocomplete() -> void:
	if suggesting:
		for i in range(suggestions.size()):
			if current_suggest == i:
				line_edit.text = str(suggestions[i])
				line_edit.caret_column = line_edit.text.length()
				if current_suggest == suggestions.size() - 1:
					current_suggest = 0
				else:
					current_suggest += 1
				return
	else:
		suggesting = true
		
		var sorted_commands := []
		for command in console_commands:
			sorted_commands.append(str(command))
		sorted_commands.sort()
		sorted_commands.reverse()
		
		var prev_index := 0
		for command in sorted_commands:
			if command.contains(line_edit.text):
				var index : int = command.find(line_edit.text)
				if index <= prev_index:
					suggestions.push_front(command)
				else:
					suggestions.push_back(command)
				prev_index = index
		autocomplete()


func reset_autocomplete() -> void:
	suggestions.clear()
	current_suggest = 0
	suggesting = false


func toggle_size() -> void:
	if (control.anchor_bottom == 1.0):
		control.anchor_bottom = 1.9
	else:
		control.anchor_bottom = 1.0


func disable():
	if not Game.in_game: return
	if Game.IsPaused(): return
	enabled = false
	toggle_console() # Ensure hidden if opened
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED ## Hide the mouse	


func enable():
	if Game.IsPaused(): return
	if not Game.in_game: return
	enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE ## Show the mouse

func toggle_console() -> void:
	if Game.IsPaused(): return
	if not Game.in_game: return
	if (enabled):
		control.visible = !control.visible
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		control.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if (control.visible):
		was_paused_already = get_tree().paused
		get_tree().paused = was_paused_already || pause_enabled
		line_edit.grab_focus()
		console_opened.emit()
	else:
		control.anchor_bottom = 1.0
		scroll_to_bottom()
		reset_autocomplete()
		if (pause_enabled && !was_paused_already):
			get_tree().paused = false
		console_closed.emit()


func is_visible():
	return control.visible


func scroll_to_bottom() -> void:
	var scroll: ScrollBar = rich_label.get_v_scroll_bar()
	scroll.value = scroll.max_value - scroll.page


func print_line(text : String, print_godot := false) -> void:
	setfont()
	if (!rich_label): # Tried to print something before the console was loaded.
		call_deferred("print_line", text)
		call_deferred("setfont")
	else:
		rich_label.append_text(text)
		rich_label.append_text("\n")
		if (print_godot):
			print(text)
			
	setfont()
	console_newline.emit(text)
	print(str(text))
	
	
			
func setfont():
	rich_label.push_font(Game.gamefont,0)


func on_text_entered(new_text : String) -> void:
	rich_label.push_font(Game.gamefont,0)
	scroll_to_bottom()
	reset_autocomplete()
	line_edit.clear()
	
	if not new_text.strip_edges().is_empty():
		setfont()
		add_input_history(new_text)
		print_line("> " + new_text + "")
		var new_text_stripped := new_text.strip_edges()
		
		var text_split := new_text_stripped.split(" ")
		var text_command := text_split[0]
		
		if console_commands.has(text_command):
			var arguments := []
			for word in text_split.slice(1):
				arguments.push_back(word.lstrip("\"'").rstrip("\"'"))
			
			# calc is a especial command that needs special treatment
			if text_command.match("calc"):
				var expression := ""
				for word in arguments:
					expression += word
				console_commands[text_command].function.callv([expression])
				return
			
			if arguments.size() < console_commands[text_command].required:
				print_line("[color=light_coral]	ERROR:[/color] Too few arguments! Required < %d >" % console_commands[text_command].required)
				return
			elif arguments.size() > console_commands[text_command].arguments.size():
				print_line("[color=light_coral]	ERROR:[/color] Too many arguments! < %d > Max" % console_commands[text_command].arguments.size())
				return
			
			console_commands[text_command].function.callv(arguments)
		else:
			emit_signal("console_unknown_command")
			print_line("[color=light_coral]	ERROR:[/color] Command not found.")
			
	rich_label.push_font(Game.gamefont,0)


func on_line_edit_text_changed(new_text : String) -> void:
	reset_autocomplete()


func add_command(command_name : String, function : Callable, arguments = [], required: int = 0, description : String = "") -> void:
	if arguments is int:
		# Legacy call using an argument number
		var param_array : PackedStringArray
		for i in range(arguments):
			param_array.append("arg_" + str(i + 1))
		console_commands[command_name] = ConsoleCommand.new(function, param_array, required, description)
		
	elif arguments is Array:
		# New array argument system
		var str_args : PackedStringArray
		for argument in arguments:
			str_args.append(str(argument))
		console_commands[command_name] = ConsoleCommand.new(function, str_args, required, description)


func remove_command(command_name : String) -> void:
	console_commands.erase(command_name)


func quit() -> void:
	get_tree().quit()


func clear() -> void:
	rich_label.clear()


func delete_history() -> void:
	console_history.clear()
	console_history_index = 0
	DirAccess.remove_absolute("user://console_history.txt")


func help() -> void:
	rich_label.push_font(Game.gamefont,0)
	rich_label.append_text(helpLabel)


func calculate(command : String) -> void:
	var expression := Expression.new()
	var error = expression.parse(command)
	if error:
		print_line("[color=light_coral]	ERROR: [/color] %s" % expression.get_error_text())
		return
	var result = expression.execute()
	if not expression.has_execute_failed():
		print_line(str(result))
	else:
		print_line("[color=light_coral]	ERROR: [/color] %s" % expression.get_error_text())


func commands() -> void:
	rich_label.push_font(Game.gamefont,0)
	var commands := []
	for command in console_commands:
		commands.append(str(command))
	commands.sort()
	rich_label.append_text("	")
	rich_label.append_text(str(commands) + "\n\n")


func commands_list() -> void:
	var commands := []
	for command in console_commands:
		commands.append(str(command))
	commands.sort()
	
	for command in commands:
		var arguments_string := ""
		var description : String = console_commands[command].description
		for i in range(console_commands[command].arguments.size()):
			if i < console_commands[command].required:
				arguments_string += "  [color=cornflower_blue]<" + console_commands[command].arguments[i] + ">[/color]"
			else:
				arguments_string += "  <" + console_commands[command].arguments[i] + ">"
		rich_label.append_text("	[color=light_green]%s[/color][color=gray]%s[/color]:   %s\n" % [command, arguments_string, description])
	rich_label.append_text("\n")


func add_input_history(text : String) -> void:
	
	if (!console_history.size() || text != console_history.back()): # Don't add consecutive duplicates
		console_history.append(text)
	console_history_index = console_history.size()


func _enter_tree() -> void:
	var console_history_file := FileAccess.open("user://console_history.txt", FileAccess.READ)
	if (console_history_file):
		while (!console_history_file.eof_reached()):
			var line := console_history_file.get_line()
			if (line.length()):
				add_input_history(line)


func _exit_tree() -> void:
	var console_history_file := FileAccess.open("user://console_history.txt", FileAccess.WRITE)
	if (console_history_file):
		var write_index := 0
		var start_write_index := console_history.size() - 100 # Max lines to write
		for line in console_history:
			if (write_index >= start_write_index):
				console_history_file.store_line(line)
			write_index += 1


func set_enable_on_release_build(enable : bool):
	enable_on_release_build = enable
	if (!enable_on_release_build):
		if (!OS.is_debug_build()):
			disable()
