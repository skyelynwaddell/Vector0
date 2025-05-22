extends CanvasLayer

var menus = {}
var currentMenu = "Main Menu"

# Called when the node enters the scene tree for the first time.
func _ready():
	## Default Main Menu
	if not Game.in_game:
		menus = {
		"Main Menu": ["New Game", "Load Game", "Help", "Mods", "Options", "Quit"],
		"Options" : ["Audio", "Graphics", "Display", "Controls", "Back"],
		"Pause" : ["Resume", "Options", "Save Game", "Load Game", "Return to Main Menu"],
		"Audio" : ["Default Settings", "Back"],
		"Graphics" : ["Low Quality Mode", "Default Settings", "Back"],
		"Display" : [ "Default Settings", "Back"],
		"Controls" : ["Default Settings", "Back"],
		"New Game" : ["Start Game", "Back"],
		"Load Game" : ["Back"],
		"Help" : ["Help", "Back"],
		"Quit Level" : [],
		"Mods": ["Browse", "My Mods", "Create", "Back"]
		}
	## Menu while in game
	else:
		menus = {
		"Main Menu": ["Resume", "Load Game", "Help", "Options", "Quit Level"],
		"Options" : ["Audio", "Graphics", "Display", "Controls", "Back"],
		"Pause" : ["Resume", "Options", "Save Game", "Load Game", "Return to Main Menu"],
		"Audio" : ["Default Settings", "Back"],
		"Graphics" : ["Low Quality Mode", "Default Settings", "Back"],
		"Display" : ["Default Settings", "Back"],
		"Controls" : ["Default Settings", "Back"],
		"New Game" : ["Start Game", "Back"],
		"Load Game" : ["Back"],
		"Help" : ["Help", "Back"],
		"Quit Level" : [],
		"Mods": ["Browse", "My Mods", "Create", "Back"]
		}
	UpdateMenu();
	
	if Game.in_game: 
		SetToPauseMenu()
	pass # Replace with function body.

func SetToPauseMenu():
	$lblMenuName.text = "PAUSE MENU"
	hide()

func return_to_mainmenu(text:String):
	currentMenu = "Main Menu"
	UpdateMenu()
	
func quit_level(text:String):
	Game.in_game = false
	Game.paused = false
	Game.RoomGoto("res://scenes/levels/main_menu.tscn")
	

func enable_window(): 
	if not Game.in_game: return
	if Console.is_visible(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE ## show the mouse	
	Game.paused = true
	show()
	
func disable_window(): 
	if not Game.in_game: return
	if Console.is_visible(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED ## Hide the mouse	
	Game.paused = false
	hide()

func toggle_window():
	if not Game.in_game: return
	if Console.is_visible(): return
	
	if not visible: 
		enable_window()
	else: 
		disable_window()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("exit"):
		##get_tree().quit()
		toggle_window()
	
	pass
	
func UpdateMenu():
	# Clear previous menu's items
	for child in %menuItems.get_children():
		child.queue_free()	
		
	for child in %saveButtons.get_children():
		child.queue_free()

	%lblMenuName.text = currentMenu.to_upper();

	match(currentMenu):
		"Quit Level":
			CreateButton("Quit Level", true, "quit_level")
			CreateButton("Cancel", true, "return_to_mainmenu")
			pass
		
		"Audio":
			CreateSlider("Master Volume","OnMasterVolumeChanged", 0, 100, int(MusicPlayer.volume_master*100))
			CreateSlider("Music Volume","OnMusicVolumeChanged", 0, 100, int(MusicPlayer.volume_music*100))
			CreateSlider("SFX Volume","OnSFXVolumeChanged", 0, 100, int(MusicPlayer.volume_sfx*100))
			CreateSlider("Voice Volume","OnVoiceVolumeChanged", 0, 100, int(MusicPlayer.volume_voice*100))
			pass
		
		"Graphics":
			CreateCheckbox("Low Texture Quality", "ToggleQuality")
			CreateCheckbox("Low Shadow Quality", "ToggleQuality")
			CreateCheckbox("Low Lighting Quality", "ToggleQuality")
			CreateCheckbox("Low Draw Distance", "ToggleQuality")
			CreateCheckbox("Enable Bloom", "ToggleQuality")
			CreateCheckbox("Enable Fog", "ToggleFog", true)
			CreateCheckbox("Enable Motion Blur", "ToggleMotionBlur")
			CreateCheckbox("Enable V-Sync", "ToggleVsync")
			CreateCheckbox("Enable HUD", "ToggleHud", true)
			CreateCheckbox("Nearest Filtering", "ToggleNearestFiltering")
			CreateSlider("Field Of View (FOV)","OnFOVChanged",30,120,90)
			pass
		
		"Display":
			CreateSlider("Resolution","OnResolutionChanged",0,4,4,"Resolution: 1920x1080")
			CreateSlider("FPS","OnFPSChanged",0,6,2,"FPS: 60")
			CreateSlider("Brightness","OnBrightnessChanged",0,100,50)
			CreateCheckbox("Fullscreen", "ToggleQuality", true)
			pass		
			
		"Controls":
			#Custom keys start from index #76 with move_left as 76
			
			var btnup = CreateButton("Move Forwards [W]",true,"OnControlPressed_UP")
			var btndown = CreateButton("Move Backwards [S]",true,"OnControlPressed_UP")
			var btnleft = CreateButton("Move Left [A]",true,"OnControlPressed_UP")
			var btnright = CreateButton("Move Right [D]",true,"OnControlPressed_UP")
			
			var btnjump = CreateButton("Jump [Space]",true,"OnControlPressed_UP")
			
			var btnshoot = CreateButton("Shoot [LEFT MB]",true,"OnControlPressed_UP")
			var btnreload = CreateButton("Reload [R]",true,"OnControlPressed_UP")
			
			
			var btnchangeweapon_up  = CreateButton("Change Weapon Up [Scroll Wheel Up]",true,"OnControlPressed_UP")
			var btnchangeweapon_down  = CreateButton("Change Weapon Down []",true,"OnControlPressed_UP")
			
			var btninteract = CreateButton("Interact [E]",true,"OnControlPressed_UP")
			var btnflashlight = CreateButton("Flashlight [F]",true,"OnControlPressed_UP")
			
			
			var btncrouch = CreateButton("Crouch [Ctrl]",true,"OnControlPressed_UP")
			var btnwalk = CreateButton("Walk [Shift]",true,"OnControlPressed_UP")
			
			var btnconsole = CreateButton("Debug Console [`]",true,"OnControlPressed_UP")
			var btnpause = CreateButton("Pause [Esc]",true,"OnControlPressed_UP")
		
		"New Game":
			pass
			
		"Load Game":
			pass
		
		"Mods":
			pass
		
		"Tutorial":
			pass

	for option in menus[currentMenu]: 
		
		## Detect which buttons should be in the scroll menu, vs the bottom no scroll menu
		var scroll = true
		if (option == "Save Settings"): scroll = false
		if (option == "Low Quality Mode"): scroll = false
		if (option == "Default Settings"): scroll = false
		if (option == "Back"): scroll = false
		
		if (currentMenu == "Options"): scroll = true
		
		CreateButton(option,scroll)
	pass

#Audio

## slider = slider value
## label = label node that displays text
## text = the sliders name ie. Master Volume, Voice Volume etc.
func OnMusicVolumeChanged(slider:int,label:Label,text:String):
	label.text = str(text, " : ", slider)
	MusicPlayer.volume_music = float(slider) / 100.0;
	pass

func OnSFXVolumeChanged(slider,label,text):
	label.text = str(text, " : ", slider)
	MusicPlayer.volume_sfx = float(slider) / 100.0;
	pass
	
func OnVoiceVolumeChanged(slider,label,text):
	label.text = str(text, " : ", slider)
	MusicPlayer.volume_voice = float(slider) / 100.0;
	pass
			
func OnMasterVolumeChanged(slider,label,text):
	label.text = str(text, " : ", slider)
	MusicPlayer.volume_master = float(slider) / 100.0;
	pass	
	
#Graphics
func ToggleQuality():
	pass
	
func ToggleFog():
	pass	
	
func ToggleMotionBlur():
	pass	
	
func ToggleNearestFiltering():
	pass	
	
func ToggleHud():
	pass	
	
func ToggleVsync():
	pass
	
func OnFOVChanged(slider,label,text):
	label.text = str(text, " : ", slider)
	pass
	
func OnBrightnessChanged(slider,label,text):
	label.text = str(text, " : ", slider)

#Buttons

## Function that is called when a user clicks a button to change the controlss
func OnControlPressed_UP():
	
	pass
	
func OnResolutionChanged(slider,label,text):
	print_debug(slider)
	var _txt = ""
	match(int(slider)):
		0: _txt = "640x480"
		1: _txt = "800x600"
		2: _txt = "1024x768"
		3: _txt = "1280x720"
		4: _txt = "1920x1080"
		
	label.text = str("Resolution:", _txt)
	pass
		
func OnFPSChanged(slider,label,text):
	print_debug(slider)
	var _txt = ""
	match(int(slider)):
		0: _txt = "24"
		1: _txt = "30"
		2: _txt = "60"
		3: _txt = "120"
		4: _txt = "144"
		5: _txt = "240"
		6: _txt = "Unlimited"
		
	label.text = str("FPS: ", _txt)
	pass
		
## Manages what each button does in the menuss
func OnOptionPressed(option):
	match(option):
		"New Game": 
			Game.in_game = true; 
			Game.paused = false;
			print("Going to level1")
			Game.RoomGoto("res://scenes/world.tscn")
		"Options" : currentMenu = "Options"; UpdateMenu();
		"Audio" : currentMenu = "Audio"; UpdateMenu();
		"Graphics" : currentMenu = "Graphics"; UpdateMenu();
		"Display" : currentMenu = "Display"; UpdateMenu();
		"Controls" : currentMenu = "Controls"; UpdateMenu();
		"Mods" : currentMenu = "Mods"; UpdateMenu();
		"Tutorial" : currentMenu = "Tutorial"; UpdateMenu();
		"Save Game" : currentMenu = "Save Game"; UpdateMenu();
		"Load Game" : currentMenu = "Load Game"; UpdateMenu();
		"Resume" : disable_window();
		"Quit Level": currentMenu = "Quit Level"; UpdateMenu();
		
		"Exit" : get_tree().quit();
		
		## Handle what default settings button does on each page
		"Default Settings" : match(currentMenu):
			"Audio":
				MusicPlayer.ResetSettings()
				
				for slider in %menuItems.get_children():
					if slider is Slider:
						slider.value = 100;
				
		
		#Handle what the back button does on each page
		"Back" : match(currentMenu):
			"Options" : currentMenu = "Main Menu"; UpdateMenu();
			"Audio" : currentMenu = "Options"; UpdateMenu();
			"Graphics" : currentMenu = "Options"; UpdateMenu();
			"Controls" : currentMenu = "Options"; UpdateMenu();
			"Display" : currentMenu = "Options"; UpdateMenu();
			"New Game" : currentMenu = "Main Menu"; UpdateMenu();
			"Load Game" : currentMenu = "Main Menu"; UpdateMenu();
			"Mods" : currentMenu = "Main Menu"; UpdateMenu();
			"Tutorial" : currentMenu = "Main Menu"; UpdateMenu();
	pass
	
func CreateSlider(text, functionToCall, min_value=0, max_value=100, default_value=100, fullyCustomText=""):
	var label = Label.new()
	var slider = HSlider.new()

	label.text = str(text, " : ", default_value)
	
	if fullyCustomText != "":
		label.text = str(fullyCustomText);
		pass
		
	slider.min_value = min_value;
	slider.max_value = max_value;
	slider.value = default_value;
	slider.value_changed.connect(Callable(self,functionToCall).bind(label , text))
	
	%menuItems.add_child(label);
	%menuItems.add_child(slider);
	
	return slider
	pass

func CreateButton(text, scroll=true, functionToCall="OnOptionPressed"):
	var button = Button.new()
	button.text = text
	button.pressed.connect(Callable(self,functionToCall).bind(text))
	
	if (scroll == true):
		%menuItems.add_child(button)
	else:
		%saveButtons.add_child(button)
	
	return button
	pass
	
func CreateCheckbox(text, functionToCall, initiallyChecked=false):
	var checkbox = CheckBox.new();
	checkbox.text = text;
	checkbox.button_pressed = initiallyChecked;
	checkbox.toggled.connect(Callable(self,functionToCall).bind(checkbox));
	%menuItems.add_child(checkbox)
	
	return checkbox
	pass
