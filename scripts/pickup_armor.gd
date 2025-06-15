@tool
extends PickUp

@export var armor_amount := 100
@export var difficulty_spawn = 0

func _ready():
	Game.DestroyOnDifficultyFlag(difficulty_spawn, self)
	Game.UpdateEntity(self,0)
	
	match(Game.difficulty):
		Game.DIFFICULTY.EASY: armor_amount = 100
		Game.DIFFICULTY.NORMAL: armor_amount = 50
		Game.DIFFICULTY.HARD: armor_amount = 50
		Game.DIFFICULTY.INSANE: armor_amount = 50
		

func _func_godot_apply_properties(props:Dictionary):
	if "difficulty_spawn" in props: difficulty_spawn = props.difficulty_spawn as int
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint(): return
	Spin(delta)
	SpawnWait(delta)
	pass

@onready var audio_armor = preload("res://audio/armor.ogg")

func _on_body_entered(body):
	if spawn_wait == true: return
	
	if body.is_in_group("Player"):
		if Game.armor.current >= Game.armor.maximum:
			return
			
		var before_armor = Game.armor.current
		Game.armor.current = min(Game.armor.current + armor_amount, Game.armor.maximum)
		var increase_amount = Game.armor.current - before_armor
		
		Game.Audio3DCreate(audio_armor, self, 1)
		#body.get_parent().IncreaseHealth(heal_amount)
		
		Signals.UpdateHUD.emit()
		Console.print_line("Picked up Armor. Increased by %d." % increase_amount)
		Game.UpdateEntity(self,1)
		queue_free()
