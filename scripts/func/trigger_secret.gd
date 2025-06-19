@tool
extends Node3D

@export var damage = 0
@export var targetname = ""
@export var target = ""

func _func_godot_apply_properties(props:Dictionary):
	if "targetname" in props: targetname = props["targetname"] as String
	if "target" in props: target = props["target"] as String
	if "damage" in props: damage = props["damage"] as int
	
	add_to_group("Entity", true)
	if Game.map_build == Game.MAP_BUILD.PREBUILD: return
	ready()
	pass

func _ready():
	if Game.map_build == Game.MAP_BUILD.RUNTIME: return
	ready()
	
func ready():
	add_to_group("Entity", true)
	Game.UpdateEntity(self,0)
	pass
	
	
var spawn_wait = true
var spawn_timer = 0.0
var spawn_timer_max = 1.0
func SpawnWait(delta):
	if spawn_wait == false: return
	
	if spawn_timer < spawn_timer_max:
		spawn_timer+=delta
		
	if spawn_timer >= spawn_timer_max:
		spawn_wait = false
		
	
func _process(delta: float) -> void:
	SpawnWait(delta)

func on_trigger():
	if spawn_wait == true: return 
	
	Game.UpdateEntity(self,1)
	Game.secrets.current += 1
	Game.secrets.current = clampi(Game.secrets.current,0,Game.secrets.total)
	
	var text = str("Secret Unlocked! ", str(Game.secrets.current), "/", str(Game.secrets.total))
	Game.PopupMessageCreate(text)
	Console.print_line(text)
	
	self.queue_free()
	pass
	
