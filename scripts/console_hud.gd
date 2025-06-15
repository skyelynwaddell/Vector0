extends VBoxContainer

@onready var ConsoleLabelScene = preload("res://scenes/console_label.tscn")
@export var display_time := 5 ## How long a console message is displayed

var messages : Array[Dictionary] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Console.console_newline.connect(_on_console_newline)
	ClearList()


## Clears the command list
func ClearList(): 
	for child in get_children(): 
		child.queue_free()


## Emitted when there was a new line printed to the console.
func _on_console_newline(text:String):
	var _label = ConsoleLabelScene.instantiate()
	_label.text = str(text)
	add_child(_label)
	
	var new_message = {
		"name" : _label.name,
		"time" : display_time
	}
	
	messages.push_back(new_message)
	
func HandleClearMessages(delta):
	for msg in messages:
		if msg.time > 0:
			msg.time -= delta
			
		if msg.time <= 0:
			for child in get_children():
				if child.name == msg.name:
					messages.erase(msg)
					child.PlayAnim()
					break
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	HandleClearMessages(delta)
	pass
