extends Control

var menus = {
	"Main Menu": ["New Game", "Load Game", "Tutorial", "Mods", "Options", "Quit"],
	"Options" : ["Audio", "Graphics", "Display", "Controls", "Back"],
	"Pause" : ["Resume", "Options", "Save Game", "Load Game", "Return to Main Menu"],
	"Audio" : ["Save Settings", "Default Settings", "Back"],
	"Graphics" : ["Save Settings", "Low Quality Mode", "Default Settings", "Back"],
	"Display" : ["Save Settings", "Default Settings", "Back"]
}

var currentMenu = "Main Menu"

# Called when the node enters the scene tree for the first time.
func _ready():
	UpdateMenu();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func UpdateMenu():
	# Clear previous menu's items
	for child in %menuItems.get_children():
		child.queue_free()

	%lblMenuName.text = currentMenu.to_upper();

	match(currentMenu):
		"Audio":
			CreateSlider("Master Volume","OnVolumeChanged")
			CreateSlider("Music Volume","OnVolumeChanged")
			CreateSlider("SFX Volume","OnSFXVolumeChanged")
			CreateSlider("In-Game Character Voice Volume","OnVoiceVolumeChanged")
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
			CreateCheckbox("Fullscreen", "ToggleQuality", true)
			
			pass

	for option in menus[currentMenu]: CreateButton(option)
	pass

#Audio
func OnVolumeChanged(slider,label,text):
	label.text = str(text, " : ", slider)
	pass

func OnSFXVolumeChanged(slider,label,text):
	label.text = str(text, " : ", slider)
	pass
	
func OnVoiceVolumeChanged(slider,label,text):
	label.text = str(text, " : ", slider)
	pass
			
func OnMasterVolumeChanged(slider,label,text):
	label.text = str(text, " : ", slider)
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
		
func OnOptionPressed(option):
	match(option):
		"New Game": get_tree().change_scene_to_file("res://scenes/levels/level1.tscn");
		"Options" : currentMenu = "Options"; UpdateMenu();
		"Audio" : currentMenu = "Audio"; UpdateMenu();
		"Graphics" : currentMenu = "Graphics"; UpdateMenu();
		"Display" : currentMenu = "Display"; UpdateMenu();
		"Exit" : get_tree().quit();
		
		#Handle what the back button does on each page
		"Back" : match(currentMenu):
			"Options" : currentMenu = "Main Menu"; UpdateMenu();
			"Audio" : currentMenu = "Options"; UpdateMenu();
			"Graphics" : currentMenu = "Options"; UpdateMenu();
			"Controls" : currentMenu = "Options"; UpdateMenu();
			"Display" : currentMenu = "Options"; UpdateMenu();
	pass
	
func CreateSlider(text, functionToCall, min_value=0, max_value=100, default_value=50, fullyCustomText=""):
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
	pass
	
	%menuItems.add_child(label);
	%menuItems.add_child(slider);
	pass

func CreateButton(text, functionToCall="OnOptionPressed"):
	var button = Button.new()
	button.text = text
	button.pressed.connect(Callable(self,functionToCall).bind(text))
	%menuItems.add_child(button)
	pass
	
func CreateCheckbox(text, functionToCall, initiallyChecked=false):
	var checkbox = CheckBox.new();
	checkbox.text = text;
	checkbox.button_pressed = initiallyChecked;
	checkbox.toggled.connect(Callable(self,functionToCall).bind(checkbox));
	%menuItems.add_child(checkbox)
	pass
