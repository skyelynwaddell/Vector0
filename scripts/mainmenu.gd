extends CanvasLayer

var menus = {}
var currentMenu = "Main Menu"

var msaa_2d_list = [
	MenuButtonItem("Disabled (Fastest)", true, false, false, "OnMSAA2DChanged", 0),
	MenuButtonItem("2x (Average)", false, false, false, "OnMSAA2DChanged", 1),
	MenuButtonItem("4x (Slow)", false, false, false, "OnMSAA2DChanged", 2),
	MenuButtonItem("8x (Slowest)", false, false, false, "OnMSAA2DChanged", 3),
]

var msaa_3d_list = [
	MenuButtonItem("Disabled (Fastest)", true, false, false, "OnMSAA3DChanged", 0),
	MenuButtonItem("2x (Average)", false, false, false, "OnMSAA3DChanged", 1),
	MenuButtonItem("4x (Slow)", false, false, false, "OnMSAA3DChanged", 2),
	MenuButtonItem("8x (Slowest)", false, false, false, "OnMSAA3DChanged", 3),
]

var scaling_3d_mode_list = [
	MenuButtonItem("Billinear (Fastest)", true, false, false, "OnScaling3DModeChanged", 0),
	MenuButtonItem("FSR 1.0 (Fast)", false, false, false, "OnScaling3DModeChanged", 1),
	MenuButtonItem("FSR 2.2 (Slow)", false, false, false, "OnScaling3DModeChanged", 2),
]

func OnMSAA2DChanged(setting:int):pass
func OnMSAA3DChanged(setting:int):pass
func OnScaling3DModeChanged(setting:int):pass


# Called when the node enters the scene tree for the first time.
func _ready():
	
	Signals.HUDHide.connect(HUDHide)
	Signals.HUDShow.connect(HUDShow)
	
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
		"Main Menu": ["Resume", "Quicksave", "Save Game", "Load Game", "Help", "Options", "Quit Level"],
		"Options" : ["Audio", "Graphics", "Display", "Controls", "Back"],
		"Pause" : ["Resume", "Options", "Save Game", "Load Game", "Return to Main Menu"],
		"Audio" : ["Default Settings", "Back"],
		"Graphics" : ["Low Quality Mode", "Default Settings", "Back"],
		"Display" : ["Default Settings", "Back"],
		"Controls" : ["Default Settings", "Back"],
		"New Game" : ["Start Game", "Back"],
		"Quicksave":[],
		"Save Game": ["Back"],
		"Save Game Confirm" : ["Back"],
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
	Signals.MainMenuShown.emit()
	
	show()
	
func disable_window(): 
	if not Game.in_game: return
	if Console.is_visible(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED ## Hide the mouse	
	Game.paused = false
	Signals.MainMenuHidden.emit()
	
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
			CreateCheckbox("FXAA", "ToggleFXAA")
			CreateCheckbox("TAA", "ToggleFXAA")
			CreateCheckbox("Debanding", "ToggleFXAA")
			CreateCheckbox("Occlusion Culling", "ToggleFXAA")
			CreateCheckbox("HDR 2D", "ToggleFXAA")
			CreateSlider("3D Scaling","On3DScalingChanged",0.25,2,1,"3D Scaling: 1",0.05)
			
			CreateMenuButton("3D Scaling Mode", scaling_3d_mode_list)
			CreateMenuButton("MSAA 2D", msaa_2d_list)
			CreateMenuButton("MSAA 3D", msaa_3d_list)
			
			CreateSlider("Mesh LOD Threshold","OnMeshLODThresholdChanged",1,1024,1,"Mesh LOD Threshold: 1",1)
			CreateSlider("Texture Mipmap Bias","OnTextureMipmapBiasChanged",-2,2,0,"Texture Mipmap Bias: 0",0.1)
			
			CreateCheckbox("Disable Lights", "ToggleQuality")
			CreateCheckbox("Enable Glow", "ToggleQuality")
			CreateCheckbox("Enable Motion Blur", "ToggleMotionBlur")
			CreateCheckbox("Enable V-Sync", "ToggleVsync", true)
			CreateCheckbox("Enable HUD", "ToggleHud", true)
			CreateSlider("Field Of View (FOV)","OnFOVChanged",30,120,90)
			pass
		
		"Display":
			CreateSlider("Resolution","OnResolutionChanged",0,4,4,"Resolution: 1920x1080")
			CreateSlider("FPS","OnFPSChanged",0,6,2,"FPS: 60")
			CreateLabel("FPS is capped at monitor refresh rate,\nif v-sync is enabled.\n\n")
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
			var data = Game.GetSaveData()
			
			for save in data.saves:
				#print("SAVE: " + str(save))
				if save.has("save_name") == false: continue
				CreateButton(str(save.save_name),true,"LoadGame",true)
			pass
			
		"Quicksave":
			pass
			
		"Save Game":
			var data = Game.GetSaveData()
			
			CreateButton("New Save",true,"NewSave")
			
			for save in data.saves:
				#print("SAVE: " + str(save))
				if save.has("save_name") == false: continue
				CreateButton(str(save.save_name),true,"SaveGameConfirm", true)
			pass
			
		"Save Game Confirm":
			CreateLabel("Overwrite save file?")
			CreateButton("Save",true,"SaveGame")
			
		
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



var save_game_confirm_name = "" ## stores the game save name we selected after we are prompted if we 
								## are sure we want to overwrite the save
								
func NewSave(na:String): 
	currentMenu = "Main Menu"
	hide()
	UpdateMenu()
	await get_tree().process_frame
	await get_tree().process_frame
	Game.SaveGame()
	show()

func SaveGameConfirm(save_name:String):
	save_game_confirm_name = save_name
	currentMenu = "Save Game Confirm";
	UpdateMenu();
	
func SaveGame(na:String=""):
	currentMenu = "Main Menu"
	hide()
	UpdateMenu()
	await get_tree().process_frame
	await get_tree().process_frame
	Game.SaveGame(save_game_confirm_name)
	disable_window()

func LoadGame(save_name:String):
	disable_window()
	Game.LoadGame(save_name)
	queue_free()
	

func On3DScalingChanged(slider:float,label:Label,text:String):
	label.text = str("3D Scaling: " + str(slider))
	

## slider = slider value
## label = label node that displays text
## text = the sliders name ie. Master Volume, Voice Volume etc.
func OnMusicVolumeChanged(slider:int,label:Label,text:String):
	label.text = str(text, " : ", slider)
	MusicPlayer.volume_music = float(slider) / 100.0;
	MusicPlayer.VolumeSetMusic(MusicPlayer.volume_music)
	pass

func OnSFXVolumeChanged(slider,label,text):
	label.text = str(text, " : ", slider)
	MusicPlayer.volume_sfx = float(slider) / 100.0;
	MusicPlayer.VolumeSetSFX(MusicPlayer.volume_sfx)
	pass
	
func OnVoiceVolumeChanged(slider,label,text):
	label.text = str(text, " : ", slider)
	MusicPlayer.volume_voice = float(slider) / 100.0;
	MusicPlayer.VolumeSetVoice(MusicPlayer.volume_voice)
	pass
			
func OnMasterVolumeChanged(slider,label,text):
	label.text = str(text, " : ", slider)
	MusicPlayer.volume_master = float(slider) / 100.0;
	MusicPlayer.VolumeSetMaster(MusicPlayer.volume_master)
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
	
func HUDHide(): 
	hide()
	
func HUDShow(): show()
	
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
			Game.RestartLevel()
			disable_window()
			
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
		"Save Game Confirm": currentMenu = "Save Game Confirm"; UpdateMenu();
		
		"Quicksave": SaveGame()
			
		
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
			"Save Game" : currentMenu = "Main Menu"; UpdateMenu();
			"Tutorial" : currentMenu = "Main Menu"; UpdateMenu();
			"Save Game Confirm" : currentMenu = "Save Game"; UpdateMenu();
	pass
	
func CreateSlider(text, functionToCall, min_value=0, max_value=100, default_value=100, fullyCustomText="", step:float=1.0):
	var label = Label.new()
	var slider = HSlider.new()
	
	slider.step = step

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

func CreateButton(text:String, scroll=true, functionToCall="OnOptionPressed",showScreenshotOnHover=false):
	var button = Button.new()
	button.text = text
	button.pressed.connect(Callable(self,functionToCall).bind(text))
	
	if showScreenshotOnHover:
		button.mouse_entered.connect(Callable(self,"ShowScreenshot").bind(text))
		button.mouse_exited.connect(Callable(self,"HideScreenshot"))
	
	if (scroll == true):
		%menuItems.add_child(button)
	else:
		%saveButtons.add_child(button)
	
	return button
	pass
	
func ShowScreenshot(buttonName:String):
	var screenshot_path = "user://saves/" + str(buttonName) + "-sc.png"
	var image := Image.new()
	var err := image.load(screenshot_path)
	if err != OK:
		print("Failed to load image: ", screenshot_path)
		return null
		
	var texture := ImageTexture.create_from_image(image)
	%Screenshot.show()
	%Screenshot.texture = texture
	
	
func HideScreenshot(): 
	var sc = get_node_or_null("Screenshot")
	if sc == null: return
	sc.hide()

	
func CreateCheckbox(text:String, functionToCall, initiallyChecked=false):
	var checkbox = CheckBox.new();
	checkbox.text = text;
	checkbox.button_pressed = initiallyChecked;
	checkbox.toggled.connect(Callable(self,functionToCall).bind(checkbox));
	%menuItems.add_child(checkbox)
	
	return checkbox
	pass
	
func CreateLabel(text:String):
	var lbl = Label.new()
	lbl.text = text
	%menuItems.add_child(lbl)
	
	return lbl


func MenuButtonItem(text:String, checked:bool, disabled:bool, seperator:bool, functionToCall, params):
	return {
		"text":text,
		"checked":checked,
		"disabled":disabled,
		"seperator":seperator,
		"function_to_call": functionToCall,
		"params":params,
	}
func CreateMenuButton(label:String, items:Array):
	var mb = MenuButton.new()
	mb.text = label
	var popup = mb.get_popup()
	
	for i in range(items.size()):
		var item = items[i]
		
		if item.seperator:
			popup.add_separator()
		else:
			popup.add_item(item.text,i) # Item id is i
			popup.set_item_as_checkable(i, true)
			popup.set_item_checked(i, item.checked)
			
			if item.disabled:
				popup.set_item(i, true)
			if item.checked:
				popup.set_item_checked(i, true)
				
		popup.id_pressed.connect(
				func(id):if id == i: Callable(self, item.function_to_call).call(item.params)
			)
		
		%menuItems.add_child(mb)


func CreateScreenshotTexture(screenshot_path: String):
	var image := Image.new()
	var err := image.load(screenshot_path)
	if err != OK:
		print("Failed to load image: ", screenshot_path)
		return null

	var texture := ImageTexture.create_from_image(image)
	var tex := TextureRect.new()
	tex.texture = texture
	%menuItems.add_child(tex)

	return tex

	
