extends CanvasLayer

func _ready() -> void:
	Signals.MainMenuShown.connect(MainMenuShown)
	Signals.MainMenuHidden.connect(MainMenuHidden)


var can_end = true
func MainMenuShown(): can_end = false
func MainMenuHidden(): can_end = true

func _process(delta: float) -> void:
	if can_end == false: return
	
	if Input.is_action_just_pressed("shoot"):
		hide()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE ## SHOW THE MOUSE
		if Game.last_data != null: 
			print("Loading game...")
			Game.LoadGame(Game.last_data.save_name)
		else:
			print("Restarting level...")
			Game.RestartLevel()
		queue_free()
