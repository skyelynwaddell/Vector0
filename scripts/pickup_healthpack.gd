@tool
extends PickUp

@export var heal_amount := 100

@export var difficulty_spawn = 0

func _ready():
	Game.DestroyOnDifficultyFlag(difficulty_spawn, self)
	Game.UpdateEntity(self,0)
	
	match(Game.difficulty):
		Game.DIFFICULTY.EASY: heal_amount = 100
		Game.DIFFICULTY.NORMAL: heal_amount = 50
		Game.DIFFICULTY.HARD: heal_amount = 50
		Game.DIFFICULTY.INSANE: heal_amount = 50

func _func_godot_apply_properties(props:Dictionary):
	if "difficulty_spawn" in props: difficulty_spawn = props.difficulty_spawn as int
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint(): return
	Spin(delta)
	SpawnWait(delta)
	pass

@onready var audio_health = preload("res://audio/health.ogg")

func _on_body_entered(body):
	if spawn_wait == true: return

	if body.is_in_group("Player"):
		if Game.hp.current >= Game.hp.maximum:
			return
			
		var before_hp = Game.hp.current
		Game.hp.current = min(Game.hp.current + heal_amount, Game.hp.maximum)
		var increase_amount = Game.hp.current - before_hp
		
		Game.Audio3DCreate(audio_health, self, 10)
		#body.get_parent().IncreaseHealth(heal_amount)
		
		Signals.UpdateHUD.emit()
		Console.print_line("Picked up a Healthpack. Healed by %d." % increase_amount)
		Game.UpdateEntity(self,1)

		queue_free()
